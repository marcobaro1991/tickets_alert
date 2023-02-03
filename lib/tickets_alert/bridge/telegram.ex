defmodule TicketsAlert.Bridge.Telegram do
  @moduledoc """
  Telegram bridge
  """

  @spec send_message_to_channel(String.t()) :: :ok | :error
  def send_message_to_channel(message) do
    url = "#{base_url()}/bot#{bot_token()}/sendMessage"

    headers = [
      {"Accept", "application/json"},
      {"User-Agent", "Telegram Bot"},
      {"content-type", "application/json"}
    ]

    body =
      Jason.encode!(%{
        chat_id: channel_id(),
        text: message,
        parse_mode: "html",
        disable_web_page_preview: false
      })

    url
    |> HTTPoison.post(body, headers)
    |> case do
      {:ok, %{status_code: 200, body: _body}} -> :ok
      _ -> :error
    end
  end

  defp base_url, do: Env.fetch!(:tickets_alert, :telegram)[:base_url]

  defp bot_token, do: Env.fetch!(:tickets_alert, :telegram)[:bot_token]

  defp channel_id, do: Env.fetch!(:tickets_alert, :telegram)[:channel_id]
end
