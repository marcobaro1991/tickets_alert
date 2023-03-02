defmodule TicketsAlert.Application.Token do
  @moduledoc false

  use Timex

  alias TicketsAlert.Repo
  alias TicketsAlert.Schema.Token, as: TokenSchema
  alias TicketsAlert.Application.Jwt, as: JwtApplication
  alias TicketsAlert.Redis.Redis, as: RedisClient
  alias TicketsAlert.Domain.Token, as: TokenDomain
  alias TicketsAlert.Domain.Jwt, as: JwtDomain
  alias TicketsAlert.Domain.User, as: UserDomain
  alias TicketsAlert.Application.User, as: UserApplication
  alias Noether.Either

  @spec save(JwtDomain.t() | nil) :: TokenSchema.t() | nil
  def save(%JwtDomain{value: token, config: %{jti: jti, sub: sub, iat: iat, exp: exp}}) do
    save(token, jti, sub, iat, exp)
  end

  def save(nil) do
    nil
  end

  @spec save(String.t(), String.t(), String.t(), DateTime.t(), DateTime.t()) :: TokenSchema.t() | nil
  def save(value, identifier, user_identifier, created_at, exp) do
    %TokenSchema{
      identifier: UUID.string_to_binary!(identifier),
      owner: UUID.string_to_binary!(user_identifier),
      value: value,
      created_at: created_at,
      exp: exp
    }
    |> Repo.insert()
    |> case do
      {:ok, res = %TokenSchema{}} -> res
      _ -> nil
    end
  end

  @spec is_blacklisted?(String.t()) :: boolean()
  def is_blacklisted?(token) do
    with {:ok, %{"jti" => identifier}} <- JwtApplication.verify_and_validate(token, JwtApplication.get_signer()),
         {:ok, token} <- RedisClient.get(identifier) do
      token != nil
    else
      _ -> true
    end
  end

  @spec set_to_blacklist(String.t()) :: %{message: String.t()} | %{error: atom()}
  def set_to_blacklist(token) do
    with {:ok, %{"jti" => jti, "exp" => exp}} <- JwtApplication.verify_and_validate(token, JwtApplication.get_signer()),
         {:ok, _} <- RedisClient.save(jti, token, exp) do
      %{message: "success of logged out"}
    else
      _ -> %{error: :unknown}
    end
  end

  @spec get_by_value(String.t()) :: TokenDomain.t() | nil
  def get_by_value(token) do
    TokenSchema
    |> TokenSchema.get_by_value(token)
    |> Repo.one()
    |> TokenDomain.new()
  end

  @spec is_expired?(DateTime.t()) :: boolean()
  def is_expired?(token_expired_date) do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
    |> DateTime.compare(token_expired_date)
    |> case do
      :lt -> false
      _ -> true
    end
  end

  @spec get_valid_user(String.t()) :: UserDomain.t() | nil
  def get_valid_user(token) do
    with {:ok, %{"sub" => owner, "exp" => exp}} <- JwtApplication.verify_and_validate(token, JwtApplication.get_signer()),
         false <- exp |> DateTime.from_unix() |> Either.unwrap() |> is_expired?(),
         %TokenDomain{} <- get_by_value(token),
         user = %UserDomain{} <- UserApplication.get_by_identifier_and_status(owner),
         false <- is_blacklisted?(token) do
      user
    else
      _ -> nil
    end
  end
end
