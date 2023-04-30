import Config

config :live_view_demos, LiveViewDemosWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "q+2jFxUqHi8QmYAqTzO/1UzTDs2O4cXXNiSbfsKq6xEMg0+98xXcDOJdnhk7BsOG",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :live_view_demos, LiveViewDemosWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/live_view_demos_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :live_view_demos, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
