import caldav/client
import caldav/error
import caldav/internal/http
import caldav/internal/xml_request
import caldav/internal/xml_response
import caldav/types
import gleam/result

/// Runs the standard CalDAV discovery flow and returns the discovered endpoints.
pub fn discover(
  client: types.Client,
) -> Result(types.DiscoveryInfo, error.Error) {
  use principal <- result.try(find_principal(client))
  use home_set <- result.try(find_calendar_home_set(client, principal))
  Ok(types.DiscoveryInfo(
    principal_url: principal,
    calendar_home_set_url: home_set,
  ))
}

/// Finds the current user principal URL from the server root.
pub fn find_principal(client: types.Client) -> Result(String, error.Error) {
  let body = xml_request.propfind_current_user_principal()

  use response <- result.try(http.propfind(
    client: client,
    url: client.config.base_url,
    body: body,
    depth: "0",
  ))

  use _ <- result.try(http.expect_success(response))

  xml_response.parse_current_user_principal(response.body)
}

/// Finds the calendar home set URL for a discovered principal.
pub fn find_calendar_home_set(
  client: types.Client,
  principal_url: String,
) -> Result(String, error.Error) {
  let body = xml_request.propfind_calendar_home_set()

  use response <- result.try(http.propfind(
    client: client,
    url: principal_url,
    body: body,
    depth: "0",
  ))

  use _ <- result.try(http.expect_success(response))

  xml_response.parse_calendar_home_set(response.body)
}
