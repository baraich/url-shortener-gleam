import gleam/io
import gleam/option
import gleam/pgo
import gleam/result
import glenvy/env

pub fn connect() {
  // Reading the DB connection URI from the environment.
  use pg_dbname <- result.try(env.get_string("DB_NAME"))
  use pg_host <- result.try(env.get_string("DB_HOST"))
  use pg_user <- result.try(env.get_string("DB_USER"))
  use pg_pass <- result.try(env.get_string("DB_PASS"))

  // Starting a connection pool
  Ok(
    pgo.Config(
      ..pgo.default_config(),
      port: 47_552,
      host: pg_host,
      user: pg_user,
      pool_size: 25,
      database: pg_dbname,
      password: option.Some(pg_pass),
    )
    |> pgo.connect,
  )
}
