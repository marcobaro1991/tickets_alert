defmodule TicketsAlert.Graphql.Plug.Context do
  @moduledoc """
  this plug add the user information to graphql resolver
  """

  alias Plug.Conn
  alias TicketsAlert.Domain.User, as: UserDomain
  alias TicketsAlert.Application.Token, as: TokenApplication
  alias TicketsAlert.Graphql.Plug.Helper

  @behaviour Plug

  @type user_context :: %{
          current_user: UserDomain.t() | nil,
          authorization_token: String.t() | nil
        }

  def init(opts), do: opts

  def call(conn, _) do
    user_context = conn |> get_authorization_token() |> get_user_context()

    Absinthe.Plug.put_options(conn, context: user_context)
  end

  @spec get_authorization_token(Conn.t()) :: String.t() | nil
  defp get_authorization_token(conn) do
    conn
    |> Helper.get_header("authorization")
    |> case do
      "Bearer " <> token -> token
      _ -> nil
    end
  end

  @spec get_user_context(String.t() | nil) :: user_context()
  defp get_user_context(_authorization_token = nil) do
    %{current_user: nil, authorization_token: nil}
  end

  defp get_user_context(_authorization_token = "") do
    %{current_user: nil, authorization_token: nil}
  end

  defp get_user_context(authorization_token) do
    %{
      current_user: TokenApplication.get_valid_user(authorization_token),
      authorization_token: authorization_token
    }
  end
end
