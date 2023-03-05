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

  require Logger

  @spec login(String.t(), String.t()) :: %{token: String.t()} | %{error: atom()}
  def login(email, password) do
    UserSchema
    |> UserSchema.get_by_email_and_password(email, encode_password(password), :active)
    |> Repo.one()
    |> UserDomain.new()
    |> JwtApplication.generate()
    |> TokenApplication.save()
    |> case do
      %TokenSchema{value: value} -> %{token: value}
      _ -> %{error: :unknown}
    end
  end

  @spec logout(String.t()) :: %{message: String.t()} | %{error: atom()}
  def logout(token) do
    with %TokenDomain{exp: exp} <- TokenApplication.get_by_value(token),
         false <- TokenApplication.is_expired?(exp),
         false <- TokenApplication.is_blacklisted?(token) do
      TokenApplication.set_to_blacklist(token)
    else
      _ -> %{error: :token_not_stored}
    end
  end

  @spec get_by_identifier(String.t()) :: UserDomain.t() | nil
  def get_by_identifier(identifier) do
    UserSchema
    |> UserSchema.get_by_identifier(UUID.string_to_binary!(identifier))
    |> Repo.one()
    |> UserDomain.new()
  end

  @spec get_active_by_identifier(String.t()) :: UserDomain.t() | nil
  def get_active_by_identifier(identifier) do
    UserSchema
    |> UserSchema.get_active_by_identifier(UUID.string_to_binary!(identifier))
    |> Repo.one()
    |> UserDomain.new()
  end

  @spec encode_password(String.t()) :: String.t()
  defp encode_password(password) do
    :md5
    |> :crypto.hash(password)
    |> Base.encode64()
  end
end
