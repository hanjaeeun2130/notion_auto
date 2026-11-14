> 원본: `.claude/skills/gws-execute/SKILL.md` (영문이 기준이며, 이 파일은 사람이 읽기 위한 참고용입니다.)

---
name: gws-execute
description: 승인된 후속 작업(Gmail, Docs, Sheets, Drive)을 GWS CLI로 실행. 사용자가 notion-db-analyze 또는 notion-db-register 의 GWS 작업을 승인한 뒤 사용. 작업 종류를 확인하고, 맞는 references/ 문서를 읽고, gws 명령을 구성한 뒤, 명령 미리보기를 보여주고 사용자가 승인해야만 gws-executor 서브 에이전트로 실행. 메일은 초안 먼저, 초안 승인 후 전송. 결과 링크를 보고.
---

# gws-execute

승인된 후속 작업을 GWS CLI로 실행합니다.

**명령 미리보기에 대한 사용자 승인 없이는 어떤 `gws` 명령도 실행하지 않습니다.**

## 참조

- `references/gmail.md` — 메일 초안·전송 절차와 안전 규칙
- `references/drive.md` — Drive / Docs / Sheets 절차와 안전 규칙
- `docs/gws-cli-reference.md` — 확인된 `gws` 명령
- `docs/approval-policy.md` — 승인 범위와 고위험 규칙
- `templates/email/` — 메일 템플릿 (예: `deadline-reminder.md`)
- `.claude/agents/gws-executor.md` — 명령을 실행하는 서브 에이전트

## 입력

notion-db-analyze 또는 notion-db-register 에서 승인된 작업. 각 작업에는 작업 번호, 유형, 대상, 내용 또는 원본 데이터, 승인 메모가 있습니다.

## 절차

### 1. 작업 종류 확인

| 종류 | 참고 문서 |
|---|---|
| 메일 (초안 / 전송) | `references/gmail.md` |
| Docs / Sheets / Drive (폴더, 공유) | `references/drive.md` |
| 기타 | 참고 문서 없음 → `docs/gws-cli-reference.md` 만 사용 |

### 2. 참고 문서를 읽고 명령 구성

1. 해당하는 `references/` 문서가 있으면 읽고, `docs/gws-cli-reference.md` 도 읽음
2. 작업마다 `gws` 명령을 구성:
   - 참고 문서나 `docs/gws-cli-reference.md` 에 있는 명령만 사용
   - 목록에 없는 명령은 사용 전에 `gws <command> --help`(읽기 전용)로 확인하고, 옵션을 추측하지 않음
   - 맞는 템플릿이 있으면 `templates/email/` 로 메일 본문 작성
   - `references/drive.md` 의 파일 이름·공유 규칙을 따름
3. 필수 정보(수신자, 파일 이름, 폴더, 내용)가 없으면 미리보기 전에 사용자에게 물어봄

### 3. 명령 미리보기 후 승인 받기

```
[명령 미리보기]
| # | 작업 | 대상 | 명령 |
|---|---|---|---|
| 1 | 메일 초안: 마감 알림 | kim@example.com | gws ... |
| 2 | Sheets: 2026-11-14_주간일정 | 내 드라이브/일정 | gws ... |
고위험: (외부 수신자, 대량 발송, 공유 변경)
참고: 메일은 초안만 만들며, 전송은 두 번째 승인이 필요합니다.
→ 전체 승인 / 번호 선택 / 수정 후 / 거절
```

- **수정** → 명령을 다시 구성하고 미리보기를 다시 보여줌
- **거절** → 실행하지 않음. 중단

### 4. gws-executor로 실행

승인된 명령을 미리보기 그대로(작업 번호, 유형, 대상, 명령, 승인 메모) `gws-executor` 서브 에이전트에 넘겨 호출합니다.

### 5. 메일: 초안 승인 후 전송

1. gws-executor가 생성된 초안(초안 ID, 수신자, 제목, 본문 미리보기)을 반환
2. 초안과 전송 명령 미리보기를 보여주고 초안별 승인(전체 / 번호 선택 / 수정 후 / 거절)을 받음
3. 승인된 초안 → gws-executor를 호출해 전송. 수정된 초안 → 고친 뒤 다시 보여줌. 거절된 초안 → 초안으로 보관

### 6. 결과 보고

작업별 결과(성공 / 실패 / 건너뜀 / 초안 생성 / 전송됨 / 초안으로 보관)와 **결과 링크**(파일·폴더 링크, 초안 ID, 메시지 ID). 오류와 해결 방법도 포함

### 7. 기록

`runs/` 에 기록: 시각, 출처(analyze / register), 명령 미리보기, 승인, 실행한 명령, 결과, 링크·ID

## 제약

- 이 스킬에서 `gws` 명령을 직접 실행하지 않음 (읽기 전용 `--help` / `--version` 확인 제외). 실행은 gws-executor를 통해서만
- 승인된 작업만, 미리보기에 보여준 명령만 실행
- 해당 초안의 승인 없이 메일 전송 금지
- 파일·초안 삭제 금지, 파일 덮어쓰기 금지, 명시적 승인 없이 공유 변경 금지
