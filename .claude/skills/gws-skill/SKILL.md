---
name: gws-skill
description: Use the Google Workspace CLI (gws) to read and act on the user's Google Calendar, Gmail, Drive, Sheets, Docs, Slides, Tasks, Chat, Forms, Meet and Apps Script from the terminal. Use this skill whenever the user asks to check, search, list, summarize, create, update, upload, share or send anything in Google Workspace — e.g. "오늘 일정 보여줘", "진흥원 캘린더 이번 주 일정", "안 읽은 메일 요약", "메일 초안 만들어줘", "드라이브에 파일 올려줘", "시트에 행 추가", "구글 문서에 내용 붙여줘", "gws 명령어 알려줘" — even if they don't say "gws". Also use it to install gws, set up or repair OAuth login, or explain what gws can do. Credentials come from the skill's own .env, so it works from any folder.
---

# gws-skill

Drive Google Workspace through the `gws` CLI (npm `@googleworkspace/cli`, tested with 0.22.5). This skill bundles a wrapper that loads OAuth credentials from its own `.env`, a preflight check, and per-service usage notes.

Paths below are relative to this skill's folder (the folder that holds this file).

## 1. Run every command through the wrapper

The wrapper loads `.env` (client ID/secret, project ID) and fixes UTF-8, so commands work from any working directory.

| Shell | Call |
|---|---|
| Bash (preferred: plain JSON quoting) | `bash <skill>/scripts/gws.sh <args>` |
| PowerShell | `& '<skill>\scripts\gws.ps1' <args>` |

In PowerShell, call the script with `&`, not `powershell -File` — the extra process strips the quotes inside `--params` JSON and gws fails with exit 3 ("key must be a string"). In PowerShell, JSON quotes must also be escaped: `'{\"pageSize\": 5}'`. Bash takes `'{"pageSize": 5}'` as is, which is why Bash is preferred.

Every call prints `Using keyring backend: keyring` on stderr. It is noise; drop stderr (`2>/dev/null`) when you parse output.

## 2. Preflight once per session

Run `bash <skill>/scripts/preflight.sh` (or `scripts/preflight.ps1`) before the first real command. It checks Node, gws, `.env`, and the login token, and prints `READY` or what is missing. It never installs or changes anything.

If it is not READY, read `references/setup-auth.md` and fix the failing line. Installing software or logging in changes the user's machine or account, so tell the user what you will do and get a yes first. Login opens a Google consent page where the user must sign in and click Allow themselves.

## 3. Build the command

Pick the reference for the service and read it — it has the exact flags, examples, and pitfalls:

| Request is about | Read |
|---|---|
| Calendar, events, agenda, free/busy | `references/calendar.md` |
| Gmail: search, read, triage, drafts, send, reply, labels | `references/gmail.md` |
| Drive: list, search, upload, download, export, share | `references/drive.md` |
| Sheets, Docs, Slides | `references/sheets-docs-slides.md` |
| Tasks, People, Chat, Forms, Keep, Meet, Classroom, Apps Script, workflow helpers | `references/other-services.md` |
| Install, login, scopes, `.env`, errors | `references/setup-auth.md` |
| "What can gws do?" overview | `references/command-catalog.md` |

Command shapes:

```
gws <service> +<helper> [flags]                       # helpers: short forms for common jobs
gws <service> <resource> [sub-resource] <method> --params '<query JSON>' [--json '<body JSON>']
gws schema <service.resource.method>                  # show parameters of any raw method
```

Prefer a helper (`+agenda`, `+triage`, `+send`, `+append`, `+upload` ...) when one fits; fall back to the raw API for anything else. When unsure of a flag, run `<command> --help` — it is fast and read-only. Add `--format table` when the output is for a person, and keep JSON when you need to parse it. Use `fields` in `--params` to keep responses small.

## 4. Safety: read freely, confirm before changing anything

Reading is harmless, so run read-only commands directly: `list`, `get`, `+agenda`, `+triage`, `+read`, `sheets +read`, `--help`, `schema`, `auth status`.

Anything that writes, sends, shares or deletes touches the user's real data or other people's inboxes and cannot always be undone. For those:

1. Show the exact command(s) you plan to run and what they will change.
2. Run them with `--dry-run` first when the command supports it (all helpers do), and show the result.
3. Run for real only after the user approves that specific command.

Email deserves extra care: create a draft (`+send --draft`, `+reply --draft`, or `users drafts create`), show recipients/subject/body, and send only after the user approves that draft. Prefer `trash` over `delete` for messages and files. Never modify or delete calendar events, files, or mail the user did not explicitly name.

If the project you are working in has its own approval rules (for example a CLAUDE.md that requires a command preview), those rules also apply.

## 5. Read the result

| Exit code | Meaning | What to do |
|---|---|---|
| 0 | success | report the result |
| 1 | API error | read the JSON `error.message`; a 403 `accessNotConfigured` means the API is off — open the `enable_url` in the message (or `gcloud services enable <api>`), wait ~10 s, retry |
| 2 | auth error | token missing/expired or scope not granted → `references/setup-auth.md` |
| 3 | validation | bad flag or bad JSON (often PowerShell quoting) |
| 4 | discovery | could not fetch the API schema; check network, retry |
| 5 | internal | rerun with `GOOGLE_WORKSPACE_CLI_LOG=gws=debug` |

Report results in the user's language, briefly: what was found or done, and IDs/links for anything created (Drive files: `https://drive.google.com/file/d/<id>`, Docs: `https://docs.google.com/document/d/<id>`, Sheets: `https://docs.google.com/spreadsheets/d/<id>`).

## 6. Defaults

- Timezone: `GWS_TIMEZONE` in `.env` (Asia/Seoul). Pass `--timezone` to `+agenda`, and RFC3339 times with an offset (`2026-11-21T09:00:00+09:00`) to raw calendar calls.
- Granted scopes (current login): calendar, gmail.modify, drive, spreadsheets. Docs and Slides APIs accept the drive scope. Tasks, People, Chat, Forms, Keep, Meet, Classroom and Apps Script need extra scopes — see `references/setup-auth.md` before using them.
