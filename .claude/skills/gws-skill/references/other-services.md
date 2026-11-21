# Other services and workflow helpers

These services need their API enabled in the GCP project and their scope added at login (`setup-auth.md` §5), except where noted. Before first use, run the read command; if it exits 2 or 403, add the scope/API and tell the user a re-login is needed.

## Workflow helpers (`gws workflow ...`, alias `wf`)

| Helper | What it does | Needs | Kind |
|---|---|---|---|
| `+standup-report` | today's meetings + open tasks | calendar, tasks | read |
| `+meeting-prep [--calendar <ID>]` | next event: agenda, attendees, linked docs | calendar | read |
| `+weekly-digest` | this week's meetings + unread mail count | calendar, gmail | read |
| `+email-to-task --message-id <id> [--tasklist <ID>]` | Gmail message → Google Tasks entry | gmail, tasks | write |
| `+file-announce --file-id <id> --space spaces/<ID> [--message '<text>']` | post a Drive file in a Chat space | drive, chat | write |

All take `--format table` and `--dry-run`.

## Tasks (`tasks`)

| Task | Command | Kind |
|---|---|---|
| Task lists | `gws tasks tasklists list` | read |
| Tasks in a list | `gws tasks tasks list --params '{"tasklist":"@default","showCompleted":false}'` | read |
| Add | `gws tasks tasks insert --params '{"tasklist":"@default"}' --json '{"title":"<title>","due":"2026-11-30T00:00:00Z","notes":"<notes>"}'` | write |
| Complete | `gws tasks tasks patch --params '{"tasklist":"@default","task":"<id>"}' --json '{"status":"completed"}'` | write |

## People / contacts (`people`)

| Task | Command | Kind |
|---|---|---|
| My contacts | `gws people people connections list --params '{"resourceName":"people/me","personFields":"names,emailAddresses,phoneNumbers","pageSize":50}'` | read |
| Search | `gws people people searchContacts --params '{"query":"김","readMask":"names,emailAddresses"}'` | read |
| Groups | `gws people contactGroups list` | read |

## Chat (`chat`) — usually Workspace (company) accounts only

| Task | Command | Kind |
|---|---|---|
| Spaces | `gws chat spaces list` | read |
| Messages | `gws chat spaces messages list --params '{"parent":"spaces/<ID>"}'` | read |
| Send | `gws chat +send --space spaces/<ID> --text '<text>'` | write (reaches others: confirm) |

## Forms (`forms`)

| Task | Command | Kind |
|---|---|---|
| Form | `gws forms forms get --params '{"formId":"<ID>"}'` | read |
| Responses | `gws forms forms responses list --params '{"formId":"<ID>"}'` | read |
| Create | `gws forms forms create --json '{"info":{"title":"<title>"}}'` | write |

## Meet (`meet`)

| Task | Command | Kind |
|---|---|---|
| Past conferences | `gws meet conferenceRecords list` | read |
| Create meeting space | `gws meet spaces create --json '{}'` (returns a meeting link) | write |

Easier for a meeting with a link: `gws calendar +insert ... --meet`.

## Keep (`keep`) — Workspace accounts only; personal Gmail accounts usually get 403

`gws keep notes list`, `gws keep notes get --params '{"name":"notes/<id>"}'`.

## Classroom (`classroom`)

`gws classroom courses list`, `gws classroom courses courseWork list --params '{"courseId":"<id>"}'`.

## Apps Script (`script`)

| Task | Command | Kind |
|---|---|---|
| Project content | `gws script projects getContent --params '{"scriptId":"<ID>"}'` | read |
| Push local files | `gws script +push --script <ID> [--dir ./src]` | write — replaces **all** files in the project |

## Admin reports (`admin-reports`, alias `reports`)

Workspace admin accounts only (audit logs, usage). Not available for personal accounts.

## Discovering anything else

- `gws <service> --help` → resources and helpers
- `gws <service> <resource> --help` → methods
- `gws schema <service>.<resource>.<method>` → parameters and body shape
