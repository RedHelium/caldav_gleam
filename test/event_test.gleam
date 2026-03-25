import caldav/internal/xml_request
import caldav/internal/xml_response
import caldav/types
import gleam/list
import gleam/option
import gleam/string

pub fn parse_calendar_query_extracts_events_test() {
  let assert Ok(events) =
    xml_response.parse_calendar_query(calendar_query_fixture())

  assert list.length(events) == 2

  let assert [first, second] = events

  assert first.href == "/dav/calendars/demo/work/event-1.ics"
  assert first.etag == option.Some("\"event-1-etag\"")
  assert first.content_type
    == option.Some("text/calendar; charset=utf-8; component=VEVENT")
  assert string.contains(first.calendar_data, "UID:event-1")

  assert second.href == "/dav/calendars/demo/work/event-2.ics"
  assert second.etag == option.Some("\"event-2-etag\"")
  assert second.content_type
    == option.Some("text/calendar; charset=utf-8; component=VEVENT")
  assert string.contains(second.calendar_data, "UID:event-2")
}

pub fn report_calendar_query_all_contains_required_filter_test() {
  let body = xml_request.report_calendar_query_all()

  assert string.contains(body, "<c:calendar-query")
  assert string.contains(body, "<c:comp-filter name=\"VCALENDAR\">")
  assert string.contains(body, "<c:comp-filter name=\"VEVENT\" />")
  assert string.contains(body, "<c:calendar-data />")
}

pub fn report_calendar_query_range_serializes_bounds_test() {
  let body =
    xml_request.report_calendar_query_range(types.TimeRange(
      start: 1700,
      end: 1800,
    ))

  assert string.contains(body, "<c:time-range start=\"1700\" end=\"1800\" />")
}

fn calendar_query_fixture() -> String {
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  <> "<d:multistatus xmlns:d=\"DAV:\" xmlns:c=\"urn:ietf:params:xml:ns:caldav\">\n"
  <> "  <d:response>\n"
  <> "    <d:href>/dav/calendars/demo/work/event-1.ics</d:href>\n"
  <> "    <d:propstat>\n"
  <> "      <d:prop>\n"
  <> "        <d:getetag>\"event-1-etag\"</d:getetag>\n"
  <> "        <d:getcontenttype>text/calendar; charset=utf-8; component=VEVENT</d:getcontenttype>\n"
  <> "        <c:calendar-data>BEGIN:VCALENDAR\n"
  <> "VERSION:2.0\n"
  <> "PRODID:-//caldav_gleam//EN\n"
  <> "BEGIN:VEVENT\n"
  <> "UID:event-1\n"
  <> "DTSTAMP:20260325T010000Z\n"
  <> "DTSTART:20260326T090000Z\n"
  <> "DTEND:20260326T100000Z\n"
  <> "SUMMARY:Project sync\n"
  <> "END:VEVENT\n"
  <> "END:VCALENDAR</c:calendar-data>\n"
  <> "      </d:prop>\n"
  <> "      <d:status>HTTP/1.1 200 OK</d:status>\n"
  <> "    </d:propstat>\n"
  <> "  </d:response>\n"
  <> "  <d:response>\n"
  <> "    <d:href>/dav/calendars/demo/work/event-2.ics</d:href>\n"
  <> "    <d:propstat>\n"
  <> "      <d:prop>\n"
  <> "        <d:getetag>\"event-2-etag\"</d:getetag>\n"
  <> "        <d:getcontenttype>text/calendar; charset=utf-8; component=VEVENT</d:getcontenttype>\n"
  <> "        <c:calendar-data>BEGIN:VCALENDAR\n"
  <> "VERSION:2.0\n"
  <> "PRODID:-//caldav_gleam//EN\n"
  <> "BEGIN:VEVENT\n"
  <> "UID:event-2\n"
  <> "DTSTAMP:20260325T020000Z\n"
  <> "DTSTART:20260327T120000Z\n"
  <> "DTEND:20260327T130000Z\n"
  <> "SUMMARY:Lunch with team\n"
  <> "END:VEVENT\n"
  <> "END:VCALENDAR</c:calendar-data>\n"
  <> "      </d:prop>\n"
  <> "      <d:status>HTTP/1.1 200 OK</d:status>\n"
  <> "    </d:propstat>\n"
  <> "  </d:response>\n"
  <> "</d:multistatus>\n"
}
