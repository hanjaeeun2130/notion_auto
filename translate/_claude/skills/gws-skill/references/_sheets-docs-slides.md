# Sheets, Docs, Slides

ID는 URL에 있습니다: `docs.google.com/spreadsheets/d/<ID>/...`, `docs.google.com/document/d/<ID>/...`, `docs.google.com/presentation/d/<ID>/...`. 또는 Drive에서 검색합니다(`references/drive.md`).

권한: Sheets는 `spreadsheets`(부여됨)를 씁니다. Docs와 Slides는 `drive` 권한(부여됨)으로도 동작합니다. 403 권한 부족이 나면 `docs` / `slides`를 추가해 다시 로그인하세요(`setup-auth.md`).

## Sheets

읽기 (바로 실행):

| 작업 | 명령 |
|---|---|
| 범위 읽기 | `gws sheets +read --spreadsheet <ID> --range 'Sheet1!A1:D20'` (탭 전체는 `--range Sheet1`) |
| 제목/탭 목록 | `gws sheets spreadsheets get --params '{"spreadsheetId":"<ID>","fields":"properties.title,sheets.properties(title,sheetId)"}'` |
| 여러 범위 | `gws sheets spreadsheets values batchGet --params '{"spreadsheetId":"<ID>","ranges":["A1:B5","Sheet2!A:A"]}'` |

쓰기 (미리보기 → dry-run → 승인):

| 작업 | 명령 |
|---|---|
| 한 행 추가 | `gws sheets +append --spreadsheet <ID> --values '홍길동,100,완료'` |
| 여러 행 추가 | `gws sheets +append --spreadsheet <ID> --json-values '[["a","b"],["c","d"]]'` |
| 셀 덮어쓰기 | `gws sheets spreadsheets values update --params '{"spreadsheetId":"<ID>","range":"Sheet1!B2","valueInputOption":"USER_ENTERED"}' --json '{"values":[["new"]]}'` |
| 범위 지우기 | `gws sheets spreadsheets values clear --params '{"spreadsheetId":"<ID>","range":"Sheet1!A2:D"}'` |
| 새 스프레드시트 | `gws sheets spreadsheets create --json '{"properties":{"title":"<제목>"}}'` |
| 탭 추가 / 서식 | `gws sheets spreadsheets batchUpdate --params '{"spreadsheetId":"<ID>"}' --json '{"requests":[{"addSheet":{"properties":{"title":"New"}}}]}'` |

`+append`는 첫 번째 탭의 마지막 데이터 행 아래에 씁니다. 값이 열과 맞도록 머리글 행을 먼저 읽으세요. `--values`는 쉼표로 나누므로, 값에 쉼표가 있으면 `--json-values`를 쓰세요. `USER_ENTERED`는 화면에서 입력하듯 날짜와 수식을 해석하고, `RAW`는 텍스트 그대로 저장합니다.

## Docs

| 작업 | 명령 | 종류 |
|---|---|---|
| 읽기 | `gws docs documents get --params '{"documentId":"<ID>"}'` (본문은 `body.content[].paragraph.elements[].textRun.content`) | 읽기 |
| 일반 텍스트 | `gws drive files export --params '{"fileId":"<ID>","mimeType":"text/plain"}' --output doc.txt` | 읽기 |
| 만들기 | `gws docs documents create --json '{"title":"<제목>"}'` | 쓰기 |
| 텍스트 덧붙이기 | `gws docs +write --document <ID> --text '<내용>'` | 쓰기 |
| 삽입 / 치환 / 서식 | `gws docs documents batchUpdate --params '{"documentId":"<ID>"}' --json '{"requests":[{"replaceAllText":{"containsText":{"text":"{{name}}","matchCase":true},"replaceText":"홍길동"}}]}'` | 쓰기 |

`+write`는 문서 끝에 일반 텍스트만 붙입니다. 그 밖의 작업은 `batchUpdate`(`location.index`를 지정한 `insertText`, `replaceAllText`, `updateTextStyle`)를 쓰세요.

## Slides

| 작업 | 명령 | 종류 |
|---|---|---|
| 읽기 | `gws slides presentations get --params '{"presentationId":"<ID>"}'` | 읽기 |
| 만들기 | `gws slides presentations create --json '{"title":"<제목>"}'` | 쓰기 |
| 편집 | `gws slides presentations batchUpdate --params '{"presentationId":"<ID>"}' --json '{"requests":[...]}'` (`createSlide`, `insertText`, `replaceAllText`) | 쓰기 |

요청 형식은 `gws schema slides.presentations.batchUpdate`(docs/sheets도 마찬가지)로 확인합니다.
