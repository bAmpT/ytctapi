# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ytctapi,
  ecto_repos: [Ytctapi.Repo]

# Configures the endpoint
config :ytctapi, Ytctapi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kbifEhZo3PUgkfYJ9npN2lTWXdUk4eVxBq0E2BsuoZZl1r5Lxs57JaWAzsaWOUX6",
  render_errors: [view: Ytctapi.ErrorView, accepts: ~w(json)],
  pubsub: [name: Ytctapi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure phoenix generators
config :phoenix, :generators,
  binary_id: true,
  migration: false,
  sample_binary_id: "111111111111111111111111"

# Configure guardian settings
config :guardian, Guardian,
  allowed_algos: ["HS256"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Ytctapi",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  serializer: Ytctapi.GuardianSerializer,
  secret_key: "iZAhpbscyAMfXDbKoa6fhE0cemz7BKStsvKoDjSUans"
  # fn ->
    # JOSE.JWS.generate_key(%{"alg" => "HS256"}) |> JOSE.JWK.to_map |> elem(1) |> Map.get("k")
  # end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
