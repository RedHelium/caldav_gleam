import caldav/config
import gleam/option

/// Wraps the root configuration used by the library.
pub type Client {
  Client(config: config.Config)
}

/// Contains the URLs discovered during the CalDAV bootstrap flow.
pub type DiscoveryInfo {
  DiscoveryInfo(principal_url: String, calendar_home_set_url: String)
}

/// Represents a calendar collection returned by the server.
pub type Calendar {
  Calendar(
    url: String,
    display_name: String,
    description: option.Option(String),
    ctag: option.Option(String),
  )
}

/// Represents a calendar object resource together with useful metadata.
pub type Event {
  Event(
    href: String,
    etag: option.Option(String),
    calendar_data: String,
    content_type: option.Option(String),
  )
}

/// Represents a time interval used in calendar queries.
pub type TimeRange {
  TimeRange(start: Int, end: Int)
}
