defmodule TicketsAlert.Bridge.Fansale do
  @moduledoc """
  Fansale bridge
  """

  alias TicketsAlert.Domain.FansaleOffer, as: FansaleOfferDomain
  alias Noether.Either

  require Logger

  @spec get_offers(String.t()) :: {:ok, [FansaleOfferDomain.t()]} | {:error, any()}
  def get_offers(group_event_id) do
    url = build_url("#{base_url()}/fansale/json/offer", groupEventId: group_event_id)

    headers = [
      {"User-Agent", "Mozilla/5.0 (X11; Linux x86_64)"},
      {"Accept", "application/json"},
      {"Accept-Language", "it-IT,it;q=0.8,en-US;q=0.5,en;q=0.3"},
      {"Accept-Encoding", "gzip, deflate, br"},
      {"Connection", "keep-alive"},
      {"Upgrade-Insecure-Requests", "1"},
      {"Sec-Fetch-Dest", "document"},
      {"Sec-Fetch-Mode", "navigate"},
      {"Sec-Fetch-Site", "none"},
      {"Sec-Fetch-User", "?1"},
      {"Pragma", "no-cache"},
      {"Cache-Control", "no-cache"},
      {"X-Requested-With", "XMLHttpRequest"}
    ]

    url
    |> HTTPoison.get(headers, timeout: 30_000, recv_timeout: 30_000)
    |> IO.inspect(label: "fansale response")
    |> case do
      {:ok, %{status_code: 200, body: body}} ->
        Logger.info("Fansale api call success for group event id: #{group_event_id}", reason: inspect(body))
        body

      error ->
        Logger.error("Fansale api call error for group event id: #{group_event_id}", reason: inspect(error))
        ":error"
    end
    |> Jason.decode(keys: :atoms)
    |> case do
      {:ok, response} ->
        response
        |> Map.get(:offers, [])
        |> Enum.map(&FansaleOfferDomain.new(&1))
        |> Enum.reject(&is_nil(&1))
        |> Either.wrap()

      error ->
        Logger.error("Fansale api decode error for group event id: #{group_event_id}", reason: inspect(error))
        {:error, nil}
    end
  end

  @spec build_url(String.t(), Keyword.t()) :: String.t()
  defp build_url(url, options) do
    query =
      options
      |> Keyword.put(:maxResults, 2500)
      |> Keyword.put(:dataMode, "evdetails")
      |> URI.encode_query()

    "#{url}?#{query}"
  end

  defp base_url, do: Env.fetch!(:tickets_alert, :fansale)[:base_url]
end
