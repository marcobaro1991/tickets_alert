defmodule TicketsAlert.Domain.Offer do
  @moduledoc false

  require Logger

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
      identifier: UUID.binary_to_string!(identifier),
      external_identifier: external_identifier,
      data: data,
      event_id: event_id
    }
  end

  def new(data) do
    Logger.error("Offer new error ", reason: inspect(data))
    nil
  end
end
