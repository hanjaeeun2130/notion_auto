# Rule: notion-work

Save **work-related tasks** to the Notion **Work** DB.

> Precedence: if this rule conflicts with CLAUDE.md, skills, agents, `config/`, or `docs/`, this rule wins.

## Target

| Item | Value |
|---|---|
| Notion DB | Work |
| DB ID | (fill in after the DB is created or found) |
| Trigger keyword | `업무` |
| Aliases | `일`, `work` |
| Defaults | Status = 진행 전; date missing → today |

## What belongs here

Work to-dos: meetings, reports, deadlines, submissions, client contact, project tasks.

Examples:
- `업무 : 기획안 제출 11/20 마감`
- `업무 : 주간회의 내일 오전 10시`

## Rules

1. Input with the keyword `업무` (or an alias) is saved **only** to Work.
2. Schedules related to **진흥원** that come from Google Calendar belong to the 회사 DB (see `notion-company.md`), not Work. If a `업무` input mentions 진흥원, flag it in the preview: "This looks like a 진흥원 schedule — save to 회사 instead?"
3. If the content clearly belongs to another category, keep the user's keyword but flag it in the preview.
4. Registration follows the notion-db-register skill: property split → preview → user approval → notion-writer.
5. If the Work DB does not exist yet, do not register. Tell the user and offer to create it (notion-writer Job A, with approval).
