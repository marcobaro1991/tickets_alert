defmodule TicketsAlert.Application.Jwt do
  @moduledoc false

  use Timex

  alias TicketsAlert.Repo
  alias TicketsAlert.Schema.Token, as: TokenSchema
  alias TicketsAlert.Schema.User, as: UserSchema
  alias TicketsAlert.Token, as: Token
  alias TicketsAlert.Redis.Redis, as: RedisClient

  @type token_config :: %{
          :sub => binary(),
          :jti => binary(),
          :exp => integer(),
          :iat => integer()
        }

  @jwt_sign Application.compile_env!(:tickets_alert, :jwt)[:sign]

  @jwt_exp_days Application.compile_env!(:tickets_alert, :jwt)[:exp_days]

  @spec generate_jwt(nil | UserSchema.t()) ::
          %{token: String.t(), identifier: binary()} | %{error: atom()}
  def generate_jwt(_user = nil) do
    %{error: :wrong_credential}
  end

  def generate_jwt(_user = %{identifier: user_identifier}) do
    with now <- DateTime.utc_now(),
         jti <- UUID.string_to_binary!(UUID.uuid4()),
         exp <- DateTime.add(now, 60 * 60 * 24 * @jwt_exp_days, :second),
         token_config <- generate_token_config(user_identifier, jti, now, exp),
         {:ok, token, _} <- Token.generate_and_sign(token_config),
         {:ok, %TokenSchema{}} <- save_jwt(token, jti, user_identifier, now, exp) do
      %{token: token, identifier: UUID.binary_to_string!(user_identifier)}
    else
      _ -> %{error: :unknown}
    end
  end

  @spec generate_token_config(binary(), binary(), DateTime.t(), DateTime.t()) :: token_config
  defp generate_token_config(user_identifier, jti, now, exp) do
    %{}
    |> Map.put(:sub, UUID.binary_to_string!(user_identifier))
    |> Map.put(:jti, UUID.binary_to_string!(jti))
    |> Map.put(:exp, DateTime.to_unix(exp))
    |> Map.put(:iat, DateTime.to_unix(now))
  end

  @spec save_jwt(String.t(), binary(), binary(), DateTime.t(), DateTime.t()) ::
          {:ok | :error, any()}
  defp save_jwt(token, jti, user_identifier, now, exp) do
    Repo.insert(%TokenSchema{
      value: token,
      jti: jti,
      sub: user_identifier,
      created_at: now,
      exp: exp
    })
  end

  @spec is_blacklisted(String.t()) :: boolean()
  def is_blacklisted(token) do
    with signer <- Joken.Signer.create(@jwt_sign, "secret"),
         {:ok, %{"jti" => jti}} <- Token.verify_and_validate(token, signer),
         {:ok, token} <- RedisClient.get(jti) do
      token != nil
    else
      _ -> true
    end
  end

  @spec set_to_blacklist(String.t()) :: %{message: String.t()} | %{error: atom()}
  def set_to_blacklist(token) do
    with signer <- Joken.Signer.create(@jwt_sign, "secret"),
         {:ok, %{"jti" => jti, "exp" => exp}} <- Token.verify_and_validate(token, signer),
         {:ok, _} <- RedisClient.save(jti, token, exp) do
      %{message: "success of logged out"}
    else
      _ -> %{error: :unknown}
    end
  end

  @spec get_by_value(String.t()) :: TokenSchema.t() | nil
  def get_by_value(token) do
    TokenSchema
    |> TokenSchema.get_by_value(token)
    |> Repo.one()
  end
end
