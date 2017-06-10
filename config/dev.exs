use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :ytctapi, Ytctapi.Endpoint,
  http: [port: 4000],
  url: [host: "0.0.0.0", port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch"]]


# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
# config :ytctapi, Ytctapi.Repo,
#   adapter: Mongo.Ecto,
#   database: "ytctapi_dev",
#   pool_size: 10

# Nanobox Setup
config :ytctapi, Ytctapi.Repo,
  adapter: Mongo.Ecto,
  database: "ytctapi_dev",
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  hostname: System.get_env("DATA_DB_HOST"),
  pool_size: 10

