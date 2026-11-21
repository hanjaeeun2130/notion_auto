# Drive

Granted scope: `drive` (full access to the user's files).

## Read (run directly)

| Task | Command |
|---|---|
| Recent files | `gws drive files list --params '{"pageSize":10,"orderBy":"modifiedTime desc","fields":"files(id,name,mimeType,modifiedTime,webViewLink)"}'` |
| Search by name | add `"q":"name contains '보고서' and trashed=false"` |
| Files in a folder | `"q":"'<folderId>' in parents and trashed=false"` |
| Only folders | `"q":"mimeType='application/vnd.google-apps.folder'"` |
| Only Sheets / Docs | `mimeType='application/vnd.google-apps.spreadsheet'` / `...document'` |
| File metadata | `gws drive files get --params '{"fileId":"<id>","fields":"id,name,mimeType,size,owners,webViewLink"}'` |
| Download binary | `gws drive files get --params '{"fileId":"<id>","alt":"media"}' --output <path>` |
| Export Google file | `gws drive files export --params '{"fileId":"<id>","mimeType":"application/pdf"}' --output <path>.pdf` (also `text/csv`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document`) |
| Sharing | `gws drive permissions list --params '{"fileId":"<id>"}'` |
| Storage / account | `gws drive about get --params '{"fields":"user,storageQuota"}'` |
| Shared drives | `gws drive drives list` |

Combine `q` terms with `and`; quote strings with single quotes inside the JSON.

## Write (preview → dry-run → approval)

| Task | Command |
|---|---|
| Upload | `gws drive +upload <localPath> [--parent <folderId>] [--name '<name>']` |
| Create folder | `gws drive files create --json '{"name":"<name>","mimeType":"application/vnd.google-apps.folder","parents":["<parentId>"]}'` |
| Create empty Doc/Sheet | `files create --json '{"name":"<name>","mimeType":"application/vnd.google-apps.document"}'` |
| Copy | `gws drive files copy --params '{"fileId":"<id>"}' --json '{"name":"<copy name>"}'` |
| Rename | `gws drive files update --params '{"fileId":"<id>"}' --json '{"name":"<new>"}'` |
| Move | `files update --params '{"fileId":"<id>","addParents":"<new>","removeParents":"<old>"}'` |
| Trash | `files update --params '{"fileId":"<id>"}' --json '{"trashed":true}'` (prefer over `files delete`) |
| Share | `gws drive permissions create --params '{"fileId":"<id>","sendNotificationEmail":false}' --json '{"role":"reader","type":"user","emailAddress":"a@x.com"}'` |

Sharing exposes the file to someone else (and may email them) — state the role and recipient in the preview. Never use `files emptyTrash` or `files delete` unless the user explicitly asks for permanent deletion of named files.

Links: `https://drive.google.com/file/d/<id>/view`, folders `https://drive.google.com/drive/folders/<id>`.
