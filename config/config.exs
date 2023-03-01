import Config

config :tickets_alert,
  ecto_repos: [TicketsAlert.Repo]

config :tickets_alert, TicketsAlertWeb.Endpoint,
  url: [host: "localhost"],
  http: [
    protocol_options: [idle_timeout: 65_000, max_keepalive: :infinity, request_timeout: 65_000],
    transport_options: [socket_opts: [keepalive: true]]
  ],
  secret_key_base: "CecrBgosXt00uogACi+Z+l9l5c4a4yW/jWpipbTeJr/x4p7jtkHDmQYC0s1UGodC",
  render_errors: [view: TicketsAlertWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TicketsAlert.PubSub

config :esbuild,
  version: "0.14.29",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tickets_alert, :telegram,
  base_url: "http://localhost:3000",
  bot_token: "XXX",
  channel_id: "XXX"

config :tickets_alert, :fansale, base_url: "http://localhost:3001"

config :elixir,
       :time_zone_database,
       Tz.TimeZoneDatabase

config :tickets_alert, :jwt,
  sign: "HS256",
  exp_days: 7

config :tickets_alert, :redis, connection_url: "redis://redis:6379/1"

config :phoenix, :json_library, Jason

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :joken, default_signer: "secret"

config :logger, :console, format: "$level $message\n", level: :debug

import_config "#{config_env()}.exs"
