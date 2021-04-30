use Mix.Config

config :phoenix_live_view_collection, :env, :test

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_live_view_collection, LiveViewCollectionWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
