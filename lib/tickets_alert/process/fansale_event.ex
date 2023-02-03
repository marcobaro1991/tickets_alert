defmodule TicketsAlert.Process.FansaleEvent do
  @moduledoc """
  This is the process that check if tickets are available for the relative event provided by fansale
  """

  use GenServer

  alias TicketsAlert.Application.FansaleEvent, as: FansaleEventApplication

  @run_every_in_minutes 1

  def start_link(event = %{identifier: event_identifier}) do
    GenServer.start_link(__MODULE__, event, name: event_identifier |> UUID.binary_to_string!() |> String.to_atom())
  end

  @impl true
  def init(state) do
    schedule_work()

    {:ok, state}
  end

  @impl true
  def handle_info(:work, state = %{identifier: event_identifier}) do
    FansaleEventApplication.check(event_identifier)

    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @run_every_in_minutes * 60 * 1000)
  end
end
