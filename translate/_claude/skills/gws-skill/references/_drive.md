# Drive

부여된 권한: `drive` (사용자 파일 전체 접근).

## 읽기 (바로 실행)

| 작업 | 명령 |
|---|---|
| 최근 파일 | `gws drive files list --params '{"pageSize":10,"orderBy":"modifiedTime desc","fields":"files(id,name,mimeType,modifiedTime,webViewLink)"}'` |
| 이름으로 검색 | `"q":"name contains '보고서' and trashed=false"` 추가 |
| 폴더 안 파일 | `"q":"'<folderId>' in parents and trashed=false"` |
| 폴더만 | `"q":"mimeType='application/vnd.google-apps.folder'"` |
| 시트 / 문서만 | `mimeType='application/vnd.google-apps.spreadsheet'` / `...document'` |
| 파일 정보 | `gws drive files get --params '{"fileId":"<id>","fields":"id,name,mimeType,size,owners,webViewLink"}'` |
| 일반 파일 다운로드 | `gws drive files get --params '{"fileId":"<id>","alt":"media"}' --output <경로>` |
| Google 파일 내보내기 | `gws drive files export --params '{"fileId":"<id>","mimeType":"application/pdf"}' --output <경로>.pdf` (`text/csv`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document`도 가능) |
| 공유 상태 | `gws drive permissions list --params '{"fileId":"<id>"}'` |
| 용량 / 계정 | `gws drive about get --params '{"fields":"user,storageQuota"}'` |
| 공유 드라이브 | `gws drive drives list` |

`q` 조건은 `and`로 묶고, JSON 안의 문자열은 작은따옴표로 감쌉니다.

## 쓰기 (미리보기 → dry-run → 승인)

| 작업 | 명령 |
|---|---|
| 업로드 | `gws drive +upload <로컬경로> [--parent <folderId>] [--name '<이름>']` |
| 폴더 만들기 | `gws drive files create --json '{"name":"<이름>","mimeType":"application/vnd.google-apps.folder","parents":["<parentId>"]}'` |
| 빈 문서/시트 만들기 | `files create --json '{"name":"<이름>","mimeType":"application/vnd.google-apps.document"}'` |
| 복사 | `gws drive files copy --params '{"fileId":"<id>"}' --json '{"name":"<사본 이름>"}'` |
| 이름 변경 | `gws drive files update --params '{"fileId":"<id>"}' --json '{"name":"<새 이름>"}'` |
| 이동 | `files update --params '{"fileId":"<id>","addParents":"<새 폴더>","removeParents":"<기존 폴더>"}'` |
| 휴지통 | `files update --params '{"fileId":"<id>"}' --json '{"trashed":true}'` (`files delete`보다 우선) |
| 공유 | `gws drive permissions create --params '{"fileId":"<id>","sendNotificationEmail":false}' --json '{"role":"reader","type":"user","emailAddress":"a@x.com"}'` |

공유하면 다른 사람이 파일을 볼 수 있게 되고 메일이 갈 수도 있으므로, 미리보기에 권한과 대상을 적으세요. 사용자가 특정 파일의 영구 삭제를 명시적으로 요청하지 않는 한 `files emptyTrash`나 `files delete`는 쓰지 않습니다.

링크: `https://drive.google.com/file/d/<id>/view`, 폴더는 `https://drive.google.com/drive/folders/<id>`.
