import Config

config :live_view_demos, LiveViewDemosWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "pu13/23t6ZER8eszXrRmf6NRPMWuNi1IJkWJkH/djNejkezLDvYpJn5YRKGLtKO1",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
