import gleam/int

/// Describes the error cases that can be produced by the library.
pub type Error {
  TransportError(message: String)
  HttpError(status: Int, body: String)
  XmlError(message: String)
  ProtocolError(message: String)
  NotFound
  Unauthorized
  Conflict
  ValidationError(message: String)
  UnknownError
}

/// Renders an error as a readable string.
pub fn to_string(err: Error) -> String {
  case err {
    TransportError(message) -> "[caldav_gleam] Transport error: " <> message
    HttpError(status, body) ->
      "[caldav_gleam] HTTP Error. Status: "
      <> int.to_string(status)
      <> " "
      <> "Body: "
      <> body
    XmlError(message) -> "[caldav_gleam] XML Error: " <> message
    ProtocolError(message) -> "[caldav_gleam] Protocol Error: " <> message
    NotFound -> "[caldav_gleam] Not found error"
    Unauthorized -> "[caldav_gleam] Unauthorized error"
    Conflict -> "[caldav_gleam] Conflict Error"
    ValidationError(message) -> "[caldav_gleam] Validation Error: " <> message
    UnknownError -> "[caldav_gleam] Unknown error"
  }
}
