import wisp.{type Request, type Response}

pub fn apply(request: Request, handler: fn(Request) -> Response) {
  // Allows different requests to be processed instead of just (GET, POST)
  let request = wisp.method_override(request)

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
