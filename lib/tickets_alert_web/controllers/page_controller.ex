defmodule TicketsAlertWeb.PageController do
  use TicketsAlertWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
