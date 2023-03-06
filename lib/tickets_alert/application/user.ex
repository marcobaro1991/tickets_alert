defmodule TicketsAlert.Application.User do
  @moduledoc false

  use Timex

  alias TicketsAlert.Repo

  alias TicketsAlert.Application.Token, as: TokenApplication
  alias TicketsAlert.Application.Jwt, as: JwtApplication
  alias TicketsAlert.Domain.User, as: UserDomain
  alias TicketsAlert.Domain.Token, as: TokenDomain
  alias TicketsAlert.Schema.User, as: UserSchema
  alias TicketsAlert.Schema.Token, as: TokenSchema
  alias Noether.Either

  require Logger

  @spec login(String.t(), String.t()) :: {:ok, String.t()} | {:error, atom()}
  def login(email, password) do
    UserSchema
    |> UserSchema.get_by_email_and_password(email, encode_password(password), :active)
    |> Repo.one()
    |> UserDomain.new()
    |> JwtApplication.generate()
    |> Either.unwrap()
    |> TokenApplication.save()
    |> Either.unwrap()
    |> case do
      %TokenSchema{value: value} -> {:ok, value}
      _ -> {:error, :unknown}
    end
  end

  @spec logout(String.t()) :: {:ok, String.t()} | {:error, :token_not_stored}
  def logout(token) do
    with {:ok, token_domain = %TokenDomain{}} <- TokenApplication.get_by_value(token),
         false <- TokenApplication.is_expired?(token_domain),
         false <- TokenApplication.is_blacklisted?(token_domain) do
      token_domain
      |> TokenApplication.set_to_blacklist()
      |> case do
        {:ok, message} -> {:ok, message}
        {:error, _error} -> {:error, :token_not_stored}
      end
    else
      _ -> {:error, :token_not_stored}
    end
  end

  @spec get_by_identifier(String.t()) :: {:ok, UserDomain.t()} | {:error, nil}
  def get_by_identifier(identifier) do
    UserSchema
    |> UserSchema.get_by_identifier(UUID.string_to_binary!(identifier))
    |> Repo.one()
    |> UserDomain.new()
    |> case do
      user_domain = %UserDomain{} -> {:ok, user_domain}
      _ -> {:error, nil}
    end
  end

  @spec get_active_by_identifier(String.t()) :: {:ok, UserDomain.t()} | {:error, nil}
  def get_active_by_identifier(identifier) do
    UserSchema
    |> UserSchema.get_active_by_identifier(UUID.string_to_binary!(identifier))
    |> Repo.one()
    |> UserDomain.new()
    |> case do
      user_domain = %UserDomain{} -> {:ok, user_domain}
      _ -> {:error, nil}
    end
  end

  @spec encode_password(String.t()) :: String.t()
  defp encode_password(password) do
    :md5
    |> :crypto.hash(password)
    |> Base.encode64()
  end
end
