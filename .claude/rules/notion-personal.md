# Rule: notion-personal

Save **personal tasks** to the Notion **Personal Tasks** DB.

> Precedence: if this rule conflicts with CLAUDE.md, skills, agents, `config/`, or `docs/`, this rule wins.

## Target

| Item | Value |
|---|---|
| Notion DB | Personal Tasks |
| DB ID | `4194deaa845181f1ad00fda90e18f804` (data source `collection://4194deaa-8451-81ad-93ab-000be1a09c5b`) |
| Properties | 일정 이름 (title), 날짜 (date), 사람 (people), 중요도 (select: 높음/보통/낮음), 위치 (text) |
| Trigger keyword | `개인` |
| Aliases | `사적`, `private` |
| Defaults | 날짜 missing → today |

## What belongs here

Personal to-dos that are not work or study: appointments with friends or family, errands, chores, health, hobbies, personal shopping, personal bills.

Examples:
- `개인 : 친구와 카페 약속 토요일 3시`
- `개인 : 병원 예약 다음 주 화요일`

## Rules

1. Input with the keyword `개인` (or an alias) is saved **only** to Personal Tasks.
2. If the content clearly belongs to another category (e.g. `개인 : 팀 회의 자료 준비`), keep the user's keyword but flag it in the registration preview: "This looks like a work task — save to Work instead?"
3. Registration follows the notion-db-register skill: property split → preview → user approval → notion-writer.
4. Never write a personal task to Work, Study, or 회사 without the user choosing it in the preview.
5. If the Personal Tasks DB does not exist yet, do not register. Tell the user and offer to create it (notion-writer Job A, with approval).
