defmodule TicketsAlert.Domain.Token do
  @moduledoc false

  alias TicketsAlert.Schema.Token, as: TokenSchema

  defstruct [
    :identifier,
    :owner,
    :created_at,
    :value,
    :exp
  ]

  @type t :: %__MODULE__{
          identifier: String.t(),
          owner: String.t(),
          created_at: DateTime.t(),
          value: String.t(),
          exp: DateTime.t()
        }

  @spec new(TokenSchema.t()) :: nil | t()
  def new(%TokenSchema{
        identifier: identifier,
        owner: owner,
        created_at: created_at,
        value: value,
        exp: exp
      }) do
    %__MODULE__{
      identifier: UUID.binary_to_string!(identifier),
      owner: UUID.binary_to_string!(owner),
      created_at: created_at,
      value: value,
      exp: exp
    }
  end

  def new(_) do
    nil
  end
end
