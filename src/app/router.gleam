import gleam/http.{Get, Post}
import wisp.{type Request, type Response}

import app/middleware

pub fn handle_request(request: Request) -> Response {
  use request <- middleware.apply(request)

  case request.method, wisp.path_segments(request) {
    _, _ -> wisp.method_not_allowed([Get, Post])
  }
}
