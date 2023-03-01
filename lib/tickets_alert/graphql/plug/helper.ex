defmodule TicketsAlert.Graphql.Plug.Helper do
  @moduledoc """
  Conn utility functions
  """

  def get_header(conn, header_name) do
    conn
    |> Plug.Conn.get_req_header(header_name)
    |> case do
      [value] -> value
      _ -> nil
    end
  end
end
