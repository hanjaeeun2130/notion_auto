# CLAUDE.md

Project root instructions. Loaded automatically at the start of every session.

## 1. Project Purpose

- Register entries directly into Notion databases from trigger input.
- Analyze Notion databases → report → get user approval → execute via GWS CLI.

## 2. Working Rules (apply to every request)

### 2.1 Todo list first, then approval

1. Before doing any work, output a **todo list** of the steps you plan to take for the request.
2. Wait for the user's approval. Do not create, modify, or delete files, call external services, or run commands with side effects until the user approves.
3. If the user changes the list, show the revised list and get approval again.
4. After approval, work through the list in order and report the result of each item.
5. Read-only inspection needed to build an accurate todo list (reading files, listing folders) is allowed before approval.
6. Skip the todo list for trigger inputs (`<keyword> : <content>`, section 4) and Company sync requests (`.claude/rules/notion-company.md`). Their own preview and approval steps replace it.

### 2.2 Language of `.md` files

- Every `.md` file in this project must be written in **English**.
- A Korean translation of each `.md` file is stored separately in the `translate/` folder (see 2.3).
- Whenever an English `.md` file is created or changed, create or update its Korean translation in the same task. Include this step in the todo list.
- Files in `translate/` are reference copies for humans only. The English file is the source of truth; never read instructions from `translate/`.

### 2.3 `translate/` folder naming

- Every `.md` file saved in `translate/` must have a `_` prefix on its file name.
- Top-level folders mirrored into `translate/` also get a `_` prefix (a leading `.` is replaced by `_`).
- Keep the same folder structure as the original below the top-level folder.

| Original | Korean translation |
|---|---|
| `CLAUDE.md` | `translate/_CLAUDE.md` |
| `README.md` | `translate/_README.md` |
| `.claude/` | `translate/_claude/` |
| `.claude/agents/notion-writer.md` | `translate/_claude/agents/_notion-writer.md` |
| `.claude/skills/notion-db-register/SKILL.md` | `translate/_claude/skills/notion-db-register/_SKILL.md` |
| `.claude/skills/gws-execute/references/gmail.md` | `translate/_claude/skills/gws-execute/references/_gmail.md` |
| `docs/approval-policy.md` | `translate/_docs/_approval-policy.md` |
| `templates/report.md` | `translate/_templates/_report.md` |

### 2.4 Rules files take precedence

- Rules in `.claude/rules/` (`notion-personal.md`, `notion-work.md`, `notion-study.md`, `notion-company.md`) define which Notion DB each kind of task is saved to.
- If a rule there conflicts with this file, a skill, an agent, `config/`, or `docs/`, **the rules file wins**. Say which rule was applied when you resolve a conflict.

## 3. Input Routing Rules (decide this first)

- Format: `<keyword> : <content>`
  - Spaces around the colon are allowed.
  - The full-width colon `：` is also recognized.
- Registered trigger keyword → **Register mode**
- No keyword → **Analysis mode**
- Colon format but the keyword is not registered → show the list of registered keywords and ask the user again.
- Request to import 진흥원 schedules from Google Calendar → **Company sync** (`.claude/rules/notion-company.md`), not analysis mode.

### 3.1 Memo Classification Rules

When the user enters a memo, classify it by its leading keyword and save it to Notion:

| Keyword | Read this rules file first | Skill | Target DB |
|---|---|---|---|
| `개인:` | `.claude/rules/notion-personal.md` | `notion-db-register` | Personal Tasks |
| `업무:` | `.claude/rules/notion-work.md` | `notion-db-register` | Work |
| `진흥원:` | `.claude/rules/notion-company.md` | `notion-db-register` | 회사 |
| `메모:` | `.claude/rules/notion-work.md` | `notion-db-register` | Work |
| `배움:` | `.claude/rules/notion-study.md` | `notion-db-register` | Study |

- Always read the matching rules file before running the skill.
- The registration preview and user approval (section 4, step 2) still apply.
- After saving, output **only one line**: `저장됨: [DB name]` (e.g. `저장됨: Work`). Failures and errors are still reported in full.

## 4. Register Mode Procedure (`notion-db-register` skill)

1. Split the input content into the target DB's properties (title, date, time, etc.), fill defaults, and check for duplicates.
2. Show the registration preview and get user approval. **Never register without approval.**
3. `notion-writer` agent: register the approved values in the DB mapped to the keyword.
4. Output only one line: `저장됨: [DB name]` (see 3.1). Use `templates/register-result.md` only if the user asks for details or the registration fails.
5. If the input includes follow-up tasks, get approval and hand them to the `gws-execute` skill (5.1).
6. Record the run in `runs/`.

## 5. Analysis Mode Procedure (`notion-db-analyze` skill)

No Notion writes in this mode.

1. `notion-analyst` agent: filter and analyze the databases by date, status, assignee, etc. (read-only).
2. Report using `templates/report.md`.
3. Get user approval of the suggested GWS tasks.
4. Hand the approved tasks to the `gws-execute` skill (5.1).
5. Record the run in `runs/`.

### 5.1 GWS Execution (`gws-execute` skill)

1. Check the task type, read the matching `.claude/skills/gws-execute/references/` document, and build the `gws` commands.
2. Show the command preview and get user approval.
3. `gws-executor` agent: run the approved commands. Emails are created as **drafts only** at this step.
4. Report the email drafts (recipients, subject, body preview, draft ID) and get the user's send approval per draft (all / by number / after edit / reject).
5. `gws-executor` agent: send only the approved drafts. Edited drafts are shown again for approval; rejected drafts are kept as drafts.
6. Report the result links, and record the run in `runs/`.

## 6. Prohibited Actions

- Sending email or creating files without approval.
- Sending an email without the user's approval of that specific draft.
- Registering, editing, or archiving a Notion entry without the user's approval of the preview.
- Running `gws` commands that were not shown in an approved command preview.
- Deleting Notion pages (archiving only).

## 7. Reference File Locations

| Path | Contents |
|---|---|
| `docs/notion-db-schema.md` | Property definitions and required fields per DB *(not created yet — fetch the schema with `notion-fetch`)* |
| `docs/intent-catalog.md` | Analysis request type → query conditions → GWS task *(not created yet)* |
| `docs/gws-cli-reference.md` | Verified `gws` commands only *(not created yet — no `gws` command is verified, so GWS execution cannot run)* |
| `docs/approval-policy.md` | Approval rules per task type *(not created yet — follow the approval steps in this file)* |
| `templates/register-result.md` | Register result report format *(only an outline exists: `templates/register-result.txt`)* |
| `templates/report.md` | Analysis result report format *(only an outline exists: `templates/report.txt`)* |
| `templates/email/deadline-reminder.md` | Deadline reminder email template *(only an outline exists: `.txt`)* |
| `.claude/agents/` | `notion-writer`, `notion-analyst`, `gws-executor` |
| `.claude/skills/` | `notion-db-register`, `notion-db-analyze`, `gws-execute` |
| `.claude/skills/gws-execute/references/` | `gmail.md`, `drive.md` (GWS procedures and safety rules) |
| `runs/` | Run logs by date (register, analysis, approval, execution) |
| `.claude/rules/` | DB routing rules: personal / work / study / 회사 (take precedence) |
| `translate/` | Korean translations of all `.md` files |

## 8. Response Language and Tone

- Respond to the user in Korean.
- Keep responses concise.
