# Calendar

Times are RFC3339 with offset, e.g. `2026-11-21T09:00:00+09:00`. Default timezone: `GWS_TIMEZONE` (Asia/Seoul).

## Read (run directly)

| Task | Command |
|---|---|
| Today / tomorrow / this week | `gws calendar +agenda --today` · `--tomorrow` · `--week` (add `--timezone Asia/Seoul --format table`) |
| Next N days | `gws calendar +agenda --days 30` |
| One calendar only | `gws calendar +agenda --days 7 --calendar '진흥원(한재은)'` (name or ID) |
| List calendars | `gws calendar calendarList list --params '{"fields":"items(id,summary,accessRole)"}'` |
| Events in a range | `gws calendar events list --params '{"calendarId":"<ID>","timeMin":"<start>","timeMax":"<end>","singleEvents":true,"orderBy":"startTime"}'` |
| Keyword search | add `"q":"<word>"` to `events list` (title, description, location, attendees) |
| One event | `gws calendar events get --params '{"calendarId":"<ID>","eventId":"<eventId>"}'` |
| Recurring instances | `gws calendar events instances --params '{"calendarId":"<ID>","eventId":"<eventId>"}'` |
| Free/busy | `gws calendar freebusy query --json '{"timeMin":"<start>","timeMax":"<end>","items":[{"id":"primary"}]}'` |

`+agenda` covers all calendars the user subscribes to and is documented as read-only. Use `events list` when you need full fields (id, description, attendees) or a calendar ID. Add `"fields":"items(id,summary,location,start,end)"` to shrink output; add `--page-all` for long ranges.

Tip: some users keep work events in separate calendars whose event titles never mention the organisation. Search by calendar (list calendars first), not only by `q`.

## Write (preview → dry-run → approval)

| Task | Command |
|---|---|
| Create event | `gws calendar +insert --summary '<title>' --start '<start>' --end '<end>' [--location '<place>'] [--description '<text>'] [--attendee a@x.com] [--meet] [--calendar <ID>]` |
| Quick add from text | `gws calendar events quickAdd --params '{"calendarId":"primary","text":"Lunch with Kim tomorrow 12pm"}'` |
| Change fields | `gws calendar events patch --params '{"calendarId":"<ID>","eventId":"<id>"}' --json '{"location":"Room 3"}'` |
| Move to another calendar | `gws calendar events move --params '{"calendarId":"<from>","eventId":"<id>","destination":"<to>"}'` |
| Delete | `gws calendar events delete --params '{"calendarId":"<ID>","eventId":"<id>"}'` — only on explicit request |

Adding `--attendee` sends invitations to those people, so mention that in the preview. All-day events use `{"date":"2026-11-25"}` instead of `dateTime` in raw `--json` bodies.

## Example

"이번 주 진흥원 일정 보여줘":
```
bash scripts/gws.sh calendar calendarList list --params '{"fields":"items(id,summary)"}' 2>/dev/null   # find calendars named 진흥원(...)
bash scripts/gws.sh calendar +agenda --week --calendar '진흥원(한재은)' --timezone Asia/Seoul --format table 2>/dev/null
```
Repeat `+agenda` per matching calendar (or use `+agenda --week` and filter rows whose `calendar` starts with `진흥원`), then present one merged table: date, time, title, location, calendar.
