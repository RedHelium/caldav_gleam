import caldav/client
import caldav/error
import caldav/internal/headers
import caldav/types
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/list
import gleam/result

/// A normalized HTTP response used by the internal transport layer.
pub type HttpResponse {
  HttpResponse(status: Int, headers: List(#(String, String)), body: String)
}

/// Sends a raw HTTP request using the current client configuration.
pub fn request(
  client client: types.Client,
  method method: http.Method,
  url url: String,
  headers extra_headers: List(#(String, String)),
  body body: String,
) -> Result(HttpResponse, error.Error) {
  let base_headers = headers.default_headers(client.config)
  let all_headers = headers.merge_headers(base_headers, extra_headers)
  use req <- result.try(
    request.to(url)
    |> result.map_error(fn(_) { error.ValidationError("Invalid URL") }),
  )
  let req =
    req
    |> request.set_method(method)
    |> request.set_body(body)

  let req =
    list.fold(over: all_headers, from: req, with: fn(acc, header) {
      let #(key, value) = header
      request.set_header(acc, key, value)
    })

  let config =
    httpc.configure()
    |> httpc.timeout(client.config.timeout_ms)

  use resp <- result.try(
    // Подсказка:
    // Здесь можно позже аккуратно преобразовать ошибку httpc в строку.
    // Для первого шага достаточно вернуть стабильный TransportError
    // с простым сообщением вроде "HTTP transport failed".
    httpc.dispatch(config, req)
    |> result.map_error(fn(e) { error.TransportError("TODO stringify") }),
  )

  Ok(HttpResponse(resp.status, resp.headers, resp.body))
}

/// Sends a PROPFIND request with the provided XML body and Depth header.
pub fn propfind(
  client client: types.Client,
  url url: String,
  body body: String,
  depth depth: String,
) -> Result(HttpResponse, error.Error) {
  request(
    client: client,
    method: http.Other("PROPFIND"),
    url: url,
    headers: [
      #("depth", depth),
      #("content-type", "application/xml; charset=utf-8"),
    ],
    body: body,
  )
}

/// Sends a REPORT request.
pub fn report(
  client client: types.Client,
  url url: String,
  body body: String,
  depth depth: String,
) {
  request(
    client: client,
    method: http.Other("REPORT"),
    url: url,
    headers: [
      #("depth", depth),
      #("content-type", "application/xml; charset=utf-8"),
    ],
    body: body,
  )
}

/// Sends a GET request.
pub fn get(client client: types.Client, url url: String) {
  request(client: client, method: http.Get, url: url, headers: [], body: "")
}

/// Sends a PUT request.
pub fn put(
  client client: types.Client,
  url url: String,
  body body: String,
  content_type content_type: String,
) {
  request(
    client: client,
    method: http.Put,
    url: url,
    headers: [
      #("content-type", content_type),
    ],
    body: body,
  )
}

/// Sends a DELETE request.
pub fn delete(client client: types.Client, url url: String) {
  request(client: client, method: http.Delete, url: url, headers: [], body: "")
}

/// Validates common successful statuses used by CalDAV operations.
pub fn expect_success(response: HttpResponse) -> Result(Nil, error.Error) {
  case response.status {
    200 | 207 -> Ok(Nil)
    401 -> Error(error.Unauthorized)
    404 -> Error(error.NotFound)
    status -> Error(error.HttpError(status, response.body))
  }
}
