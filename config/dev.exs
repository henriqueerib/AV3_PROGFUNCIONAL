import Config

config :rotinaeco, Rotinaeco.Repo,
  username: "postgres",
  password: "120103",
  hostname: "localhost",
  database: "rotinaeco_dev",
  pool_size: 10,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :rotinaeco, RotinaecoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "C6OaYj4TsD9T0gZ7EiDNAvZeaRTHKVE99Q3PJ7F07IQWXuoqJZrZdqhl7p3JF7Kj",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:rotinaeco, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:rotinaeco, ~w(--watch)]}
  ]

config :rotinaeco, RotinaecoWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
      ~r"priv/gettext/.*\.po$"E,
      ~r"lib/rotinaeco_web/router\.ex$"E,
      ~r"lib/rotinaeco_web/(controllers|live|components)/.*\.(ex|heex)$"E
    ]
  ]

config :rotinaeco, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true,
  colocated_js: [
    disable_symlink_warning: true
  ]

config :swoosh, :api_client, false
