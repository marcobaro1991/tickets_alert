defmodule TicketsAlert.Graphql.Plug.Helper do
  @moduledoc """
  Conn utility functions
  """
  alias Plug.Conn

  @spec get_header(Conn.t(), String.t()) :: String.t() | nil
  def get_header(conn, header_name) do
    conn
    |> Plug.Conn.get_req_header(header_name)
    |> case do
      [value] -> value
      _ -> nil
    end
  end
end
