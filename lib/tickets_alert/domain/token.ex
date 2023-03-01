defmodule TicketsAlert.Domain.Token do
  @moduledoc false

  alias TicketsAlert.Schema.Token, as: TokenSchema

  defstruct [
    :value,
    :jti,
    :sub,
    :exp
  ]

  @type t :: %__MODULE__{
          value: String.t(),
          jti: String.t(),
          sub: String.t(),
          exp: Date.t()
        }

  @spec new(TokenSchema.t()) :: nil | t()
  def new(%TokenSchema{
        value: value,
        jti: jti,
        sub: sub,
        exp: exp
      }) do
    %__MODULE__{
      value: value,
      jti: jti,
      sub: sub,
      exp: exp
    }
  end

  def new(_) do
    nil
  end
end
