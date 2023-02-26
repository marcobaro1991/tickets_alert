defmodule TicketsAlert.Process.EventsHandler do
  @moduledoc """
  This is the main process that spawn one process for each event that must check if tickets are available
  """

  use GenServer

  alias TicketsAlert.Application.Event, as: EventApplication
  alias TicketsAlert.DynamicSupervisor, as: DynSupervisor

  @run_every_in_minutes 1

  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    schedule_work()

    {:ok, state}
  end

  @impl true
  def handle_info(:work, _state) do
    Logger.info("check events")
    terminate_expired_and_disabled_running_events()
    start_events()
    schedule_work()

    {:noreply, nil}
  end

  @spec terminate_expired_and_disabled_running_events :: :ok | :error
  defp terminate_expired_and_disabled_running_events do
    Enum.each(DynSupervisor.get_child_list(), fn %{pid: pid, state: event} ->
      event
      |> Map.get(:identifier)
      |> EventApplication.still_valid?()
      |> terminate_process(pid)
    end)
  end

  @spec terminate_process(boolean(), pid()) :: :ok | :error
  defp terminate_process(_event_still_valid? = true, _pid) do
    :ok
  end

  defp terminate_process(_, pid) do
    DynSupervisor.terminate_process(pid)
  end

  @spec start_events :: list()
  defp start_events do
    EventApplication.get_all_valid()
    |> reject_events_already_running()
    |> Enum.map(fn %{identifier: identifier, provider: provider} ->
      case provider do
        :fansale ->
          DynSupervisor.start_fansale_event_process(%{identifier: identifier})

        _ ->
          nil
      end
    end)
  end

  @spec reject_events_already_running(list()) :: list()
  defp reject_events_already_running(valid_events) do
    Enum.reject(valid_events, fn %{identifier: event_identifier} ->
      Enum.any?(DynSupervisor.get_child_list(), fn %{state: state} ->
        Map.get(state, :identifier) == event_identifier
      end)
    end)
  end

  defp schedule_work do
    Process.send_after(self(), :work, @run_every_in_minutes * 60 * 1000)
  end
end
