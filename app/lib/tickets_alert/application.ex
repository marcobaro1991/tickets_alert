defmodule TicketsAlert.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, args) do
    TicketsAlert.Supervisor.start_link(args)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TicketsAlertWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
