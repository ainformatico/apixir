# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :apixir,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :apixir, ApixirWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ApixirWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Apixir.PubSub,
  live_view: [signing_salt: "VdLaY/VY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :apixir, :rate_limit_requests, 10
config :apixir, :rate_limit_window, 60_000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
