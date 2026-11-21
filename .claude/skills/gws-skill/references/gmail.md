# Gmail

Granted scope: `gmail.modify` (read, label, draft, send, trash — not permanent delete of the whole mailbox settings). `userId` is always `"me"`.

## Read (run directly)

| Task | Command |
|---|---|
| Unread summary | `gws gmail +triage` (default `is:unread`, 20 rows, table) |
| Search | `gws gmail +triage --query 'from:boss newer_than:7d' --max 10` |
| With labels | `gws gmail +triage --labels` |
| Read one message | `gws gmail +read --id <messageId> --headers` (`--format json` for parsing, `--html` for HTML body) |
| Raw list | `gws gmail users messages list --params '{"userId":"me","q":"has:attachment newer_than:3d","maxResults":10}'` |
| Raw get | `gws gmail users messages get --params '{"userId":"me","id":"<id>","format":"metadata"}'` |
| Thread | `gws gmail users threads get --params '{"userId":"me","id":"<threadId>"}'` |
| Labels | `gws gmail users labels list --params '{"userId":"me"}'` |
| Drafts | `gws gmail users drafts list --params '{"userId":"me"}'` |
| Profile | `gws gmail users getProfile --params '{"userId":"me"}'` |
| Attachment | `gws gmail users messages attachments get --params '{"userId":"me","messageId":"<id>","id":"<attachmentId>"}' --output <file>` |

`q` uses Gmail search syntax: `from:`, `to:`, `subject:`, `is:unread`, `has:attachment`, `newer_than:7d`, `after:2026/11/01`, `label:`.

## Write: draft first, send only after approval

Sending reaches other people and cannot be recalled. Always:

1. Create a draft:
   - New: `gws gmail +send --to a@x.com --subject '<subject>' --body '<body>' --draft`
   - Reply: `gws gmail +reply --message-id <id> --body '<text>' --draft` (`+reply-all` for everyone)
   - Forward: `gws gmail +forward --message-id <id> --to b@x.com --body 'FYI' --draft`
   Options: `--cc`, `--bcc`, `-a <file>` (repeatable, 25 MB total), `--html` (fragment tags only), `--from <alias>`.
2. Show the user: recipients, subject, body preview, draft ID (from the output).
3. After the user approves that draft, send it: `gws gmail users drafts send --json '{"id":"<draftId>"}' --params '{"userId":"me"}'`.

Use `--dry-run` on any helper to see the exact request without sending. Sending without `--draft` is only for when the user explicitly says to send immediately and has seen the content.

## Organise (preview → approval)

| Task | Command |
|---|---|
| Mark read | `gws gmail users messages modify --params '{"userId":"me","id":"<id>"}' --json '{"removeLabelIds":["UNREAD"]}'` |
| Add label | `... modify ... --json '{"addLabelIds":["<labelId>"]}'` |
| Bulk | `gws gmail users messages batchModify --params '{"userId":"me"}' --json '{"ids":[...],"removeLabelIds":["UNREAD"]}'` |
| Trash / restore | `gws gmail users messages trash` / `untrash` with `{"userId":"me","id":"<id>"}` |
| Delete a draft | `gws gmail users drafts delete --params '{"userId":"me","id":"<draftId>"}'` |

Avoid `messages delete` / `batchDelete` (permanent); use `trash`.

`+watch` streams new mail through Pub/Sub and creates Pub/Sub resources in the project — use only on request.
