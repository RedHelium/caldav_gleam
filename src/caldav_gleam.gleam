import caldav/auth
import caldav/calendar
import caldav/client
import caldav/config
import caldav/discovery
import caldav/error
import caldav/event
import caldav/types
import gleam/option

pub fn no_auth() -> auth.Auth {
  auth.NoAuth
}

pub fn basic_auth(username: String, password: String) -> auth.Auth {
  auth.Basic(username: username, password: password)
}

pub fn bearer_auth(token: String) -> auth.Auth {
  auth.Bearer(token: token)
}

pub fn oauth_auth() -> auth.Auth {
  auth.OAuth
}

pub fn new_config(base_url: String, credentials: auth.Auth) -> config.Config {
  config.new(base_url, credentials)
}

pub fn with_user_agent(cfg: config.Config, user_agent: String) -> config.Config {
  config.with_user_agent(cfg, user_agent)
}

pub fn with_timeout(cfg: config.Config, timeout_ms: Int) -> config.Config {
  config.with_timeout(cfg, timeout_ms)
}

pub fn new_client(cfg: config.Config) -> types.Client {
  client.new(cfg)
}

pub fn client_config(caldav_client: types.Client) -> config.Config {
  client.config(caldav_client)
}

pub fn discover(
  caldav_client: types.Client,
) -> Result(types.DiscoveryInfo, error.Error) {
  discovery.discover(caldav_client)
}

pub fn find_principal(
  caldav_client: types.Client,
) -> Result(String, error.Error) {
  discovery.find_principal(caldav_client)
}

pub fn find_calendar_home_set(
  caldav_client: types.Client,
  principal_url: String,
) -> Result(String, error.Error) {
  discovery.find_calendar_home_set(caldav_client, principal_url)
}

pub fn list_calendars(
  caldav_client: types.Client,
  discovery_info: types.DiscoveryInfo,
) -> Result(List(types.Calendar), error.Error) {
  calendar.list_calendars(caldav_client, discovery_info)
}

pub fn list_events(
  caldav_client: types.Client,
  calendar_url: String,
) -> Result(List(types.Event), error.Error) {
  event.list_events(caldav_client, calendar_url)
}

pub fn list_events_in_range(
  caldav_client: types.Client,
  calendar_url: String,
  range: types.TimeRange,
) -> Result(List(types.Event), error.Error) {
  event.list_events_in_range(caldav_client, calendar_url, range)
}

pub fn get_event(
  caldav_client: types.Client,
  event_url: String,
) -> Result(types.Event, error.Error) {
  event.get_event(caldav_client, event_url)
}

pub fn create_event(
  caldav_client: types.Client,
  calendar_url: String,
  file_name: String,
  ics_data: String,
) -> Result(types.Event, error.Error) {
  event.create_event(caldav_client, calendar_url, file_name, ics_data)
}

pub fn update_event(
  caldav_client: types.Client,
  event_url: String,
  ics_data: String,
  etag: option.Option(String),
) -> Result(types.Event, error.Error) {
  event.update_event(caldav_client, event_url, ics_data, etag)
}

pub fn delete_event(
  caldav_client: types.Client,
  event_url: String,
  etag: option.Option(String),
) -> Result(Nil, error.Error) {
  event.delete_event(caldav_client, event_url, etag)
}

pub fn error_to_string(err: error.Error) -> String {
  error.to_string(err)
}
