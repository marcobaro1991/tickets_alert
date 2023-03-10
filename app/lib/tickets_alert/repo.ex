defmodule TicketsAlert.Repo do
  use Ecto.Repo,
    otp_app: :tickets_alert,
    adapter: Ecto.Adapters.Postgres
end
