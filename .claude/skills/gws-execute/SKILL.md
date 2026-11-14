---
name: gws-execute
description: Execute approved follow-up tasks (Gmail, Docs, Sheets, Drive) with the GWS CLI. Use after the user approves GWS tasks from notion-db-analyze or notion-db-register. Checks the task type, reads the matching references/ document, builds the gws commands, shows a command preview, and runs them through the gws-executor sub-agent only after the user approves. Emails go draft first, send after draft approval. Reports result links.
---

# gws-execute

Runs approved follow-up tasks with the GWS CLI.

**No `gws` command runs without the user's approval of the command preview.**

## References

- `references/gmail.md` — email draft / send procedure and safety rules
- `references/drive.md` — Drive / Docs / Sheets procedure and safety rules
- `docs/gws-cli-reference.md` — verified `gws` commands
- `docs/approval-policy.md` — approval scope and high-risk rules
- `templates/email/` — email templates (e.g. `deadline-reminder.md`)
- `.claude/agents/gws-executor.md` — the sub-agent that runs the commands

## Input

Approved tasks from notion-db-analyze or notion-db-register. Each task has: task number, type, target, content or source data, approval note.

## Procedure

### 1. Check the task type

| Type | Reference document |
|---|---|
| Email (draft / send) | `references/gmail.md` |
| Docs / Sheets / Drive (folder, share) | `references/drive.md` |
| Other | No reference → use `docs/gws-cli-reference.md` only |

### 2. Read references and build commands

1. Read the matching document in `references/` if it exists, and `docs/gws-cli-reference.md`.
2. Build the `gws` command(s) for each task:
   - Use only commands listed in the references or `docs/gws-cli-reference.md`.
   - If a command is not listed, check it with `gws <command> --help` (read-only) before using it; never guess flags.
   - Fill email bodies from `templates/email/` when a template fits.
   - Follow the file naming and sharing rules in `references/drive.md`.
3. If required data is missing (recipient, file name, folder, content), ask the user before the preview.

### 3. Show the command preview and get approval

```
[Command preview]
| # | Task | Target | Command |
|---|---|---|---|
| 1 | Email draft: 마감 알림 | kim@example.com | gws ... |
| 2 | Sheets: 2026-11-14_주간일정 | My Drive/일정 | gws ... |
High-risk: (external recipients, bulk send, sharing changes)
Note: emails are created as drafts only; sending needs a second approval.
→ Approve all / by number / after edit / reject
```

- **Edit** → rebuild the commands and show the preview again.
- **Reject** → do not run. Stop.

### 4. Run via gws-executor

Call the `gws-executor` sub-agent with the approved commands exactly as previewed (task number, type, target, command, approval note).

### 5. Email: draft approval, then send

1. gws-executor returns the created drafts (draft ID, recipients, subject, body preview).
2. Show the drafts and the send command preview; get approval per draft: all / by number / after edit / reject.
3. Approved drafts → call gws-executor to send them. Edited drafts → update and show again. Rejected drafts → kept as drafts.

### 6. Report results

Per task: result (success / failed / skipped / draft created / sent / kept as draft) and **result links**: file and folder links, draft ID, message ID. Include errors and how to fix them.

### 7. Log

Record in `runs/`: timestamp, source (analyze / register), command preview, approvals, executed commands, results, links and IDs.

## Constraints

- Do not run `gws` commands directly in this skill (except read-only `--help` / `--version` checks); execution goes only through gws-executor.
- Run only approved tasks, and only the commands shown in the preview.
- Never send an email without approval of that draft.
- Never delete files or drafts, never overwrite files, and never change sharing without explicit approval.
