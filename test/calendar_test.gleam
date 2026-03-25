import caldav/internal/xml_request
import caldav/internal/xml_response
import gleam/list
import gleam/option
import gleam/string

pub fn parse_calendars_filters_non_calendar_collections_test() {
  let assert Ok(calendars) = xml_response.parse_calendars(list_calendars_fixture())

  assert list.length(calendars) == 2

  let assert [work, personal] = calendars

  assert work.url == "/dav/calendars/demo/work/"
  assert work.display_name == "Work"
  assert work.description == option.Some("Work calendar")
  assert work.ctag == option.Some("work-ctag-1")

  assert personal.url == "/dav/calendars/demo/personal/"
  assert personal.display_name == "Personal"
  assert personal.description == option.Some("Personal events")
  assert personal.ctag == option.Some("personal-ctag-7")
}

pub fn propfind_list_calendars_body_contains_required_tags_test() {
  let body = xml_request.propfind_list_calendars()

  assert string.contains(body, "<d:displayname />")
  assert string.contains(body, "<c:calendar-description />")
  assert string.contains(body, "<cs:getctag />")
  assert string.contains(body, "<d:resourcetype />")
}

fn list_calendars_fixture() -> String {
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  <> "<d:multistatus xmlns:d=\"DAV:\" xmlns:c=\"urn:ietf:params:xml:ns:caldav\" xmlns:cs=\"http://calendarserver.org/ns/\">\n"
  <> "  <d:response>\n"
  <> "    <d:href>/dav/calendars/demo/</d:href>\n"
  <> "    <d:propstat>\n"
  <> "      <d:prop>\n"
  <> "        <d:displayname>Calendar Home</d:displayname>\n"
  <> "        <d:resourcetype><d:collection /></d:resourcetype>\n"
  <> "      </d:prop>\n"
  <> "      <d:status>HTTP/1.1 200 OK</d:status>\n"
  <> "    </d:propstat>\n"
  <> "  </d:response>\n"
  <> "  <d:response>\n"
  <> "    <d:href>/dav/calendars/demo/work/</d:href>\n"
  <> "    <d:propstat>\n"
  <> "      <d:prop>\n"
  <> "        <d:displayname>Work</d:displayname>\n"
  <> "        <c:calendar-description>Work calendar</c:calendar-description>\n"
  <> "        <cs:getctag>work-ctag-1</cs:getctag>\n"
  <> "        <d:resourcetype><d:collection /><c:calendar /></d:resourcetype>\n"
  <> "      </d:prop>\n"
  <> "      <d:status>HTTP/1.1 200 OK</d:status>\n"
  <> "    </d:propstat>\n"
  <> "  </d:response>\n"
  <> "  <d:response>\n"
  <> "    <d:href>/dav/calendars/demo/personal/</d:href>\n"
  <> "    <d:propstat>\n"
  <> "      <d:prop>\n"
  <> "        <d:displayname>Personal</d:displayname>\n"
  <> "        <c:calendar-description>Personal events</c:calendar-description>\n"
  <> "        <cs:getctag>personal-ctag-7</cs:getctag>\n"
  <> "        <d:resourcetype><d:collection /><c:calendar /></d:resourcetype>\n"
  <> "      </d:prop>\n"
  <> "      <d:status>HTTP/1.1 200 OK</d:status>\n"
  <> "    </d:propstat>\n"
  <> "  </d:response>\n"
  <> "</d:multistatus>\n"
}
