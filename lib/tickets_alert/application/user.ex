defmodule TicketsAlert.Application.User do
  @moduledoc false

  use Timex

  alias TicketsAlert.Repo

  alias TicketsAlert.Application.Jwt, as: JwtApplication
  alias TicketsAlert.Domain.User, as: UserDomain
  alias TicketsAlert.Schema.User, as: UserSchema
  alias TicketsAlert.Schema.Token, as: TokenSchema

  require Logger

  @spec login(String.t(), String.t()) ::
          %{token: String.t(), identifier: String.t()} | %{error: atom()}
  def login(email, password) do
    UserSchema
    |> UserSchema.get_by_email_and_password(email, encode_password(password), :active)
    |> Repo.one()
    |> JwtApplication.generate_jwt()
  end

  @spec logout(String.t()) :: %{message: String.t()} | %{error: atom()}
  def logout(token) do
    token
    |> JwtApplication.get_by_value()
    |> case do
      %TokenSchema{} -> JwtApplication.set_to_blacklist(token)
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

  @spec get_by_identifier_and_status(String.t(), atom()) :: UserDomain.t() | nil
  def get_by_identifier_and_status(identifier, status \\ :active) do
    UserSchema
    |> UserSchema.get_by_identifier_and_status(UUID.string_to_binary!(identifier), status)
    |> Repo.one()
    |> UserDomain.new()
  end

  @spec encode_password(String.t()) :: String.t()
  def encode_password(password) do
    :md5
    |> :crypto.hash(password)
    |> Base.encode64()
  end
end
