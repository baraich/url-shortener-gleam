import gleam/dynamic
import gleam/http.{Get, Post}
import gleam/io
import gleam/list
import gleam/pgo.{type Connection}
import gleam/string
import wisp.{type Request, type Response}

import app/middleware

fn landing_page(connection: Connection) -> Response {
  let sql = "SELECT * FROM urls"
  let response_type =
    dynamic.tuple3(dynamic.int, dynamic.string, dynamic.string)

  let assert Ok(results) = pgo.execute(sql, connection, [], response_type)
  io.debug(results)
  let ids = list.map(results.rows, fn(item) { item.2 })

  wisp.ok()
  |> wisp.string_body(string.concat(ids))
}

pub fn handle_request(request: Request, connection: Connection) -> Response {
  use request <- middleware.apply(request)

  case request.method, wisp.path_segments(request) {
    Get, [] -> landing_page(connection)
    _, _ -> wisp.method_not_allowed([Get, Post])
  }
}
