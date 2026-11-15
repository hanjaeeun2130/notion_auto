---
name: notion-db-register
description: Register a schedule entry into Notion when the user input starts with a trigger keyword defined in .claude/rules/ ("<keyword> : <content>", half-width ":" or full-width "："). Splits the content into DB properties, shows a registration preview, and registers through the notion-writer sub-agent only after the user approves. Also handles edit / cancel requests in trigger format, and hands follow-up GWS tasks to the gws-execute skill.
---

# notion-db-register

Registers an entry decided by a trigger keyword into the mapped Notion DB.

**Never register, edit, or archive anything without the user's approval of the preview.**

## References

- `.claude/rules/` — keywords, aliases, target DB, DB ID, default values (one rule file per DB)
- `docs/notion-db-schema.md` — properties, types, required fields, options per DB
- `templates/register-result.md` — result report format
- `.claude/agents/notion-writer.md` — the sub-agent that performs the write

## Procedure

### 1. Recognize the trigger

- Format: `<keyword> : <content>`. Allow spaces around the colon; accept `:` and `：`.
- Match the keyword against keywords and aliases in the `.claude/rules/` files (case-insensitive).
- Colon format but no match → show the list of registered keywords and ask the user again. Stop.
- Edit / cancel words in the content (e.g. "취소", "변경", "cancel", "change to") → go to **Edit / cancel requests** below.

### 2. Load the schema

- Read the target DB's section in `docs/notion-db-schema.md`.
- If missing or outdated, fetch the DB schema with `notion-fetch` (read-only).

### 3. Split the content into properties

Extract only properties that exist in the target DB.

| Property | Rule |
|---|---|
| Title | The content with date, time, place, assignee, and follow-up task expressions removed |
| Date | Resolve to an absolute date using the current date and time zone (Asia/Seoul): 오늘 / 내일 / 모레 / 토요일 (next occurrence, today included) / 다음 주 월요일 / 11/20 (this year; if already past, mark low-confidence) |
| Time | 오후 3시 → 15:00, 15:00 → 15:00. Without 오전/오후: 1–6 → PM, 7–11 → AM, 12 → noon; mark as low-confidence |
| Place / assignee / priority, etc. | Only if the DB has the property; assignee must match a known person, otherwise low-confidence |
| Missing properties | Fill with defaults from the matching `.claude/rules/` file (e.g. date missing → today) and mark as default |

### 4. Check before preview

- **Required properties:** if a required property is still empty, ask for it.
- **Options:** if a select / status value is not an existing option, propose the closest option or ask.
- **Duplicates:** query the DB (read-only) for an entry with the same date and the same or near-identical title. If found, show it in the preview.

### 5. Separate follow-up tasks

If the input also asks for GWS work (e.g. "팀장에게 메일 보내줘", "시트로 정리해줘"), take it out of the entry content and list it as a follow-up task. It is not part of the Notion entry.

### 6. Show the registration preview and get approval

```
[Registration preview]
Keyword: 업무 → DB: Work
| Property | Value | Source |
|---|---|---|
| Title | 기획안 제출 | input |
| Date | 2026-11-20 | input "11/20" |
| Status | 진행 전 | default |
Needs check: (low-confidence values, possible duplicates)
Follow-up tasks: (if any)
→ Approve / Edit (tell me what to change) / Reject
```

- **Approve** → step 7.
- **Edit** → apply the changes and show the preview again.
- **Reject** → do not register. Stop.

### 7. Register via notion-writer

Call the `notion-writer` sub-agent with:
- Target DB (name, ID)
- The approved property values, exactly as approved
- Original input text
- Approval note

### 8. Report and log

- Output only one line: `저장됨: [DB name]` (CLAUDE.md 3.1). If the user asks for details or the registration fails, report in `templates/register-result.md` format: keyword → DB, registered values with original expressions, page link, values filled by defaults, how to edit or undo (e.g. "개인 : 카페 약속 시간 4시로 변경").
- Record in `runs/`: timestamp, original input, preview, approval, page ID, result.

### 9. Hand off follow-up tasks

If step 5 found follow-up tasks, show them and, after the user approves them, hand them to the **gws-execute** skill with the created page info (title, date, link).

## Edit / cancel requests

1. Find the target row by keyword DB + title (+ date) with a read-only query.
2. Show the target row and the change (new values, or "archive" for cancel).
3. After approval, call `notion-writer` to update or archive the row. Cancellation is done by changing status or archiving; never delete.
4. If several rows match, list them and let the user pick.

## Examples

| Input | Result |
|---|---|
| `개인 : 친구와 카페 약속 토요일 3시` | DB Personal Tasks / Title 친구와 카페 약속 / Date next Saturday / Time 15:00 (low-confidence: no 오전/오후) / Status 예정 (default) |
| `업무：기획안 제출 11/20 마감` | DB Work / Title 기획안 제출 / Date 2026-11-20 / Status 진행 전 (default) |
| `업무 : 주간회의 내일 오전 10시, 팀원들에게 메일 보내줘` | DB Work / Title 주간회의 / Date tomorrow / Time 10:00 / Follow-up: email to team → gws-execute |
| `개인 : 카페 약속 취소` | Edit / cancel request → find the row → show it → archive after approval |
| `회식 : 금요일 7시` (no such keyword) | Show registered keywords and ask again |

## Constraints

- No registration, edit, or archive without approval of the preview.
- Write only to DBs defined in `.claude/rules/`.
- Never delete Notion pages or DBs.
- This skill does not run `gws` commands; follow-up tasks go to the gws-execute skill.
