defmodule TicketsAlert.Application.Event do
  @moduledoc false
  alias TicketsAlert.Repo
  alias TicketsAlert.Schema.Event, as: EventSchema
  alias TicketsAlert.Domain.Event, as: EventDomain

  require Logger

  @spec get_all_valid :: [EventDomain.t()]
  def get_all_valid do
    current_date = DateTime.to_date(DateTime.utc_now())

    EventSchema
    |> EventSchema.get_all_valid(current_date)
    |> Repo.all()
    |> Repo.preload(:offers)
    |> Enum.map(&EventDomain.new(&1))
    |> Enum.reject(&is_nil(&1))
  end

  @spec get_by_identifier(String.t()) :: {:ok, EventDomain.t()} | {:error, :not_found}
  def get_by_identifier(identifier) do
    EventSchema
    |> EventSchema.get_by_identifier(UUID.string_to_binary!(identifier))
    |> Repo.one()
    |> Repo.preload(:offers)
    |> EventDomain.new()
    |> case do
      %EventDomain{} = event -> {:ok, event}
      _ -> {:error, :not_found}
    end
  end

  @spec still_valid?(String.t()) :: boolean()
  def still_valid?(identifier) do
    identifier
    |> get_by_identifier()
    |> case do
      {:ok, %EventDomain{date: event_date, enabled: enabled}} -> !is_expired?(event_date) && enabled
      _ -> false
    end
  end

  @spec is_expired?(Date.t()) :: boolean()
  defp is_expired?(event_date) do
    DateTime.utc_now()
    |> DateTime.to_date()
    |> Date.compare(event_date)
    |> case do
      :lt -> false
      :eq -> true
      :gt -> true
    end
  end
end
