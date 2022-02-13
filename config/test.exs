import Config

config :phoenix_live_view_collection, env: :test

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phoenix_live_view_collection, LiveViewCollectionWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "yQs3//1Z+8X8DQukLAHAWU42ejMnGWiTLl6EDVDTI+wWHGli5tXy0AfVuhbVOAeL",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
