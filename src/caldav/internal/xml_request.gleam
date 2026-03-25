import caldav/types
import gleam/int

/// Builds a PROPFIND body that asks for the current user principal.
pub fn propfind_current_user_principal() -> String {
  "<d:propfind xmlns:d=\"DAV:\">"
  <> "<d:prop>"
  <> "<d:current-user-principal />"
  <> "</d:prop>"
  <> "</d:propfind>"
}

/// Builds a PROPFIND body that asks for the calendar home set of a principal.
pub fn propfind_calendar_home_set() -> String {
  "<d:propfind xmlns:d=\"DAV:\" xmlns:c=\"urn:ietf:params:xml:ns:caldav\">"
  <> "<d:prop>"
  <> "<c:calendar-home-set />"
  <> "</d:prop>"
  <> "</d:propfind>"
}

/// Builds a PROPFIND body that asks for the core properties of calendar collections.
pub fn propfind_list_calendars() -> String {
  "<d:propfind"
  <> " xmlns:d=\"DAV:\""
  <> " xmlns:c=\"urn:ietf:params:xml:ns:caldav\""
  <> " xmlns:cs=\"http://calendarserver.org/ns/\">"
  <> "<d:prop>"
  <> "<d:displayname />"
  <> "<c:calendar-description />"
  <> "<cs:getctag />"
  <> "<d:resourcetype />"
  <> "</d:prop>"
  <> "</d:propfind>"
}

/// Builds a REPORT body that asks for all VEVENT resources in a calendar.
pub fn report_calendar_query_all() -> String {
  "<c:calendar-query xmlns:d=\"DAV:\" xmlns:c=\"urn:ietf:params:xml:ns:caldav\">"
  <> "<d:prop>"
  <> "<d:getetag />"
  <> "<d:getcontenttype />"
  <> "<c:calendar-data />"
  <> "</d:prop>"
  <> "<c:filter>"
  <> "<c:comp-filter name=\"VCALENDAR\">"
  <> "<c:comp-filter name=\"VEVENT\" />"
  <> "</c:comp-filter>"
  <> "</c:filter>"
  <> "</c:calendar-query>"
}

/// Builds a REPORT body that asks for VEVENT resources inside a time range.
///
/// The current `TimeRange` type is still a placeholder, so its integer values
/// are serialized directly into the CalDAV `start` and `end` attributes.
pub fn report_calendar_query_range(range: types.TimeRange) -> String {
  let types.TimeRange(start, end) = range

  "<c:calendar-query xmlns:d=\"DAV:\" xmlns:c=\"urn:ietf:params:xml:ns:caldav\">"
  <> "<d:prop>"
  <> "<d:getetag />"
  <> "<d:getcontenttype />"
  <> "<c:calendar-data />"
  <> "</d:prop>"
  <> "<c:filter>"
  <> "<c:comp-filter name=\"VCALENDAR\">"
  <> "<c:comp-filter name=\"VEVENT\">"
  <> "<c:time-range start=\""
  <> format_time_range_value(start)
  <> "\" end=\""
  <> format_time_range_value(end)
  <> "\" />"
  <> "</c:comp-filter>"
  <> "</c:comp-filter>"
  <> "</c:filter>"
  <> "</c:calendar-query>"
}

/// Converts the temporary integer-based time range value into XML text.
fn format_time_range_value(value: Int) -> String {
  int.to_string(value)
}
