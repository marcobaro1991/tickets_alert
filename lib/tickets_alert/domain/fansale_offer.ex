defmodule TicketsAlert.Domain.FansaleOffer do
  @moduledoc false

  require Logger

  defstruct [
    :id,
    :initial_offer_url,
    :evdetails_seat_description_html,
    :current_price,
    :ticket_block_row_seat_groups,
    :tickets
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          initial_offer_url: String.t(),
          evdetails_seat_description_html: String.t(),
          current_price: float(),
          ticket_block_row_seat_groups: [map()],
          tickets: [map()]
        }

  @spec new(map() | any()) :: nil | t()
  def new(%{
        id: id,
        initialOfferUrl: initial_offer_url,
        evdetailsSeatDescriptionHtml: evdetails_seat_description_html,
        currentPrice: current_price,
        ticketBlockRowSeatGroups: ticket_block_row_seat_groups,
        tickets: tickets
      }),
      do: %__MODULE__{
        id: "#{id}",
        initial_offer_url: initial_offer_url,
        evdetails_seat_description_html: evdetails_seat_description_html,
        current_price: current_price,
        ticket_block_row_seat_groups: ticket_block_row_seat_groups,
        tickets: tickets
      }

  def new(data) do
    Logger.error("Fansale offer new error ", reason: inspect(data))
    nil
  end
end
