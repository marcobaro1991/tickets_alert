defmodule TicketsAlert.Application.Jwt do
  @moduledoc false

  use Joken.Config

  alias TicketsAlert.Domain.User, as: UserDomain
  alias TicketsAlert.Domain.Jwt, as: JwtDomain

  @jwt_sign Application.compile_env!(:tickets_alert, :jwt)[:sign]
  @jwt_exp_days Application.compile_env!(:tickets_alert, :jwt)[:exp_days]

  @spec generate(UserDomain.t() | nil) :: {:ok, JwtDomain.t()} | {:error, nil}
  def generate(_user = %UserDomain{identifier: user_identifier}) do
    now = DateTime.utc_now()
    jti = UUID.uuid4()
    exp = DateTime.add(now, 60 * 60 * 24 * @jwt_exp_days, :second)
    config = generate_token_config(user_identifier, jti, now, exp)

    with {:ok, token, _} <- generate_and_sign(config),
         jwt_domain = %JwtDomain{} <- JwtDomain.new(token, config) do
      {:ok, jwt_domain}
    else
      _ -> {:error, nil}
    end
  end

  def generate(_user = nil) do
    {:error, nil}
  end

  @spec is_valid_format?(String.t()) :: boolean()
  def is_valid_format?(token) do
    token
    |> verify_and_validate(get_signer())
    |> case do
      {:ok, _} -> true
      _ -> false
    end
  end

  @impl true
  def token_config do
    default_claims(skip: [:iss, :aud, :jti, :nbf, :exp, :iat])
  end

  defp get_signer do
    Joken.Signer.create(@jwt_sign, "secret")
  end

  @spec generate_token_config(String.t(), String.t(), DateTime.t(), DateTime.t()) :: map()
  defp generate_token_config(user_identifier, jti, now, exp) do
    %{}
    |> Map.put(:sub, user_identifier)
    |> Map.put(:jti, jti)
    |> Map.put(:exp, DateTime.to_unix(exp))
    |> Map.put(:iat, DateTime.to_unix(now))
  end
end
