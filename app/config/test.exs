import Config

config :tickets_alert, TicketsAlert.Repo,
  username: "tickets_alert",
  password: "tickets_alert",
  hostname: "db",
  database: "tickets_alert",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :tickets_alert, TicketsAlertWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "CecrBgosXt00uogACi+Z+l9l5c4a4yW/jWpipbTeJr/x4p7jtkHDmQYC0s1UGodC",
  server: false

config :tickets_alert, :telegram,
  base_url: "http://telegram-mock-service:3000",
  bot_token: "XXX",
  channel_id: "XXX"

config :tickets_alert, :fansale, base_url: "http://fansale-mock-service:3000"

if System.get_env("GITHUB_ACTIONS") do
  config :tickets_alert, TicketsAlert.Repo,
    username: "postgres",
    password: "postgres",
    hostname: "localhost"

  config :tickets_alert, :redis, connection_url: "redis://localhost:6379/1"

  config :tickets_alert, :telegram,
    base_url: "http://telegram-mock-service:3001",
    bot_token: "XXX",
    channel_id: "XXX"

  config :tickets_alert, :fansale, base_url: "http://fansale-mock-service:3000"
end
