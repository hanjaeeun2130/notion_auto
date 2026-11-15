# Rule: notion-study

Save **study-related tasks** to the Notion **Study** DB.

> Precedence: if this rule conflicts with CLAUDE.md, skills, agents, `config/`, or `docs/`, this rule wins.

## Target

| Item | Value |
|---|---|
| Notion DB | Study |
| DB ID | `4194deaa8451816db06debcef56c190a` (data source `collection://4194deaa-8451-81a5-8ce9-000ba4f668cf`) |
| Properties | 학습주제 (title), 마감일 (date), 요약 (text) |
| Trigger keyword | `학습` |
| Aliases | `공부`, `study`, `배움` |
| Defaults | 마감일 missing → today |

## What belongs here

Learning to-dos: lectures, courses, assignments, exams, certifications, reading, practice, study groups.

Examples:
- `학습 : 파이썬 강의 3강 수강 오늘`
- `공부 : 정보처리기사 필기 시험 12/7`

## Rules

1. Input with the keyword `학습` (or an alias) is saved **only** to Study.
2. If the content clearly belongs to another category, keep the user's keyword but flag it in the preview.
3. Registration follows the notion-db-register skill: property split → preview → user approval → notion-writer.
4. If the Study DB does not exist yet, do not register. Tell the user and offer to create it (notion-writer Job A, with approval).
