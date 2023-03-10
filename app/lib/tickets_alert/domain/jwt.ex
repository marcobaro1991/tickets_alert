defmodule TicketsAlert.Domain.Jwt do
  @moduledoc false

  defstruct [
    :value,
    :config
  ]

  @type t :: %__MODULE__{
          value: String.t(),
          config: config()
        }

  @type config :: %{
          jti: String.t(),
          sub: String.t(),
          iat: DateTime.t(),
          exp: DateTime.t()
        }

  def new(value, %{jti: jti, sub: sub, iat: iat, exp: exp}) do
    %__MODULE__{
      value: value,
      config: %{
        jti: jti,
        sub: sub,
        iat: DateTime.from_unix!(iat),
        exp: DateTime.from_unix!(exp)
      }
    }
  end

  def new(_, _) do
    nil
  end
end
