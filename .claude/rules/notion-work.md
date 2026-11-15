# Rule: notion-work

Save **work-related tasks** to the Notion **Work** DB.

> Precedence: if this rule conflicts with CLAUDE.md, skills, agents, `config/`, or `docs/`, this rule wins.

## Target

| Item | Value |
|---|---|
| Notion DB | Work |
| DB ID | `4194deaa845181cfa46de46f748aa6f8` (data source `collection://4194deaa-8451-815b-bcaa-000ba17a90f5`) |
| Properties | 업무 이름 (title), 등록 날짜 (date), 마감일 (date), 공동작업자 (people), 전송메일 (email), 중요도 (select: 높음/보통/낮음) |
| Trigger keyword | `업무` |
| Aliases | `일`, `work`, `메모` |
| Defaults | 등록 날짜 missing → today; a date given in the input goes to 마감일 |

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
