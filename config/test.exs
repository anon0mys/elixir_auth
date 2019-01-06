use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :odyssey, OdysseyWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Reduce encryption during tests for speed
config :bcrypt_elixir, log_rounds: 4

# Configure your database
config :odyssey, Odyssey.Repo,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("TEST_DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  pool: Ecto.Adapters.SQL.Sandbox
