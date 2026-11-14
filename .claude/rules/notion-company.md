# Rule: notion-회사 (company)

Save **진흥원-related schedules from Google Calendar** to the Notion **회사** DB.

> Precedence: if this rule conflicts with CLAUDE.md, skills, agents, `config/`, or `docs/`, this rule wins.

## Target

| Item | Value |
|---|---|
| Notion DB | 회사 |
| DB ID | (fill in after the DB is created or found) |
| Source | Google Calendar (via GWS CLI) |
| Match word | `진흥원` |
| Trigger keyword | None — runs on a request such as "진흥원 일정 가져와줘", "회사 일정 동기화해줘" |

## Overrides of other rules

- **Analysis mode "no Notion writes":** this request has no trigger keyword but writes to Notion. Do not route it to notion-db-analyze; use the sync procedure below.
- **gws-execute "no gws command without a command preview":** the Google Calendar **read-only** query in step 1 may run through gws-executor without a command preview. Any other `gws` command (create, update, delete, share, send) still needs the normal preview and approval.

## Sync procedure

1. **Read Google Calendar (read-only).** Default range: today to 30 days ahead, unless the user gives a range. Use only a read-only calendar list command verified with `gws calendar --help` and recorded in `docs/gws-cli-reference.md`.
2. **Filter.** Keep events whose title, description, or location contains `진흥원`.
3. **Remove duplicates.** Query the 회사 DB (read-only) and drop events whose Google Calendar event ID is already saved. If an event exists with different date/time, list it as "changed".
4. **Show the sync preview:** `# | Title | Date | Time | Location | Calendar event ID | New / Changed`.
5. **Get user approval** (all / by number / after edit / reject). Never write without approval.
6. **Register via notion-writer.** New events → create rows. Changed events → update rows. Save the Google Calendar event ID in each row.
7. **Report** created / updated page links and record the run in `runs/`.

## Property mapping (proposal)

| 회사 DB property | Google Calendar field |
|---|---|
| Title | Event title |
| Date | Start date-time – end date-time |
| Location | Location |
| Notes | Description |
| Calendar event ID | Event ID (used for duplicate check) |

## Rules

1. Only events containing `진흥원` are saved to 회사. Other calendar events are not saved anywhere by this rule.
2. Never modify or delete Google Calendar events.
3. Never delete Notion rows. If an event was removed from the calendar, report it and archive the row only after the user approves.
4. If the 회사 DB does not exist yet, do not register. Tell the user and offer to create it (notion-writer Job A, with approval). Note: the existing page titled "회사" under 채용 공고 트래커 is **not** this DB.
