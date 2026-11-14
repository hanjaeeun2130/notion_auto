# Gmail Reference

Procedure and safety rules for email tasks in the gws-execute skill.

> Commands are not filled in yet. After installing the GWS CLI, verify each command with `gws <command> --help`, record it in `docs/gws-cli-reference.md`, and copy it into the table below.

## Supported tasks

| Task | Command (verified) |
|---|---|
| Create draft | TBD |
| Send a draft by ID | TBD |
| Update a draft | TBD |
| List / get drafts | TBD |

## Procedure

1. **Check recipients.** Resolve assignee names with the assignee → email mapping in `docs/notion-db-schema.md`. Unknown names → ask the user.
2. **Fill the template.** Use a template from `templates/email/` when one fits (e.g. `deadline-reminder.md`); otherwise write subject and body from the task content.
3. **Create the draft** (after command preview approval).
4. **Show the draft** for send approval: draft ID, To / Cc, subject, body preview.
5. **Send** only the approved drafts, by draft ID, without changing recipients or content.

## Safety rules

- **External domain:** recipients outside the user's domain, or not in the assignee → email mapping, need one more confirmation before sending.
- **Bulk send:** 10 or more recipients in one email, or 5 or more emails in one task, need one more approval before sending. (Adjust these thresholds here.)
- Never send without draft approval. Never delete drafts.

## Result format

| # | Draft ID | Message ID | To | Subject | Result |
|---|---|---|---|---|---|
