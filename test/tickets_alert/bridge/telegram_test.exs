defmodule TicketsAlert.Bridge.TelegramTest do
  @moduledoc false

  use TicketsAlert.ChannelCase
  alias TicketsAlert.Bridge.Telegram, as: TelegramBridge

  test "Telegram send message success" do
    assert :ok == TelegramBridge.send_message_to_channel("message txt ok")
  end

  test "Telegram send message error" do
    assert :error == TelegramBridge.send_message_to_channel("message with error response")
  end
end
