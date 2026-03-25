import caldav/error
import caldav/internal/http
import caldav/internal/url
import caldav/internal/xml_request
import caldav/internal/xml_response
import caldav/types
import gleam/http as raw_http
import gleam/option
import gleam/result
import gleam/string

/// Lists all events available in a calendar collection.
pub fn list_events(
  client: types.Client,
  calendar_url: String,
) -> Result(List(types.Event), error.Error) {
  let xml_body = xml_request.report_calendar_query_all()
  use response <- result.try(http.report(client, calendar_url, xml_body, "1"))
  use _ <- result.try(http.expect_success(response))
  xml_response.parse_calendar_query(response.body)
}

/// Lists events that intersect with the given time range.
pub fn list_events_in_range(
  client: types.Client,
  calendar_url: String,
  range: types.TimeRange,
) -> Result(List(types.Event), error.Error) {
  let xml_body = xml_request.report_calendar_query_range(range)
  use response <- result.try(http.report(client, calendar_url, xml_body, "1"))
  use _ <- result.try(http.expect_success(response))
  xml_response.parse_calendar_query(response.body)
}

/// Fetches a single event by its full resource URL.
pub fn get_event(
  client: types.Client,
  event_url: String,
) -> Result(types.Event, error.Error) {
  use response <- result.try(http.get(client, event_url))
  case response.status {
    200 ->
      Ok(types.Event(
        href: event_url,
        etag: find_header(response.headers, "etag"),
        calendar_data: response.body,
        content_type: find_header(response.headers, "content-type"),
      ))
    404 -> Error(error.NotFound)
    401 -> Error(error.Unauthorized)
    status -> Error(error.HttpError(status, response.body))
  }
}

/// Creates a new event resource inside the target calendar.
pub fn create_event(
  client: types.Client,
  calendar_url: String,
  file_name: String,
  ics_data: String,
) -> Result(types.Event, error.Error) {
  use _ <- result.try(validate_file_name(file_name))

  let event_url = url.join(calendar_url, file_name)

  use response <- result.try(http.put(
    client,
    event_url,
    ics_data,
    "text/calendar; charset=utf-8",
  ))

  use _ <- result.try(expect_write_success(response))

  get_event(client, event_url)
}

/// Updates an existing event and optionally checks the current ETag.
pub fn update_event(
  client: types.Client,
  event_url: String,
  ics_data: String,
  etag: option.Option(String),
) -> Result(types.Event, error.Error) {
  let extra_headers = case etag {
    option.Some(value) -> [#("if-match", value)]
    option.None -> []
  }

  use response <- result.try(http.request(
    client: client,
    method: raw_http.Put,
    url: event_url,
    headers: [#("content-type", "text/calendar; charset=utf-8"), ..extra_headers],
    body: ics_data,
  ))

  use _ <- result.try(expect_write_success(response))

  get_event(client, event_url)
}

/// Deletes an event and optionally checks the current ETag.
pub fn delete_event(
  client: types.Client,
  event_url: String,
  etag: option.Option(String),
) -> Result(Nil, error.Error) {
  let extra_headers = case etag {
    option.Some(value) -> [#("if-match", value)]
    option.None -> []
  }

  use response <- result.try(http.request(
    client: client,
    method: raw_http.Delete,
    url: event_url,
    headers: extra_headers,
    body: "",
  ))

  case response.status {
    200 | 204 -> Ok(Nil)
    401 -> Error(error.Unauthorized)
    404 -> Error(error.NotFound)
    409 | 412 -> Error(error.Conflict)
    status -> Error(error.HttpError(status, response.body))
  }
}

fn find_header(
  headers: List(#(String, String)),
  expected_name: String,
) -> option.Option(String) {
  case headers {
    [] -> option.None
    [#(name, value), ..rest] ->
      case string.lowercase(name) == expected_name {
        True -> option.Some(value)
        False -> find_header(rest, expected_name)
      }
  }
}

fn validate_file_name(file_name: String) -> Result(Nil, error.Error) {
  let normalized = string.trim(file_name)

  case normalized == "" {
    True -> Error(error.ValidationError("file_name must not be empty"))
    False ->
      case string.ends_with(normalized, ".ics") {
        True -> Ok(Nil)
        False -> Error(error.ValidationError("file_name must end with .ics"))
      }
  }
}

fn expect_write_success(response: http.HttpResponse) -> Result(Nil, error.Error) {
  case response.status {
    200 | 201 | 204 -> Ok(Nil)
    401 -> Error(error.Unauthorized)
    404 -> Error(error.NotFound)
    409 | 412 -> Error(error.Conflict)
    status -> Error(error.HttpError(status, response.body))
  }
}
