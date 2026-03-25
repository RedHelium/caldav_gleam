import caldav/error
import caldav/internal/http
import caldav/internal/xml_request
import caldav/internal/xml_response
import caldav/types
import gleam/result

/// Lists calendars available under the discovered calendar home set.
pub fn list_calendars(
  client: types.Client,
  discovery: types.DiscoveryInfo,
) -> Result(List(types.Calendar), error.Error) {
  let xml_body = xml_request.propfind_list_calendars()
  use propfind_discovery_response <- result.try(http.propfind(
    client,
    discovery.calendar_home_set_url,
    xml_body,
    "1",
  ))
  use _ <- result.try(http.expect_success(propfind_discovery_response))
  let calendars = xml_response.parse_calendars(propfind_discovery_response.body)

  calendars
}
