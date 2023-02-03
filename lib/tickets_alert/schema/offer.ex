defmodule TicketsAlert.Schema.Offer do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias TicketsAlert.Schema.Event, as: Event

  @type t() :: %__MODULE__{}

  @required_fields [:identifier, :external_identifier, :event_id, :data]
  @optional_fields []

  schema "offers" do
    field :identifier, :string
    field :external_identifier, :string
    field :data, :map
    belongs_to :event, Event
    timestamps()
  end

  def get_by_event_id(query, event_id) do
    from o in query,
      where: o.event_id == ^event_id
  end

  def get_by_external_identifier_and_event_id(query, external_identifier, event_id) do
    from o in query,
      where: o.external_identifier == ^external_identifier and o.event_id == ^event_id
  end

  def changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def update_changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
