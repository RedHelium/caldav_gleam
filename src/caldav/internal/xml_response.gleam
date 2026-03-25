import caldav/error
import caldav/types
import gleam/list
import gleam/option
import gleam/result
import gleam/string

/// Parses the current user principal URL from a DAV multistatus response.
pub fn parse_current_user_principal(body: String) -> Result(String, error.Error) {
  let xml = normalize_xml(body)

  use principal <- result.try(
    option.to_result(
      extract_tag_text(xml, "current-user-principal")
      |> option.then(fn(section) { extract_tag_text(section, "href") })
      |> option.map(string.trim),
      error.XmlError("Could not parse current-user-principal href"),
    ),
  )

  Ok(principal)
}

/// Parses the calendar home set URL from a DAV multistatus response.
pub fn parse_calendar_home_set(body: String) -> Result(String, error.Error) {
  let xml = normalize_xml(body)

  use home_set <- result.try(
    option.to_result(
      extract_tag_text(xml, "calendar-home-set")
      |> option.then(fn(section) { extract_tag_text(section, "href") })
      |> option.map(string.trim),
      error.XmlError("Could not parse calendar-home-set href"),
    ),
  )

  Ok(home_set)
}

/// Parses calendar collection entries from a DAV multistatus response.
pub fn parse_calendars(body: String) -> Result(List(types.Calendar), error.Error) {
  let xml = normalize_xml(body)

  xml
  |> extract_blocks("response")
  |> list.filter_map(parse_calendar_response)
  |> Ok
}

/// Parses calendar object resources from a CalDAV calendar-query response.
pub fn parse_calendar_query(body: String) -> Result(List(types.Event), error.Error) {
  let xml = normalize_xml(body)

  xml
  |> extract_blocks("response")
  |> list.filter_map(parse_event_response)
  |> Ok
}

fn parse_calendar_response(block: String) -> Result(types.Calendar, Nil) {
  case is_calendar_collection(block) {
    False -> Error(Nil)
    True -> {
      let property_block = property_source(block)

      use href <- result.try(
        option.to_result(
          extract_tag_text(block, "href") |> option.map(string.trim),
          Nil,
        ),
      )

      let display_name =
        extract_tag_text(property_block, "displayname")
        |> option.map(string.trim)
        |> option.unwrap("")

      let description =
        extract_tag_text(property_block, "calendar-description")
        |> option.map(string.trim)

      let ctag =
        extract_tag_text(property_block, "getctag")
        |> option.map(string.trim)

      Ok(types.Calendar(
        url: href,
        display_name: display_name,
        description: description,
        ctag: ctag,
      ))
    }
  }
}

fn parse_event_response(block: String) -> Result(types.Event, Nil) {
  let property_block = property_source(block)

  use href <- result.try(
    option.to_result(
      extract_tag_text(block, "href") |> option.map(string.trim),
      Nil,
    ),
  )

  use calendar_data <- result.try(
    option.to_result(
      extract_tag_text(property_block, "calendar-data"),
      Nil,
    ),
  )

  let etag =
    extract_tag_text(property_block, "getetag")
    |> option.map(string.trim)

  let content_type =
    extract_tag_text(property_block, "getcontenttype")
    |> option.map(string.trim)

  Ok(types.Event(
    href: href,
    etag: etag,
    calendar_data: string.trim(calendar_data),
    content_type: content_type,
  ))
}

fn property_source(block: String) -> String {
  case successful_propstat(block) {
    option.Some(propstat) -> propstat
    option.None -> block
  }
}

fn successful_propstat(block: String) -> option.Option(String) {
  block
  |> extract_blocks("propstat")
  |> list.filter(fn(propstat) {
    string.contains(propstat, "200 OK") || string.contains(propstat, ">200<")
  })
  |> first_option
}

fn is_calendar_collection(block: String) -> Bool {
  let property_block = property_source(block)

  string.contains(property_block, "<calendar/>")
  || string.contains(property_block, "<calendar />")
  || string.contains(property_block, "<calendar></calendar>")
}

fn extract_blocks(xml: String, tag: String) -> List(String) {
  xml
  |> string.split("<" <> tag <> ">")
  |> list.filter_map(fn(segment) {
    case string.split_once(segment, "</" <> tag <> ">") {
      Ok(#(content, _)) -> Ok(content)
      Error(_) -> Error(Nil)
    }
  })
}

fn extract_tag_text(xml: String, tag: String) -> option.Option(String) {
  case string.split_once(xml, "<" <> tag <> ">") {
    Ok(#(_, rest)) ->
      case string.split_once(rest, "</" <> tag <> ">") {
        Ok(#(content, _)) -> option.Some(content)
        Error(_) -> option.None
      }
    Error(_) -> option.None
  }
}

fn first_option(values: List(a)) -> option.Option(a) {
  case list.first(values) {
    Ok(value) -> option.Some(value)
    Error(_) -> option.None
  }
}

fn normalize_xml(xml: String) -> String {
  xml
  |> strip_namespace_prefix("d")
  |> strip_namespace_prefix("D")
  |> strip_namespace_prefix("c")
  |> strip_namespace_prefix("C")
  |> strip_namespace_prefix("cs")
  |> strip_namespace_prefix("CS")
  |> strip_namespace_prefix("cal")
  |> strip_namespace_prefix("CAL")
}

fn strip_namespace_prefix(xml: String, prefix: String) -> String {
  xml
  |> string.replace(each: "<" <> prefix <> ":", with: "<")
  |> string.replace(each: "</" <> prefix <> ":", with: "</")
}
