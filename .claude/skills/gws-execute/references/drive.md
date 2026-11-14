# Drive / Docs / Sheets Reference

Procedure and safety rules for file tasks in the gws-execute skill.

> Commands are not filled in yet. After installing the GWS CLI, verify each command with `gws <command> --help`, record it in `docs/gws-cli-reference.md`, and copy it into the table below.

## Supported tasks

| Task | Typical use | Command (verified) |
|---|---|---|
| Create Docs | Analysis report | TBD |
| Create Sheets | Schedule / task table | TBD |
| Write content | Fill Docs text or Sheets rows | TBD |
| Find / create folder | Save location | TBD |
| Share | Change sharing (explicit approval only) | TBD |

## Procedure

1. **Check the save location.** Use the folder in the task; if none is given, ask the user. Look up the folder ID (read-only).
2. **Check the file name.** Rule: `YYYY-MM-DD_<task name>` (e.g. `2026-11-14_주간일정`). If a file with the same name exists in the folder, ask the user for a new name; never overwrite.
3. **Create** the file in the folder.
4. **Write content.** Sheets: header row + one row per result item. Docs: sections from `templates/report.md`.
5. **Return the link** to the file (and folder).

## Safety rules

- No overwrite, no delete.
- Default sharing scope: private (owner only).
- Any sharing change must appear in the command preview and be explicitly approved.

## Result format

| # | Type | File name | Folder | Link | Result |
|---|---|---|---|---|---|
