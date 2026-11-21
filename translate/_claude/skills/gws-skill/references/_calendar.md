# Calendar

시간은 오프셋을 포함한 RFC3339 형식입니다. 예: `2026-11-21T09:00:00+09:00`. 기본 시간대: `GWS_TIMEZONE`(Asia/Seoul).

## 읽기 (바로 실행)

| 작업 | 명령 |
|---|---|
| 오늘 / 내일 / 이번 주 | `gws calendar +agenda --today` · `--tomorrow` · `--week` (`--timezone Asia/Seoul --format table` 추가) |
| 앞으로 N일 | `gws calendar +agenda --days 30` |
| 특정 캘린더만 | `gws calendar +agenda --days 7 --calendar '진흥원(한재은)'` (이름 또는 ID) |
| 캘린더 목록 | `gws calendar calendarList list --params '{"fields":"items(id,summary,accessRole)"}'` |
| 기간 내 이벤트 | `gws calendar events list --params '{"calendarId":"<ID>","timeMin":"<시작>","timeMax":"<끝>","singleEvents":true,"orderBy":"startTime"}'` |
| 키워드 검색 | `events list`에 `"q":"<단어>"` 추가 (제목, 설명, 장소, 참석자) |
| 이벤트 하나 | `gws calendar events get --params '{"calendarId":"<ID>","eventId":"<eventId>"}'` |
| 반복 일정의 회차 | `gws calendar events instances --params '{"calendarId":"<ID>","eventId":"<eventId>"}'` |
| 빈 시간 조회 | `gws calendar freebusy query --json '{"timeMin":"<시작>","timeMax":"<끝>","items":[{"id":"primary"}]}'` |

`+agenda`는 사용자가 구독한 모든 캘린더를 조회하며 읽기 전용입니다. 전체 필드(id, 설명, 참석자)나 캘린더 ID가 필요하면 `events list`를 쓰세요. `"fields":"items(id,summary,location,start,end)"`로 출력을 줄이고, 기간이 길면 `--page-all`을 붙입니다.

팁: 업무 일정을 별도 캘린더에 두고, 일정 제목에는 기관 이름을 쓰지 않는 경우가 있습니다. `q`만 쓰지 말고 캘린더 기준으로 찾으세요(캘린더 목록부터 조회).

## 쓰기 (미리보기 → dry-run → 승인)

| 작업 | 명령 |
|---|---|
| 일정 만들기 | `gws calendar +insert --summary '<제목>' --start '<시작>' --end '<끝>' [--location '<장소>'] [--description '<내용>'] [--attendee a@x.com] [--meet] [--calendar <ID>]` |
| 문장으로 빠르게 추가 | `gws calendar events quickAdd --params '{"calendarId":"primary","text":"Lunch with Kim tomorrow 12pm"}'` |
| 일부 필드 수정 | `gws calendar events patch --params '{"calendarId":"<ID>","eventId":"<id>"}' --json '{"location":"Room 3"}'` |
| 다른 캘린더로 이동 | `gws calendar events move --params '{"calendarId":"<원래>","eventId":"<id>","destination":"<대상>"}'` |
| 삭제 | `gws calendar events delete --params '{"calendarId":"<ID>","eventId":"<id>"}'` — 명시적으로 요청할 때만 |

`--attendee`를 넣으면 그 사람들에게 초대장이 가므로 미리보기에서 알려주세요. 종일 일정은 `--json` 본문에서 `dateTime` 대신 `{"date":"2026-11-25"}`를 씁니다.

## 예시

"이번 주 진흥원 일정 보여줘":
```
bash scripts/gws.sh calendar calendarList list --params '{"fields":"items(id,summary)"}' 2>/dev/null   # 진흥원(...) 캘린더 찾기
bash scripts/gws.sh calendar +agenda --week --calendar '진흥원(한재은)' --timezone Asia/Seoul --format table 2>/dev/null
```
해당하는 캘린더마다 `+agenda`를 반복하거나(또는 `+agenda --week` 결과에서 `calendar`가 `진흥원`으로 시작하는 행만 골라), 날짜·시간·제목·장소·캘린더로 합친 표 하나로 보여줍니다.
