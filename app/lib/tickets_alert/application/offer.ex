defmodule TicketsAlert.Application.Offer do
  @moduledoc false

  alias TicketsAlert.Repo
  alias TicketsAlert.Domain.Offer, as: OfferDomain
  alias TicketsAlert.Schema.Offer, as: OfferSchema

  @spec get_by_external_identifier_and_event_id(String.t(), integer()) :: {:ok, OfferDomain.t()} | {:error, :offer_not_found}
  def get_by_external_identifier_and_event_id(external_identifier, event_id) do
    OfferSchema
    |> OfferSchema.get_by_external_identifier_and_event_id(external_identifier, event_id)
    |> Repo.one()
    |> OfferDomain.new()
    |> case do
      %OfferDomain{} = offer -> {:ok, offer}
      _ -> {:error, :offer_not_found}
    end
  end

  @spec save_offer(OfferSchema.t()) :: {:ok, OfferDomain.t()} | {:error, nil}
  def save_offer(offer = %OfferSchema{}) do
    offer
    |> Repo.insert()
    |> case do
      {:ok, res} -> OfferDomain.new(res)
      {_, _err} -> nil
    end
    |> case do
      offer_domain = %OfferDomain{} -> {:ok, offer_domain}
      _ -> {:error, nil}
    end
  end
end
