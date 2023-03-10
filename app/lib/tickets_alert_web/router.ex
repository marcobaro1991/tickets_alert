defmodule TicketsAlertWeb.Router do
  use TicketsAlertWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TicketsAlertWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug CORSPlug
    plug :accepts, ["json"]
    plug TicketsAlert.Graphql.Plug.Context
  end

  scope "/", TicketsAlertWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TicketsAlertWeb.Telemetry
    end
  end

  scope "/graphql" do
    pipe_through :graphql

    forward "/", Absinthe.Plug, schema: TicketsAlert.Graphql.Schema, json_codec: Jason
  end
end
