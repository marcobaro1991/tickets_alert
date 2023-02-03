import Config

config :tickets_alert, TicketsAlert.Repo,
  username: "tickets_alert",
  password: "tickets_alert",
  hostname: "db",
  database: "tickets_alert",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

if System.get_env("GITHUB_ACTIONS") do
  config :tickets_alert, TicketsAlert.Repo,
    username: "postgres",
    password: "postgres",
    hostname: "localhost"
end

config :tickets_alert, TicketsAlertWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "CecrBgosXt00uogACi+Z+l9l5c4a4yW/jWpipbTeJr/x4p7jtkHDmQYC0s1UGodC",
  server: false

config :tickets_alert, TicketsAlert.Mailer, adapter: Swoosh.Adapters.Test

config :logger, :console, format: "$level $message\n", level: :info

config :phoenix, :plug_init_mode, :runtime

config :joken, default_signer: "secret"

config :tickets_alert, :jwt,
  sign: "HS256",
  exp_days: 7

config :http_mock_pal,
  routers: [
    {TicketsAlert.Support.TelegramMock, port: 3000},
    {TicketsAlert.Support.FansaleMock, port: 3001}
  ]
