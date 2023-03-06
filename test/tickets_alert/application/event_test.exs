defmodule TicketsAlert.Application.EventTest do
  @moduledoc false

  use TicketsAlert.ChannelCase

  alias TicketsAlert.Application.Event, as: EventApplication
  alias TicketsAlert.Domain.Event, as: EventDomain

  @fansale_expired_event_identifier "97ea8c69-daca-4dbe-9ca1-7682410653d4"
  @fansale_disabled_event_identifier "f92691fe-18ff-4a41-b4c3-a1d453433ec5"
  @fansale_not_valid_event_identifier "10577cdd-54d3-44a2-a412-c7bd1e6a2bf9"
  @fansale_valid_event_identifier "96c547c4-fd6c-4a94-a009-1e28c4901b14"
  @fansale_expired_today_event_identifier "b02c2941-c952-416a-a74b-191afa2f8ced"

  test "Fetch all valid offers success" do
    events = EventApplication.get_all_valid()

    events_wrong_domain =
      Enum.any?(events, fn event ->
        case event do
          %EventDomain{} -> false
          _ -> true
        end
      end)

    assert length(events) == 1

    assert false == events_wrong_domain
  end

  test "check if event that is expired is still valid" do
    assert EventApplication.is_still_valid?(@fansale_expired_event_identifier) == false
  end

  test "check if event that is expiring today is still valid" do
    assert EventApplication.is_still_valid?(@fansale_expired_today_event_identifier) == false
  end

  test "check if event that is disabled is still valid" do
    assert EventApplication.is_still_valid?(@fansale_disabled_event_identifier) == false
  end

  test "check if event is correctly not valid" do
    assert EventApplication.is_still_valid?(@fansale_not_valid_event_identifier) == false
  end

  test "check if event is correctly valid" do
    assert EventApplication.is_still_valid?(@fansale_valid_event_identifier) == true
  end

  test "verify event domain from valid event" do
    @fansale_valid_event_identifier
    |> EventApplication.get_by_identifier()
    |> case do
      {:ok, %EventDomain{}} -> assert true
      _ -> assert false
    end
  end

  test "verify event domain from event that does not exist" do
    "f8370e45-8d12-4dd0-8d73-78d92fce745f"
    |> EventApplication.get_by_identifier()
    |> case do
      {:ok, %EventDomain{}} -> assert false
      _ -> assert true
    end
  end
end
