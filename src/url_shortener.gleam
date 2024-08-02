import app/db
import gleam/erlang/process
import gleam/result.{try}
import glenvy/dotenv
import glenvy/env
import mist
import wisp

import app/router

pub fn main() {
  // Making sure the continuation of the program only happens
  // after successfully loading environment variables into the application.
  let assert Ok(_) = dotenv.load()

  use port <- try(env.get_int("PORT"))
  use secret_key <- try(env.get_string("SECRET_KEY"))

  // Getting the database connection pool
  let assert Ok(db) = db.connect()

  // Log information about the current incomming request
  wisp.configure_logger()

  // Trying to start the webserver on given PORT
  let assert Ok(_) =
    wisp.mist_handler(
      fn(request) { router.handle_request(request, db) },
      secret_key,
    )
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  // Once the code execution reaches here, we are sure that our webserver
  // has been started listening on the specified server PORT.
  // The code execution happens on a new Erlang process that runs concurrently,
  // so we put the following thread to sleep.
  process.sleep_forever()
  Ok(Nil)
}
