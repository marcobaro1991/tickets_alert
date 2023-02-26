defmodule TicketsAlert.Application.FansaleEvent do
  @moduledoc false

  require Logger

  alias TicketsAlert.Domain.Event, as: EventDomain
  alias TicketsAlert.Application.Event, as: EventApplication
  alias TicketsAlert.Application.Offer, as: OfferApplication
  alias TicketsAlert.Bridge.Fansale, as: FansaleBridge
  alias TicketsAlert.Domain.FansaleOffer, as: FansaleOfferDomain
  alias TicketsAlert.Domain.Offer, as: OfferDomain
  alias TicketsAlert.Schema.Offer, as: OfferSchema
  alias TicketsAlert.Bridge.Telegram, as: TelegramBridge

  @spec check(String.t()) :: :ok | :error
  def check(event_identifier) do
    with true <- EventApplication.still_valid?(event_identifier),
         {:ok, %EventDomain{title: event_title, id: event_id, external_identifier: event_external_identifier}} <- EventApplication.get_by_identifier(event_identifier),
         {:ok, fansale_offers} <- FansaleBridge.get_offers(event_external_identifier),
         new_fansale_offers <- reject_already_stored_offer(fansale_offers, event_id),
         new_stored_offers <- save_offers(new_fansale_offers, event_id) do
      send_telegram_messages(new_stored_offers, event_title)
    else
      error -> handle_error(error, event_identifier)
    end
  end

  @spec reject_already_stored_offer([FansaleOfferDomain.t()], integer()) :: [FansaleOfferDomain.t()]
  defp reject_already_stored_offer(fansale_offers, event_id) do
    Enum.reject(fansale_offers, fn %FansaleOfferDomain{id: fansale_offer_id} ->
      "#{fansale_offer_id}"
      |> OfferApplication.get_by_external_identifier_and_event_id(event_id)
      |> case do
        {:ok, %OfferDomain{}} -> true
        _ -> false
      end
    end)
  end

  @spec save_offers([FansaleOfferDomain.t()], integer()) :: list()
  defp save_offers(new_fansale_offers, event_id) do
    new_fansale_offers
    |> Enum.map(fn fansale_offer = %FansaleOfferDomain{} ->
      fansale_offer
      |> from_fansale_domain_to_offer_schema(event_id)
      |> OfferApplication.save_offer()
    end)
    |> Enum.reject(&is_nil(&1))
  end

  @spec from_fansale_domain_to_offer_schema(FansaleOfferDomain.t(), integer()) :: OfferSchema.t()
  defp from_fansale_domain_to_offer_schema(fansale_offer = %FansaleOfferDomain{}, event_id) do
    %OfferSchema{
      identifier: UUID.string_to_binary!(UUID.uuid4()),
      external_identifier: Map.get(fansale_offer, :id),
      data: %{
        initial_offer_url: Map.get(fansale_offer, :initial_offer_url),
        evdetails_seat_description_html: Map.get(fansale_offer, :evdetails_seat_description_html),
        current_price: Map.get(fansale_offer, :current_price),
        ticket_block_row_seat_groups: Map.get(fansale_offer, :ticket_block_row_seat_groups),
        tickets: Map.get(fansale_offer, :tickets)
      },
      event_id: event_id
    }
  end

  @spec handle_error(boolean() | tuple(), String.t()) :: atom()
  defp handle_error(false, event_identifier) do
    Logger.error("event not valid #{event_identifier}")
    :error
  end

  defp handle_error({:error, :not_found}, event_identifier) do
    Logger.error("event not found #{event_identifier}")
    :error
  end

  defp handle_error({:error, error}, _event_identifier) do
    Logger.error("generic error", reason: inspect(error))
    :error
  end

  @spec build_telegram_message(OfferDomain.t(), String.t()) :: String.t()
  defp build_telegram_message(
         %OfferDomain{
           data: %{
             current_price: current_price,
             evdetails_seat_description_html: evdetails_seat_description_html,
             initial_offer_url: initial_offer_url
           }
         },
         event_title
       ) do
    "<b>#{event_title}</b>\n<a href='https://www.fansale.it#{initial_offer_url}'>#{evdetails_seat_description_html} : #{current_price} €</a>\n"
  end

  @spec send_telegram_messages([OfferDomain.t()], String.t()) :: :ok | :error
  defp send_telegram_messages(new_stored_offers, event_title) do
    new_stored_offers
    |> Enum.map(fn stored_offer = %OfferDomain{} ->
      stored_offer
      |> build_telegram_message(event_title)
      |> TelegramBridge.send_message_to_channel()
    end)
    |> Enum.any?(fn res -> res == :error end)
    |> case do
      true -> :error
      false -> :ok
    end
  end
end
