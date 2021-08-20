# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :todo, TodoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PfmabSaMe6hM5cTQw68voWDwvGd0DqYkkH3k56wp9+qgzXP3qZhqcTSrWQJMS7W7",
  render_errors: [view: TodoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Todo.PubSub,
  live_view: [signing_salt: "jnVvdNBn"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
