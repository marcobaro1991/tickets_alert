defmodule TicketsAlert.Bridge.FansaleTest do
  @moduledoc false

  use TicketsAlert.ChannelCase

  alias Noether.Either
  alias TicketsAlert.Bridge.Fansale, as: FansaleBridge

  test "Fansale send offers request success" do
    assert "happy_group_event_id" |> FansaleBridge.get_offers() |> Either.unwrap() |> length() == 2
  end

  test "Fansale send offers request error" do
    assert "error_group_event_id" |> FansaleBridge.get_offers() |> Either.error?() == true
  end
end
