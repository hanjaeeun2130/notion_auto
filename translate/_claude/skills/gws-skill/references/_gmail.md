# Gmail

부여된 권한: `gmail.modify` (읽기, 라벨, 초안, 발송, 휴지통 — 메일함 설정 영구 삭제는 아님). `userId`는 항상 `"me"`입니다.

## 읽기 (바로 실행)

| 작업 | 명령 |
|---|---|
| 안 읽은 메일 요약 | `gws gmail +triage` (기본 `is:unread`, 20건, 표) |
| 검색 | `gws gmail +triage --query 'from:boss newer_than:7d' --max 10` |
| 라벨 포함 | `gws gmail +triage --labels` |
| 메일 하나 읽기 | `gws gmail +read --id <messageId> --headers` (파싱용은 `--format json`, HTML 본문은 `--html`) |
| 원본 API 목록 | `gws gmail users messages list --params '{"userId":"me","q":"has:attachment newer_than:3d","maxResults":10}'` |
| 원본 API 조회 | `gws gmail users messages get --params '{"userId":"me","id":"<id>","format":"metadata"}'` |
| 스레드 | `gws gmail users threads get --params '{"userId":"me","id":"<threadId>"}'` |
| 라벨 | `gws gmail users labels list --params '{"userId":"me"}'` |
| 초안 | `gws gmail users drafts list --params '{"userId":"me"}'` |
| 프로필 | `gws gmail users getProfile --params '{"userId":"me"}'` |
| 첨부파일 | `gws gmail users messages attachments get --params '{"userId":"me","messageId":"<id>","id":"<attachmentId>"}' --output <파일>` |

`q`는 Gmail 검색 문법을 씁니다: `from:`, `to:`, `subject:`, `is:unread`, `has:attachment`, `newer_than:7d`, `after:2026/11/01`, `label:`.

## 쓰기: 초안 먼저, 승인 후 발송

발송한 메일은 다른 사람에게 닿고 되돌릴 수 없습니다. 항상 다음 순서를 따릅니다.

1. 초안 만들기:
   - 새 메일: `gws gmail +send --to a@x.com --subject '<제목>' --body '<본문>' --draft`
   - 답장: `gws gmail +reply --message-id <id> --body '<내용>' --draft` (전체 답장은 `+reply-all`)
   - 전달: `gws gmail +forward --message-id <id> --to b@x.com --body 'FYI' --draft`
   옵션: `--cc`, `--bcc`, `-a <파일>`(여러 번 가능, 합계 25MB), `--html`(조각 태그만), `--from <별칭>`.
2. 사용자에게 받는 사람, 제목, 본문 미리보기, 초안 ID(출력에서 확인)를 보여줍니다.
3. 사용자가 그 초안을 승인하면 발송합니다: `gws gmail users drafts send --json '{"id":"<draftId>"}' --params '{"userId":"me"}'`.

헬퍼에 `--dry-run`을 붙이면 보내지 않고 실제 요청 내용만 볼 수 있습니다. `--draft` 없이 바로 보내는 건 사용자가 내용을 보고 즉시 보내라고 명시했을 때만 합니다.

## 정리 (미리보기 → 승인)

| 작업 | 명령 |
|---|---|
| 읽음 표시 | `gws gmail users messages modify --params '{"userId":"me","id":"<id>"}' --json '{"removeLabelIds":["UNREAD"]}'` |
| 라벨 추가 | `... modify ... --json '{"addLabelIds":["<labelId>"]}'` |
| 일괄 처리 | `gws gmail users messages batchModify --params '{"userId":"me"}' --json '{"ids":[...],"removeLabelIds":["UNREAD"]}'` |
| 휴지통 / 복원 | `gws gmail users messages trash` / `untrash`, 파라미터 `{"userId":"me","id":"<id>"}` |
| 초안 삭제 | `gws gmail users drafts delete --params '{"userId":"me","id":"<draftId>"}'` |

`messages delete` / `batchDelete`(영구 삭제)는 피하고 `trash`를 쓰세요.

`+watch`는 Pub/Sub로 새 메일을 실시간 수신하며 프로젝트에 Pub/Sub 리소스를 만듭니다. 요청이 있을 때만 쓰세요.
