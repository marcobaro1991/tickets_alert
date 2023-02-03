defmodule TicketsAlert.Application.EventTest do
  @moduledoc false

  use TicketsAlert.ChannelCase

  alias TicketsAlert.Application.Event, as: EventApplication

  @fansale_expired_event_identifier "97ea8c69-daca-4dbe-9ca1-7682410653d4"
  @fansale_disabled_event_identifier "f92691fe-18ff-4a41-b4c3-a1d453433ec5"
  @fansale_not_valid_event_identifier "10577cdd-54d3-44a2-a412-c7bd1e6a2bf9"
  @fansale_valid_event_identifier "96c547c4-fd6c-4a94-a009-1e28c4901b14"

  test "Fetch all valid offers success" do
    assert length(EventApplication.get_all_valid()) == 1
  end

  test "check if event that is expired is still valid" do
    assert EventApplication.still_valid?(@fansale_expired_event_identifier) == false
  end

  test "check if event that is disabled is still valid" do
    assert EventApplication.still_valid?(@fansale_disabled_event_identifier) == false
  end

  test "check if event is correctly not valid" do
    assert EventApplication.still_valid?(@fansale_not_valid_event_identifier) == false
  end

  test "check if event is correctly valid" do
    assert EventApplication.still_valid?(@fansale_valid_event_identifier) == true
  end
end
