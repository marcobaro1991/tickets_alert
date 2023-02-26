defmodule TicketsAlert.Support.TelegramMock do
  @moduledoc nil

  use Plug.Router

  plug :match
  plug :dispatch

  alias Noether.Either

  @base __DIR__ <> "/telegram"

  post "/bot:token/sendMessage" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    body
    |> Jason.decode(keys: :atoms)
    |> Either.unwrap()
    |> handle_response(conn)
  end

  defp handle_response(
         %{
           chat_id: _chat_id,
           disable_web_page_preview: _disable_web_page_preview,
           parse_mode: _parse_mode,
           text: "message with error response"
         },
         conn
       ) do
    send_resp(conn, 500, "")
  end

  defp handle_response(_, conn) do
    case File.read(@base <> "/send_message_response_ok.json") do
      {:ok, content} -> send_resp(conn, 200, content)
      {:error, :enoent} -> nil
    end
  end
end
