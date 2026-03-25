# caldav_gleam

A lightweight Gleam library for practical CalDAV operations:

- endpoint discovery (`current-user-principal`, `calendar-home-set`)
- listing calendars
- querying calendar events
- creating, updating, and deleting `VEVENT` resources (`.ics`)

## Status

Current status: 1.0.

The core CalDAV flow is implemented and tested for common client tasks without over-engineering.

## Features

- Authentication: `Basic`, `Bearer`, `NoAuth`
- CalDAV endpoint discovery
- `PROPFIND` for calendars
- `REPORT calendar-query` for events
- `GET` event by URL
- `PUT` create/update event
- `DELETE` event
- Unified library error type

## Installation

```bash
gleam add caldav_gleam
```

## Quick Start

```gleam
import caldav_gleam
import gleam/int
import gleam/io
import gleam/list

pub fn main() {
  let cfg =
    caldav_gleam.new_config(
      "https://nextcloud.example.com/remote.php/dav",
      caldav_gleam.basic_auth("demo", "app-password"),
    )
    |> caldav_gleam.with_timeout(10_000)
    |> caldav_gleam.with_user_agent("my-caldav-app/0.1.0")

  let client = caldav_gleam.new_client(cfg)

  case caldav_gleam.discover(client) {
    Error(err) -> io.println(caldav_gleam.error_to_string(err))
    Ok(info) ->
      case caldav_gleam.list_calendars(client, info) {
        Error(err) -> io.println(caldav_gleam.error_to_string(err))
        Ok(calendars) ->
          io.println("Calendars found: " <> int.to_string(list.length(calendars)))
      }
  }
}
```

## Create Event Example

```gleam
import caldav_gleam
import gleam/io

pub fn create_event_example() {
  let cfg =
    caldav_gleam.new_config(
      "https://nextcloud.example.com/remote.php/dav",
      caldav_gleam.basic_auth("demo", "app-password"),
    )

  let client = caldav_gleam.new_client(cfg)

  let event_ics =
    "BEGIN:VCALENDAR\r\n"
    <> "VERSION:2.0\r\n"
    <> "PRODID:-//caldav_gleam//EN\r\n"
    <> "BEGIN:VEVENT\r\n"
    <> "UID:sample-1\r\n"
    <> "DTSTAMP:20260325T010000Z\r\n"
    <> "DTSTART:20260326T090000Z\r\n"
    <> "DTEND:20260326T100000Z\r\n"
    <> "SUMMARY:Demo event\r\n"
    <> "END:VEVENT\r\n"
    <> "END:VCALENDAR\r\n"

  case caldav_gleam.create_event(
    client,
    "https://nextcloud.example.com/remote.php/dav/calendars/demo/work/",
    "sample-1.ics",
    event_ics,
  ) {
    Ok(event) -> io.println("Created: " <> event.href)
    Error(err) -> io.println(caldav_gleam.error_to_string(err))
  }
}
```

## Public API (Facade)

Main module: `caldav_gleam`.

- auth: `no_auth`, `basic_auth`, `bearer_auth`, `oauth_auth`
- config: `new_config`, `with_user_agent`, `with_timeout`
- client: `new_client`, `client_config`
- discovery: `discover`, `find_principal`, `find_calendar_home_set`
- calendar: `list_calendars`
- event: `list_events`, `list_events_in_range`, `get_event`, `create_event`, `update_event`, `delete_event`
- errors: `error_to_string`

## Error Model

The library returns `Result(..., caldav/error.Error)` with these primary variants:

- `TransportError`
- `HttpError`
- `XmlError`
- `ProtocolError`
- `NotFound`
- `Unauthorized`
- `Conflict`
- `ValidationError`

## Running Tests

```bash
gleam test
```

Current tests cover discovery/calendar/event response parsing and XML request builders.