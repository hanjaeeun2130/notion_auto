# Rule: notion-회사 (company)

Save **진흥원-related schedules** to the Notion **회사** DB, either from Google Calendar (sync) or from direct input (`진흥원 : <content>`).

> Precedence: if this rule conflicts with CLAUDE.md, skills, agents, `config/`, or `docs/`, this rule wins.

## Target

| Item | Value |
|---|---|
| Notion DB | 회사 |
| DB ID | `4194deaa8451811185c0ef630639c99f` (data source `collection://4194deaa-8451-81e4-9bbd-000b0996c136`) |
| Properties | 업무 목록 (title), 날짜 (date), 시간 (text), 장소 (text) |
| Source | Google Calendar (via GWS CLI) |
| Match word | `진흥원` |
| Trigger keyword | `진흥원` or `회사` for direct input (`회사 : <content>` is saved to 회사 even if it is not 진흥원-related) (e.g. `진흥원 : 사업설명회 11/28 오후 2시`). Calendar sync has no keyword — it runs on a request such as "진흥원 일정 가져와줘", "회사 일정 동기화해줘" |

## Overrides of other rules

- **Analysis mode "no Notion writes":** this request has no trigger keyword but writes to Notion. Do not route it to notion-db-analyze; use the sync procedure below.
- **gws-execute "no gws command without a command preview":** the Google Calendar **read-only** query in step 1 may run through gws-executor without a command preview. Any other `gws` command (create, update, delete, share, send) still needs the normal preview and approval.

## Sync procedure

1. **Read Google Calendar (read-only).** Default range: today to 30 days ahead, unless the user gives a range. Use only a read-only calendar list command verified with `gws calendar --help` and recorded in `docs/gws-cli-reference.md`.
2. **Filter.** Keep events whose title, description, or location contains `진흥원`.
3. **Remove duplicates.** Query the 회사 DB (read-only) and drop events whose 업무 목록 + 날짜 already match a saved row (the DB has no Calendar event ID property). If an event exists with different date/time, list it as "changed".
4. **Show the sync preview:** `# | Title | Date | Time | Location | Calendar event ID | New / Changed`.
5. **Get user approval** (all / by number / after edit / reject). Never write without approval.
6. **Register via notion-writer.** New events → create rows. Changed events → update rows.
7. **Report** created / updated page links and record the run in `runs/`.

## Property mapping (proposal)

| 회사 DB property | Google Calendar field |
|---|---|
| 업무 목록 | Event title |
| 날짜 | Start date – end date |
| 시간 | Start time – end time (text) |
| 장소 | Location |

## Rules

1. Only events containing `진흥원` are saved to 회사. Other calendar events are not saved anywhere by this rule.
2. Never modify or delete Google Calendar events.
3. Never delete Notion rows. If an event was removed from the calendar, report it and archive the row only after the user approves.
4. If the 회사 DB does not exist yet, do not register. Tell the user and offer to create it (notion-writer Job A, with approval). Note: the existing page titled "회사" under 채용 공고 트래커 is **not** this DB.

## Direct input (`진흥원 : <content>`)

1. Register through the notion-db-register skill: property split → preview → user approval → notion-writer.
2. Fill only 업무 목록, 날짜, 시간, 장소; leave missing ones empty (날짜 missing → today).
3. After saving, output only one line: `저장됨: 회사`.
