defmodule TicketsAlert.Graphql.Resolver.User do
  @moduledoc false

  alias TicketsAlert.Application.User, as: UserApplication

  alias Absinthe.Resolution

  alias TicketsAlert.Domain.User, as: UserDomain

  @spec login(map(), any()) ::
          {:ok, %{token: String.t(), identifier: String.t()} | %{error: atom()}}
  def login(_args, %Resolution{
        context: %{
          current_user: %UserDomain{identifier: _user_identifier},
          authorization_token: _authorization_token
        }
      }) do
    {:ok, %{error: :already_logged_in}}
  end

  def login(%{email: email, password: password}, _info) do
    email
    |> UserApplication.login(password)
    |> case do
      {:ok, token} -> {:ok, %{token: token}}
      {:error, error} -> {:ok, %{error: error}}
    end
  end

  @spec logout(map(), any()) :: {:ok, %{message: String.t()}} | {:ok, %{error: :token_not_stored}}
  def logout(_, %Resolution{
        context: %{
          current_user: %UserDomain{identifier: _user_identifier},
          authorization_token: authorization_token
        }
      }) do
    authorization_token
    |> UserApplication.logout()
    |> case do
      {:ok, message} -> {:ok, %{message: message}}
      {:error, :token_not_stored} -> {:ok, %{error: :token_not_stored}}
    end
  end
end
