import Config

config :tickets_alert, TicketsAlert.Repo,
  username: "tickets_alert",
  password: "tickets_alert",
  database: "tickets_alert",
  hostname: "db",
  pool_size: 20,
  timeout: 60_000,
  ownership_timeout: 60_000,
  disconnect_on_error_codes: [:ER_CANT_EXECUTE_IN_READ_ONLY_TRANSACTION]

config :tickets_alert, TicketsAlertWeb.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 80],
  server: true,
  load_from_system_env: true

config :logger,
  backends: [
    {PrimaExLogger, :prima_logger}
  ],
  level: :info

config :logger, :prima_logger,
  encoder: Jason,
  type: :tickets_alert,
  environment: :production

config :tickets_alert, :telegram,
  base_url: {:system, "PRODUCTION_TELEGRAM_BASE_URL"},
  bot_token: {:system, "PRODUCTION_TELEGRAM_BOT_TOKEN"},
  channel_id: {:system, "PRODUCTION_TELEGRAM_CHANNEL_ID"}

config :tickets_alert, :fansale, base_url: {:system, "PRODUCTION_FANSALE_BASE_URL"}
