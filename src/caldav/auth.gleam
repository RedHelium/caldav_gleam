import gleam/bit_array

/// Represents the supported authentication strategies for CalDAV requests.
pub type Auth {
  NoAuth
  Basic(username: String, password: String)
  Bearer(token: String)
  OAuth
  // TODO Complete work with OAuth
}

/// Converts an authentication value into HTTP headers.
pub fn to_headers(auth: Auth) -> List(#(String, String)) {
  case auth {
    Bearer(token) -> {
      [#("authorization", "Bearer " <> token)]
    }
    NoAuth | OAuth -> []
    Basic(username, password) -> {
      let credentials = username <> ":" <> password
      let encoded =
        credentials
        |> bit_array.from_string
        |> bit_array.base64_encode(True)

      [#("authorization", "Basic " <> encoded)]
    }
  }
}
