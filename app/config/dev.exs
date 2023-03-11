import Config

config :tickets_alert, TicketsAlert.Repo,
  username: "tickets_alert",
  password: "tickets_alert",
  hostname: "db",
  database: "tickets_alert",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :tickets_alert, TicketsAlertWeb.Endpoint,
  http: [port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "JCj/TVYnRhCl0FKMTf2CiAFFB3okcDmy6qKR5efjKJL4LuuIKRE0BrAv/lKKrhbw",
  live_view: [signing_salt: "F0WWUDLjFJ3zOwJB"],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/tickets_alert_web/(live|views)/.*(ex)$",
      ~r"lib/tickets_alert_web/templates/.*(eex)$"
    ]
  ],
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}
  ]

# config :logger,
#  backends: [
#    {PrimaExLogger, :prima_logger}
#  ],
#  level: :info
#
# config :logger, :prima_logger,
#  encoder: Jason,
#  type: :tickets_alert,
#  environment: :dev

config :tickets_alert, :telegram,
  base_url: "http://telegram-mock-service:3001",
  bot_token: "XXX",
  channel_id: "XXX"

config :tickets_alert, :fansale, base_url: "http://fansale-mock-service:3000"
