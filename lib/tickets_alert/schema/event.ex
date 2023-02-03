defmodule TicketsAlert.Schema.Event do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias TicketsAlert.Schema.Offer, as: Offer

  @type t() :: %__MODULE__{}

  @required_fields [:identifier, :external_identifier, :title, :date]
  @optional_fields []

  schema "events" do
    field :identifier, :string
    field :external_identifier, :string
    field :title, :string
    field :date, :date
    field :provider, Ecto.Enum, values: [:fansale, :other]
    field :enabled, :boolean
    has_many :offers, Offer
    timestamps()
  end

  def get_by_identifier(query, identifier) do
    from e in query,
      where: e.identifier == ^identifier
  end

  def get_by_external_identifier(query, external_identifier) do
    from e in query,
      where: e.external_identifier == ^external_identifier
  end

  def get_all_valid(query, current_date) do
    from e in query,
      where: e.date > ^current_date and e.enabled == true
  end

  def get_all_fansale_valid(query, current_date) do
    from e in query,
      where: e.date > ^current_date and e.enabled == true and e.provider == :fansale
  end

  def update_changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
