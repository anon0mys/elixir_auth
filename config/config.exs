# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :odyssey,
  ecto_repos: [Odyssey.Repo]

# Configures the endpoint
config :odyssey, OdysseyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1OVnVguaHna6+YWdbskztQaOvF9ln2NgYWfAm6kgVA/503iYKv9NVgYPXrTEYFee",
  render_errors: [view: OdysseyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Odyssey.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures auth
config :odyssey, Odyssey.Auth.Guardian,
  issuer: "odyssey",
  secret_key: System.get_env("SECRET_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
