# gws command catalog (gws 0.22.5)

Use this to answer "what can gws do?" Details live in the per-service references.

Availability with the current login: ✅ granted · 🔓 works with the drive scope · 🔒 needs API + scope added (`setup-auth.md` §5)

## Services

| Service | Purpose | Availability |
|---|---|---|
| `calendar` | calendars, events | ✅ |
| `gmail` | read, draft, send, labels | ✅ |
| `drive` | files, folders, shared drives, permissions | ✅ |
| `sheets` | spreadsheets | ✅ |
| `docs` | Google Docs | 🔓 |
| `slides` | presentations | 🔓 |
| `tasks` | task lists | 🔒 |
| `people` | contacts, profiles | 🔒 |
| `chat` | Chat spaces, messages | 🔒 (Workspace) |
| `forms` | forms, responses | 🔒 |
| `keep` | Keep notes | 🔒 (Workspace) |
| `meet` | Meet spaces, conference records | 🔒 |
| `classroom` | courses, coursework | 🔒 |
| `script` | Apps Script projects | 🔒 |
| `workflow` (`wf`) | cross-service helpers | depends on services used |
| `admin-reports` (`reports`) | audit/usage logs | admin only |
| `events`, `modelarmor` | Workspace event subscriptions, content filtering | 🔒 |

## Helpers

| Command | Purpose | Kind |
|---|---|---|
| `calendar +agenda` | upcoming events (`--today/--tomorrow/--week/--days N/--calendar`) | read |
| `calendar +insert` | create event (`--summary --start --end --location --attendee --meet`) | write |
| `gmail +triage` | unread summary (`--query --max --labels`) | read |
| `gmail +read` | message body/headers | read |
| `gmail +send` | send (`--draft` to save as draft) | send |
| `gmail +reply` / `+reply-all` / `+forward` | threaded reply / forward (`--draft`) | send |
| `gmail +watch` | stream new mail via Pub/Sub | read (creates Pub/Sub resources) |
| `sheets +read` / `+append` | read range / append rows | read / write |
| `docs +write` | append text | write |
| `drive +upload` | upload file | write |
| `chat +send` | post message | write |
| `script +push` | upload script files | write |
| `workflow +standup-report` / `+meeting-prep` / `+weekly-digest` | summaries | read |
| `workflow +email-to-task` / `+file-announce` | mail→task / announce file | write |

## Main resources and methods

| Service | Resource | Methods |
|---|---|---|
| calendar | `events` | list, get, instances, insert, quickAdd, update, patch, move, import, delete, watch |
| calendar | `calendarList`, `calendars`, `acl`, `freebusy`, `settings`, `colors` | calendar list, sharing, free/busy |
| gmail | `users messages` | list, get, send, modify, batchModify, trash, untrash, delete, batchDelete, insert, import, attachments |
| gmail | `users drafts` | list, get, create, update, send, delete |
| gmail | `users` | getProfile, labels, threads, history, settings, watch, stop |
| drive | `files` | list, get, create, copy, update, download, export, delete, emptyTrash, watch, listLabels, modifyLabels |
| drive | `permissions`, `drives`, `comments`, `replies`, `revisions`, `changes`, `about` | sharing, shared drives, comments, versions |
| sheets | `spreadsheets` | create, get, batchUpdate, getByDataFilter |
| sheets | `spreadsheets values` | get, batchGet, update, batchUpdate, append, clear, batchClear (+ByDataFilter) |
| docs | `documents` | create, get, batchUpdate |
| slides | `presentations` | create, get, batchUpdate (+ pages) |
| tasks | `tasklists`, `tasks` | list, get, insert, update, patch, delete, move, clear |

## Global flags

| Flag | Meaning |
|---|---|
| `--params <JSON>` | URL/query parameters |
| `--json <JSON>` | request body |
| `--upload <PATH>` / `--upload-content-type` | media upload |
| `--output <PATH>` | save binary response |
| `--format json\|table\|yaml\|csv` | output format |
| `--page-all`, `--page-limit N`, `--page-delay MS` | pagination (NDJSON) |
| `--dry-run` | validate locally, send nothing |
| `--api-version` | override API version |

## Auth commands

`gws auth status` · `gws auth login -s <services>` · `gws auth setup` (needs gcloud; stops at OAuth client creation in 0.22.5) · `gws auth export [--unmasked]` · `gws auth logout`

## Exit codes

0 success · 1 API error · 2 auth · 3 validation · 4 discovery · 5 internal
