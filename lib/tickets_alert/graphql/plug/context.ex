defmodule TicketsAlert.Graphql.Plug.Context do
  @moduledoc """
  this plug add the user information to graphql resolver
  """

  alias TicketsAlert.Domain.User, as: UserDomain
  alias TicketsAlert.Domain.Token, as: TokenDomain
  alias TicketsAlert.Application.User, as: UserApplication
  alias TicketsAlert.Application.Token, as: TokenApplication
  alias TicketsAlert.Graphql.Plug.Helper
  alias TicketsAlert.Token, as: Token

  alias Noether.Either

  @behaviour Plug

  @jwt_sign Application.compile_env!(:tickets_alert, :jwt)[:sign]

  @type user_context :: %{
          current_user: UserDomain.t() | nil,
          authorization_token: String.t() | nil
        }

  def init(opts), do: opts

  def call(conn, _) do
    context = conn |> get_authorization_token() |> get_user_from_token()

    Absinthe.Plug.put_options(conn, context: context)
  end

  @spec get_authorization_token(any()) :: String.t() | nil
  defp get_authorization_token(conn) do
    conn
    |> Helper.get_header("authorization")
    |> case do
      "Bearer " <> token -> token
      _ -> nil
    end
  end

  @spec get_user_from_token(String.t() | nil) :: user_context()
  defp get_user_from_token(nil), do: user_not_valid()

  defp get_user_from_token(token) do
    signer = Joken.Signer.create(@jwt_sign, "secret")

    with {:ok, %{"sub" => sub, "exp" => exp}} <- Token.verify_and_validate(token, signer),
         false <- exp |> DateTime.from_unix() |> Either.unwrap() |> token_is_expired?(),
         %TokenDomain{} <- TokenApplication.get_by_value(token),
         user = %UserDomain{} <- UserApplication.get_by_identifier_and_status(sub),
         false <- TokenApplication.is_blacklisted(token) do
      %{
        current_user: user,
        authorization_token: token
      }
    else
      _ -> user_not_valid(token)
    end
  end

  @spec token_is_expired?(any()) :: boolean()
  defp token_is_expired?(token_expired_date) do
    now = DateTime.truncate(DateTime.utc_now(), :second)

    case DateTime.compare(now, token_expired_date) do
      :lt -> false
      _ -> true
    end
  end

  defp user_not_valid do
    user_not_valid(nil)
  end

  defp user_not_valid(token) do
    %{current_user: nil, authorization_token: token}
  end
end
