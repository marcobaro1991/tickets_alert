defmodule TicketsAlert.Application.Token do
  @moduledoc false

  use Timex

  alias TicketsAlert.Repo
  alias TicketsAlert.Schema.Token, as: TokenSchema
  alias TicketsAlert.Redis.Redis, as: RedisClient
  alias TicketsAlert.Domain.Token, as: TokenDomain
  alias TicketsAlert.Domain.Jwt, as: JwtDomain
  alias Noether.Either

  @spec save(JwtDomain.t() | nil) :: {:ok, TokenSchema.t()} | {:error, nil}
  def save(%JwtDomain{value: token, config: %{jti: jti, sub: sub, iat: iat, exp: exp}}) do
    save(token, jti, sub, iat, exp)
  end

  def save(nil) do
    {:error, nil}
  end

  @spec save(String.t(), String.t(), String.t(), DateTime.t(), DateTime.t()) :: {:ok, TokenSchema.t()} | {:error, nil}
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
      {:ok, res = %TokenSchema{}} -> {:ok, res}
      _ -> {:error, nil}
    end
  end

  @spec is_blacklisted?(TokenDomain.t()) :: boolean()
  def is_blacklisted?(%TokenDomain{identifier: identifier}) do
    identifier
    |> RedisClient.get()
    |> Either.unwrap()
    |> case do
      nil -> false
      _ -> true
    end
  end

  @spec set_to_blacklist(TokenDomain.t()) :: {:ok, String.t()} | {:error, atom()}
  def set_to_blacklist(%TokenDomain{identifier: identifier, value: value, exp: exp}) do
    with ttl <- DateTime.to_unix(exp),
         {:ok, _} <- RedisClient.save(identifier, value, ttl) do
      {:ok, "success of logged out"}
    else
      _ -> {:error, :unknown}
    end
  end

  @spec get_by_value(String.t()) :: {:ok, TokenDomain.t()} | {:error, nil}
  def get_by_value(token) do
    TokenSchema
    |> TokenSchema.get_by_value(token)
    |> Repo.one()
    |> TokenDomain.new()
    |> case do
      token_domain = %TokenDomain{} -> {:ok, token_domain}
      _ -> {:error, nil}
    end
  end

  @spec is_expired?(TokenDomain.t()) :: boolean()
  def is_expired?(%TokenDomain{exp: exp}) do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
    |> DateTime.compare(exp)
    |> case do
      :lt -> false
      _ -> true
    end
  end
end
