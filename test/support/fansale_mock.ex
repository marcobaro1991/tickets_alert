defmodule TicketsAlert.Support.FansaleMock do
  @moduledoc nil

  use Plug.Router

  plug :match
  plug :dispatch

  @base __DIR__ <> "/fansale"

  get "/fansale/json/offer" do
    {:ok, _body, %{query_string: query_string}} = Plug.Conn.read_body(conn)

    query_string
    |> URI.decode_query()
    |> handle_response(conn)
  end

  defp handle_response(
         %{
           "groupEventId" => "error_group_event_id",
           "maxResults" => _max_results,
           "dataMode" => _data_mode
         },
         conn
       ) do
    send_resp(conn, 500, "")
  end

  defp handle_response(_, conn) do
    (@base <> "/response_success.json")
    |> File.read()
    |> case do
      {:ok, content} -> send_resp(conn, 200, content)
      {:error, :enoent} -> nil
    end
  end
end
