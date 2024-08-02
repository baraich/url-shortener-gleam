import gleam/http
import gleam/int
import gleam/io
import gleam/string
import gleam_community/ansi
import wisp.{type Request, type Response}

fn log_request(req: Request, handler: fn() -> Response) -> Response {
  let response = handler()

  [
    ansi.blue("INFO "),
    int.to_string(response.status),
    " ",
    string.uppercase(http.method_to_string(req.method)),
    " ",
    req.path,
  ]
  |> string.concat
  |> io.println

  response
}

pub fn apply(request: Request, handler: fn(Request) -> Response) {
  // Allows different requests to be processed instead of just (GET, POST)
  let request = wisp.method_override(request)

  // Log information about the current incomming request
  use <- log_request(request)

  // Automatically response with 500 (ServerInternalError) status code, if the 
  // the handler function crashes
  use <- wisp.rescue_crashes
  use request <- wisp.handle_head(request)

  // Get the installation path for the project
  let assert Ok(installation_path) = wisp.priv_directory(".")

  use <- wisp.serve_static(
    request,
    under: "/static",
    from: installation_path <> "/static",
  )

  handler(request)
}
