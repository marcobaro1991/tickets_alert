defmodule TicketsAlert.Domain.Offer do
  @moduledoc false

  alias TicketsAlert.Schema.Offer, as: OfferSchema

  defstruct [
    :identifier,
    :external_identifier,
    :data,
    :event_id
  ]

  @type t :: %__MODULE__{
          identifier: String.t(),
          external_identifier: String.t(),
          data: map(),
          event_id: integer()
        }

  @spec new(OfferSchema.t()) :: nil | t()
  def new(%OfferSchema{
        identifier: identifier,
        external_identifier: external_identifier,
        data: data,
        event_id: event_id
      }) do
    %__MODULE__{
      identifier: identifier,
      external_identifier: external_identifier,
      data: data,
      event_id: event_id
    }
  end

  def new(_), do: nil
end
