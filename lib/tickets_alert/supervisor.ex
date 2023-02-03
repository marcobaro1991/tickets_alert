defmodule TicketsAlert.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_args) do
    children = [
      dynamic_supervisor(),
      pub_sub(),
      repo(),
      endpoint(),
      events_handler_process()
    ]

    opts = [strategy: :one_for_one, max_restarts: 6]
    Supervisor.init(children, opts)
  end

  def dynamic_supervisor do
    {DynamicSupervisor, strategy: :one_for_one, name: TicketsAlert.DynamicSupervisor}
  end

  defp pub_sub do
    {Phoenix.PubSub, name: TicketsAlert.PubSub}
  end

  defp repo do
    TicketsAlert.Repo
  end

  def endpoint do
    Supervisor.child_spec({TicketsAlertWeb.Endpoint, []}, shutdown: 60_000)
  end

  def events_handler_process do
    %{
      id: TicketsAlert.Process.EventsHandler,
      start: {TicketsAlert.Process.EventsHandler, :start_link, [[]]}
    }
  end
end
