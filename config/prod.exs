import Config

config :tickets_alert, TicketsAlertWeb.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 80],
  server: true,
  load_from_system_env: true

config :tickets_alert, TicketsAlert.Repo,
  username: "tickets_alert",
  password: "tickets_alert",
  database: "tickets_alert",
  hostname: "db",
  pool_size: 20,
  timeout: 60_000,
  ownership_timeout: 60_000,
  disconnect_on_error_codes: [:ER_CANT_EXECUTE_IN_READ_ONLY_TRANSACTION]

config :tickets_alert, :telegram,
  base_url: {:system, "TELEGRAM_BASE_URL", "https://www.exmaple.com"},
  bot_token: {:system, "TELEGRAM_BOT_TOKEN", "XXX"},
  channel_id: {:system, "TELEGRAM_CHANNEL_ID", "XXX"}

config :tickets_alert, :fansale, base_url: {:system, "FANSALE_BASE_URL", "https://www.exmaple.com"}

# config :logger, :console, format: "$level $message\n", level: :debug

config :logger,
  backends: [
    {PrimaExLogger, :prima_logger}
  ],
  level: :info

config :logger, :prima_logger,
  encoder: Jason,
  type: :tickets_alert,
  environment: :production
