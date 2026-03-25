import caldav/error
import caldav/types
import gleam/option

/// Lists all events available in a calendar collection.
pub fn list_events(
  client: types.Client,
  calendar_url: String,
) -> Result(List(types.Event), error.Error) {
  todo
}

/// Lists events that intersect with the given time range.
pub fn list_events_in_range(
  client: types.Client,
  calendar_url: String,
  range: types.TimeRange,
) -> Result(List(types.Event), error.Error) {
  todo
}

/// Fetches a single event by its full resource URL.
pub fn get_event(
  client: types.Client,
  event_url: String,
) -> Result(types.Event, error.Error) {
  todo
}

/// Creates a new event resource inside the target calendar.
pub fn create_event(
  client: types.Client,
  calendar_url: String,
  file_name: String,
  ics_data,
) -> Result(types.Event, error.Error) {
  todo
}

/// Updates an existing event and optionally checks the current ETag.
pub fn update_event(
  client: types.Client,
  event_url: String,
  ics_data,
  etag: option.Option(String),
) -> Result(types.Event, error.Error) {
  todo
}

/// Deletes an event and optionally checks the current ETag.
pub fn delete_event(
  client: types.Client,
  event_url: String,
  etag: option.Option(String),
) -> Result(Nil, error.Error) {
  todo
}
