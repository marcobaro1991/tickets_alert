defmodule TicketsAlert.Graphql.Plug.Context do
  @moduledoc """
  this plug add the user information to graphql resolver
  """

  alias Plug.Conn
  alias TicketsAlert.Domain.User, as: UserDomain
  alias TicketsAlert.Domain.Token, as: TokenDomain
  alias TicketsAlert.Application.Token, as: TokenApplication
  alias TicketsAlert.Application.User, as: UserApplication
  alias TicketsAlert.Application.Jwt, as: JwtApplication
  alias TicketsAlert.Graphql.Plug.Helper

  @behaviour Plug

  @type user_context :: %{
          current_user: UserDomain.t() | nil,
          authorization_token: String.t() | nil
        }

  def init(opts), do: opts

  def call(conn, _) do
    user_context = conn |> get_authorization_token() |> get_user_from_jwt()

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

  @spec get_user_from_jwt(String.t() | nil) :: user_context()
  defp get_user_from_jwt(_authorization_token = nil) do
    %{current_user: nil, authorization_token: nil}
  end

  defp get_user_from_jwt(_authorization_token = "") do
    %{current_user: nil, authorization_token: nil}
  end

  defp get_user_from_jwt(authorization_token) do
    with true <- JwtApplication.is_valid_format?(authorization_token),
         {:ok, token_domain = %TokenDomain{owner: owner}} <- TokenApplication.get_by_value(authorization_token),
         false <- TokenApplication.is_expired?(token_domain),
         false <- TokenApplication.is_blacklisted?(token_domain),
         {:ok, user_domain = %UserDomain{}} <- UserApplication.get_active_by_identifier(owner) do
      %{current_user: user_domain, authorization_token: authorization_token}
    else
      _ -> %{current_user: nil, authorization_token: authorization_token}
    end
  end
end
