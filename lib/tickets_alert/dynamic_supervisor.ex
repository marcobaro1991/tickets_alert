defmodule TicketsAlert.DynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor

  alias TicketsAlert.Process.FansaleEvent, as: FansaleEventProcess

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(max_children: 100, strategy: :one_for_one)
  end

  @spec start_fansale_event_process(map()) :: %{identifier: String.t(), pid: pid() | nil}
  def start_fansale_event_process(event = %{identifier: identifier}) do
    __MODULE__
    |> DynamicSupervisor.start_child(%{
      id: UUID.binary_to_string!(identifier),
      start: {FansaleEventProcess, :start_link, [event]}
    })
    |> case do
      {:ok, pid} -> %{identifier: identifier, pid: pid}
      _ -> %{identifier: identifier, pid: nil}
    end
  end

  @spec terminate_process(pid()) :: :ok | :error
  def terminate_process(pid) do
    __MODULE__
    |> DynamicSupervisor.terminate_child(pid)
    |> case do
      :ok -> :ok
      _ -> :error
    end
  end

  @spec get_child_list :: [map()]
  def get_child_list do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn _running_process = {_, pid, _, _} ->
      %{
        pid: pid,
        state: :sys.get_state(pid)
      }
    end)
  end
end
