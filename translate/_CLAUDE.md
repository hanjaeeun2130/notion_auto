# CLAUDE.md (한글 번역본)

> 원본: `CLAUDE.md` (영문이 기준이며, 이 파일은 사람이 읽기 위한 참고용입니다.)

프로젝트 루트 지침. 매 세션 시작 시 자동으로 로드됩니다.

## 1. 프로젝트 목적

- 트리거 입력으로 Notion DB에 직접 등록합니다.
- Notion DB 분석 → 보고 → 사용자 승인 → GWS CLI로 실행합니다.

## 2. 작업 규칙 (모든 요청에 적용)

### 2.1 todo list 선 보고 후 승인

1. 작업을 시작하기 전에, 요청에 대해 수행할 단계를 **todo list**로 출력합니다.
2. 사용자의 승인을 기다립니다. 승인 전에는 파일 생성·수정·삭제, 외부 서비스 호출, 부작용이 있는 명령 실행을 하지 않습니다.
3. 사용자가 목록을 수정하면, 수정된 목록을 다시 보여주고 다시 승인을 받습니다.
4. 승인 후에는 목록 순서대로 작업하고 각 항목의 결과를 보고합니다.
5. 정확한 todo list 작성에 필요한 읽기 전용 확인(파일 읽기, 폴더 목록 조회)은 승인 전에도 허용됩니다.
6. 트리거 입력(`<키워드> : <내용>`, 4장)과 회사 동기화 요청(`.claude/rules/notion-company.md`)에서는 todo list를 생략합니다. 각 절차의 미리보기와 승인 단계가 이를 대신합니다.

### 2.2 `.md` 파일 작성 언어

- 이 프로젝트의 모든 `.md` 파일은 **영어**로 작성합니다.
- 각 `.md` 파일의 한글 번역본은 `translate/` 폴더에 따로 저장합니다 (2.3 참고).
- 영문 `.md` 파일을 생성하거나 수정할 때마다 같은 작업 안에서 한글 번역본도 생성·갱신합니다. 이 단계를 todo list에 포함합니다.
- `translate/` 의 파일은 사람이 읽기 위한 참고용 사본입니다. 영문 파일이 기준이며, `translate/` 에서 지침을 읽지 않습니다.

### 2.3 `translate/` 폴더 명명 규칙

- `translate/` 에 저장되는 모든 `.md` 파일은 파일 이름 앞에 `_` 를 붙입니다.
- `translate/` 로 옮겨지는 최상위 폴더에도 `_` 를 붙입니다 (맨 앞의 `.` 은 `_` 로 바꿈).
- 최상위 폴더 아래는 원본과 같은 폴더 구조를 유지합니다.

| 원본 | 한글 번역본 |
|---|---|
| `CLAUDE.md` | `translate/_CLAUDE.md` |
| `README.md` | `translate/_README.md` |
| `.claude/` | `translate/_claude/` |
| `.claude/agents/notion-writer.md` | `translate/_claude/agents/_notion-writer.md` |
| `.claude/skills/notion-db-register/SKILL.md` | `translate/_claude/skills/notion-db-register/_SKILL.md` |
| `.claude/skills/gws-execute/references/gmail.md` | `translate/_claude/skills/gws-execute/references/_gmail.md` |
| `docs/approval-policy.md` | `translate/_docs/_approval-policy.md` |
| `templates/report.md` | `translate/_templates/_report.md` |

### 2.4 rules 파일 우선

- `.claude/rules/` 의 규칙(`notion-personal.md`, `notion-work.md`, `notion-study.md`, `notion-company.md`)이 할 일 종류별로 저장할 Notion DB를 정합니다.
- 이 규칙이 이 파일, 스킬, 에이전트, `config/`, `docs/` 와 충돌하면 **rules 파일을 우선**합니다. 충돌을 해결할 때는 어떤 규칙을 적용했는지 알립니다.

## 3. 입력 라우팅 규칙 (가장 먼저 판단)

- 형식: `<키워드> : <내용>`
  - 콜론 앞뒤 공백 허용
  - 전각 콜론 `：` 도 인식
- 등록된 트리거 키워드 → **등록 모드**
- 키워드가 없음 → **분석 모드**
- 콜론 형식이지만 미등록 키워드 → 등록된 키워드 목록을 제시하고 되묻기
- Google 캘린더의 진흥원 일정 가져오기 요청 → 분석 모드가 아니라 **회사 동기화** (`.claude/rules/notion-company.md`)

### 3.1 메모 분류 규칙

사용자가 메모를 입력하면 앞의 키워드로 분류해 Notion에 저장합니다.

| 키워드 | 먼저 읽을 규칙 파일 | 스킬 | 저장 DB |
|---|---|---|---|
| `개인:` | `.claude/rules/notion-personal.md` | `notion-db-register` | Personal Tasks |
| `업무:` | `.claude/rules/notion-work.md` | `notion-db-register` | Work |
| `진흥원:` | `.claude/rules/notion-company.md` | `notion-db-register` | 회사 |
| `메모:` | `.claude/rules/notion-work.md` | `notion-db-register` | Work |
| `배움:` | `.claude/rules/notion-study.md` | `notion-db-register` | Study |

- 스킬을 실행하기 전에 반드시 해당 규칙 파일을 읽음
- 등록 미리보기와 사용자 승인(4장 2단계)은 그대로 적용
- 저장 완료 후 `저장됨: [DB명]` **한 줄만** 출력 (예: `저장됨: Work`). 실패나 오류는 기존대로 자세히 보고

## 4. 등록 모드 절차 (`notion-db-register` 스킬)

1. 입력 내용을 대상 DB 속성(제목·날짜·시간 등)으로 나누고, 기본값을 채우고, 중복 여부 확인
2. 등록 미리보기를 보여주고 사용자 승인을 받음. **승인 없이 등록 금지**
3. `notion-writer` 에이전트: 승인된 값을 키워드에 매핑된 DB에 등록
4. `저장됨: [DB명]` 한 줄만 출력 (3.1 참고). 사용자가 자세한 내용을 요청하거나 등록이 실패한 경우에만 `templates/register-result.md` 양식 사용
5. 입력에 후속 작업이 있으면 승인을 받아 `gws-execute` 스킬로 위임 (5.1)
6. `runs/` 에 실행 기록

## 5. 분석 모드 절차 (`notion-db-analyze` 스킬)

이 모드에서는 Notion에 쓰지 않습니다.

1. `notion-analyst` 에이전트: 날짜·상태·담당자 등으로 DB 필터링·분석 (읽기 전용)
2. `templates/report.md` 양식으로 보고
3. 제안 GWS 작업에 대한 사용자 승인
4. 승인된 작업을 `gws-execute` 스킬로 위임 (5.1)
5. `runs/` 에 실행 기록

### 5.1 GWS 실행 (`gws-execute` 스킬)

1. 작업 종류를 확인하고, 해당하는 `.claude/skills/gws-execute/references/` 문서를 읽고, `gws` 명령 구성
2. 명령 미리보기를 보여주고 사용자 승인을 받음
3. `gws-executor` 에이전트: 승인된 명령 실행. 이 단계에서 메일은 **초안만** 작성
4. 메일 초안(수신자, 제목, 본문 미리보기, 초안 ID)을 보고하고, 초안별 전송 승인(전체 / 번호 선택 / 수정 후 / 거절)을 받음
5. `gws-executor` 에이전트: 승인된 초안만 전송. 수정된 초안은 다시 보여주고 승인받으며, 거절된 초안은 초안으로 보관
6. 결과 링크를 보고하고 `runs/` 에 실행 기록

## 6. 금지사항

- 승인 없는 메일 발송·파일 생성
- 해당 초안에 대한 사용자 승인 없이 메일 전송
- 미리보기에 대한 사용자 승인 없이 Notion 항목 등록·수정·보관
- 승인된 명령 미리보기에 없던 `gws` 명령 실행
- Notion 페이지 삭제 (보관만 허용)

## 7. 참조 파일 위치

| 경로 | 내용 |
|---|---|
| `docs/notion-db-schema.md` | DB별 속성 정의, 필수 입력 항목 *(아직 없음 — `notion-fetch`로 스키마 조회)* |
| `docs/intent-catalog.md` | 분석 모드 요청 유형 → 조회 조건 → GWS 작업 *(아직 없음)* |
| `docs/gws-cli-reference.md` | 직접 확인한 `gws` 명령만 *(아직 없음 — 확인된 `gws` 명령이 없어 GWS 실행 불가)* |
| `docs/approval-policy.md` | 작업별 승인 규칙 *(아직 없음 — 이 파일의 승인 절차를 따름)* |
| `templates/register-result.md` | 등록 결과 보고 양식 *(개요만 있음: `templates/register-result.txt`)* |
| `templates/report.md` | 분석 결과 보고 양식 *(개요만 있음: `templates/report.txt`)* |
| `templates/email/deadline-reminder.md` | 마감 알림 메일 템플릿 *(개요만 있음: `.txt`)* |
| `.claude/agents/` | `notion-writer`, `notion-analyst`, `gws-executor` |
| `.claude/skills/` | `notion-db-register`, `notion-db-analyze`, `gws-execute` |
| `.claude/skills/gws-execute/references/` | `gmail.md`, `drive.md` (GWS 절차와 안전 규칙) |
| `runs/` | 날짜별 실행 기록 (등록·분석·승인·실행) |
| `.claude/rules/` | DB 분류 규칙: 개인 / 업무 / 학습 / 회사 (우선 적용) |
| `translate/` | 모든 `.md` 파일의 한글 번역본 |

## 8. 응답 언어·톤

- 사용자에게는 한글로 응답합니다.
- 간결하게 응답합니다.
