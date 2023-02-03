defmodule TicketsAlert.Token do
  @moduledoc false

  use Joken.Config

  @impl true
  def token_config do
    # iss: name of the service
    # iat: timestamp of creation of the JWT
    # sub: identifier of the user
    # exp: expiration on the token timestamp

    claims = default_claims(skip: [:iss, :aud, :jti, :nbf, :exp, :iat])

    add_claim(claims, "iss", fn -> "auth_service" end, &(&1 == "auth_service"))
  end
end
