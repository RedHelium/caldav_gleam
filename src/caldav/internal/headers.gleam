import caldav/auth
import caldav/config
import gleam/list
import gleam/option

pub fn default_headers(config: config.Config) -> List(#(String, String)) {
  [#("user-agent", config.user_agent), ..auth.to_headers(config.auth)]
}

pub fn with_depth(headers, depth) -> List(#(String, String)) {
  list.key_set(headers, "depth", depth)
}

pub fn with_content_type(headers, value) -> List(#(String, String)) {
  list.key_set(headers, "content-type", value)
}

pub fn with_if_match(
  headers,
  etag: option.Option(String),
) -> List(#(String, String)) {
  case etag {
    option.Some(etag) -> list.key_set(headers, "if-match", etag)
    option.None -> headers
  }
}

pub fn merge_headers(
  left: List(#(String, String)),
  right: List(#(String, String)),
) -> List(#(String, String)) {
  list.fold(over: right, from: left, with: fn(headers, header) {
    let #(key, value) = header
    list.key_set(headers, key, value)
  })
}
