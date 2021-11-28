use Mix.Config

config :todo, TodoWeb.Endpoint,
  server: true,
  url: [host: "elixirtodomvc.com", port: 80],
  http: [
    port: 4000,
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: "PfmabSaMe6hM5cTQw68voWDwvGd0DqYkkH3k56wp9+qgzXP3qZhqcTSrWQJMS7w1"
