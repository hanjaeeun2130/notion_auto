# Sheets, Docs, Slides

IDs come from the URL: `docs.google.com/spreadsheets/d/<ID>/...`, `docs.google.com/document/d/<ID>/...`, `docs.google.com/presentation/d/<ID>/...`. Or search Drive (`references/drive.md`).

Scopes: Sheets uses `spreadsheets` (granted). Docs and Slides accept the `drive` scope (granted); if a call fails with 403 insufficient scopes, re-login adding `docs` / `slides` (see `setup-auth.md`).

## Sheets

Read (run directly):

| Task | Command |
|---|---|
| Read a range | `gws sheets +read --spreadsheet <ID> --range 'Sheet1!A1:D20'` (or `--range Sheet1` for the whole tab) |
| Sheet titles/tabs | `gws sheets spreadsheets get --params '{"spreadsheetId":"<ID>","fields":"properties.title,sheets.properties(title,sheetId)"}'` |
| Several ranges | `gws sheets spreadsheets values batchGet --params '{"spreadsheetId":"<ID>","ranges":["A1:B5","Sheet2!A:A"]}'` |

Write (preview → dry-run → approval):

| Task | Command |
|---|---|
| Append one row | `gws sheets +append --spreadsheet <ID> --values '홍길동,100,완료'` |
| Append many rows | `gws sheets +append --spreadsheet <ID> --json-values '[["a","b"],["c","d"]]'` |
| Overwrite cells | `gws sheets spreadsheets values update --params '{"spreadsheetId":"<ID>","range":"Sheet1!B2","valueInputOption":"USER_ENTERED"}' --json '{"values":[["new"]]}'` |
| Clear range | `gws sheets spreadsheets values clear --params '{"spreadsheetId":"<ID>","range":"Sheet1!A2:D"}'` |
| New spreadsheet | `gws sheets spreadsheets create --json '{"properties":{"title":"<title>"}}'` |
| Add tab / format | `gws sheets spreadsheets batchUpdate --params '{"spreadsheetId":"<ID>"}' --json '{"requests":[{"addSheet":{"properties":{"title":"New"}}}]}'` |

`+append` writes to the first tab after the last row with data; read the header row first so the values line up with the columns. `--values` splits on commas, so use `--json-values` when a value contains a comma. `USER_ENTERED` parses dates and formulas like typing in the UI; `RAW` stores text as is.

## Docs

| Task | Command | Kind |
|---|---|---|
| Read | `gws docs documents get --params '{"documentId":"<ID>"}'` (text is under `body.content[].paragraph.elements[].textRun.content`) | read |
| Plain text | `gws drive files export --params '{"fileId":"<ID>","mimeType":"text/plain"}' --output doc.txt` | read |
| Create | `gws docs documents create --json '{"title":"<title>"}'` | write |
| Append text | `gws docs +write --document <ID> --text '<text>'` | write |
| Insert / replace / style | `gws docs documents batchUpdate --params '{"documentId":"<ID>"}' --json '{"requests":[{"replaceAllText":{"containsText":{"text":"{{name}}","matchCase":true},"replaceText":"홍길동"}}]}'` | write |

`+write` appends plain text at the end; use `batchUpdate` (`insertText` with a `location.index`, `replaceAllText`, `updateTextStyle`) for anything else.

## Slides

| Task | Command | Kind |
|---|---|---|
| Read | `gws slides presentations get --params '{"presentationId":"<ID>"}'` | read |
| Create | `gws slides presentations create --json '{"title":"<title>"}'` | write |
| Edit | `gws slides presentations batchUpdate --params '{"presentationId":"<ID>"}' --json '{"requests":[...]}'` (`createSlide`, `insertText`, `replaceAllText`) | write |

Use `gws schema slides.presentations.batchUpdate` (or docs/sheets equivalents) to look up request shapes.
