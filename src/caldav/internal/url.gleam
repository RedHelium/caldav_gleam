import gleam/string

/// Joins a base URL and a relative path without producing a double slash.
///
/// The `base` value is expected to already include the scheme and host,
/// while `path` represents the resource path.
pub fn join(base: String, path: String) -> String {
  let base_format = case string.ends_with(base, "/") {
    True -> string.drop_end(base, 1)
    False -> base
  }
  let path_format = case string.starts_with(path, "/") {
    True -> path
    False -> string.append("/", path)
  }

  base_format <> path_format
}

/// Ensures that the URL ends with a trailing slash.
pub fn ensure_trailing_slash(url: String) -> String {
  let url_format = case string.ends_with(url, "/") {
    True -> url
    False -> string.append(url, "/")
  }
  url_format
}

/// Removes a trailing slash without breaking the root path `/`.
pub fn strip_trailing_slash(url: String) -> String {
  let url_format = case url == "/" {
    True -> url
    False ->
      case string.ends_with(url, "/") {
        True -> string.drop_end(url, 1)
        False -> url
      }
  }
  url_format
}
