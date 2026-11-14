---
name: notion-db-analyze
description: Handle lookup / analysis requests that have no trigger keyword (e.g. "오늘 마감 작업 확인해줘", "이번 주 일정 정리해줘"). Filters Notion DBs by date, status, assignee, etc. through the read-only notion-analyst sub-agent, reports with templates/report.md, and hands approved GWS tasks to the gws-execute skill. Never writes to Notion.
---

# notion-db-analyze

Processes lookup and analysis requests without a trigger keyword.

**This skill never writes to Notion** — no page or DB creation, update, archive, or delete, and no call to `notion-writer`.

## References

- `docs/intent-catalog.md` — request type → query conditions → suggested GWS task
- `docs/notion-db-schema.md` — properties, status values, assignee → email mapping
- `.claude/rules/` — DB list and IDs
- `templates/report.md` — report format
- `.claude/agents/notion-analyst.md` — the read-only sub-agent that queries and analyzes

## Procedure

### 1. Confirm the mode

- If the input is in `<keyword> : <content>` format with a registered keyword, this is not an analysis request; use the notion-db-register skill instead.
- If the request asks to register or change data, do not handle it here. Tell the user to use the trigger format (e.g. `업무 : ...`).

### 2. Query and analyze via notion-analyst

Call the `notion-analyst` sub-agent with:
- The user's original request
- The current date, time, and time zone (Asia/Seoul)

The sub-agent matches the request type, converts the conditions, queries the DBs, and returns: query conditions / result items / summary / suggested GWS tasks.

Condition conversion reference (applied by the sub-agent):

| Expression | Condition |
|---|---|
| 오늘 / 내일 / 이번 주 / 다음 주 | Date = resolved date or date range (week = Monday–Sunday) |
| ~까지 / 마감 | Due date ≤ given date |
| 지연 / 기한 지난 | Due date < today AND status = unfinished |
| 미완료 / 완료 / 취소 | Status values from `docs/notion-db-schema.md` |
| <name> 담당 | Assignee = matched person |

### 3. Handle ambiguous or empty results

- **Ambiguous:** if the sub-agent returns candidate interpretations, ask the user to choose, then query again.
- **0 results:** show the conditions used and suggest relaxed conditions.

### 4. Report

Fill `templates/report.md`:
1. Request summary (original + interpreted intent)
2. Query conditions (DBs, filters, reference time)
3. Result table (`# | Title | Date | Status | Assignee | Source DB`)
4. Suggested GWS tasks (`# | Task | Target | Note`)
5. Approval request: "Approve all / by number / after edit / reject"

### 5. Hand off approved tasks

- Approved GWS tasks → hand to the **gws-execute** skill with the task number, type, target, content, and source result items.
- Rejected or no tasks → end after the report.

### 6. Log

Record in `runs/`: timestamp, request, query conditions, result count, suggested tasks, approval decision.

## Examples

| Request | Query | Suggested task |
|---|---|---|
| 오늘 마감 작업 확인해줘 | 업무일정, due = today, unfinished | Deadline reminder email to assignees |
| 이번 주 일정 정리해줘 | 개인일정 + 업무일정, date in this week | Weekly schedule Sheets |
| 지연된 작업 알려줘 | 업무일정, due < today, unfinished | Reminder email to assignees |

## Constraints

- No Notion writes of any kind in this skill.
- No `gws` commands in this skill; GWS work goes only through the gws-execute skill after approval.
- Report only what the query returned.
