defmodule TicketsAlert.Domain.Event do
  @moduledoc false

  alias TicketsAlert.Schema.Event, as: EventSchema
  alias TicketsAlert.Domain.Offer, as: OfferDomain

  defstruct [
    :id,
    :identifier,
    :external_identifier,
    :title,
    :date,
    :provider,
    :enabled,
    :offers
  ]

  @type provider :: :fansale | :other

  @type t :: %__MODULE__{
          id: integer(),
          identifier: binary(),
          external_identifier: String.t(),
          title: String.t(),
          date: Date.t(),
          provider: provider(),
          enabled: boolean(),
          offers: [OfferDomain.t()]
        }

  @spec new(EventSchema.t() | any()) :: nil | t()
  def new(%EventSchema{
        id: id,
        identifier: identifier,
        external_identifier: external_identifier,
        title: title,
        date: date,
        provider: provider,
        enabled: enabled,
        offers: offers
      }),
      do: %__MODULE__{
        id: id,
        identifier: identifier,
        external_identifier: external_identifier,
        title: title,
        date: date,
        provider: provider,
        enabled: enabled,
        offers: Enum.map(offers, &OfferDomain.new(&1))
      }

  def new(_), do: nil
end
