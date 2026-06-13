import Config

config :pbkdf2_elixir, :rounds, 1

config :rotinaeco, Rotinaeco.Repo,
  username: "postgres",
  password: "120103",
  hostname: "localhost",
  database: "rotinaeco_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :rotinaeco, RotinaecoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "lZOU119/ZBJqNfIiSLKu5DYVgqJ3vqcyslBqFNk7rp20rZf1h5ya45wDChOlmd1y",
  server: false

config :rotinaeco, Rotinaeco.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :phoenix,
  sort_verified_routes_query_params: true
