defmodule TicketsAlert.Schema.Token do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  import Ecto.Query

  @required_fields [:identifier, :owner, :value, :created_at, :exp]

  @type t() :: %__MODULE__{}

  schema "tokens" do
    field :identifier, :string
    field :owner, :string
    field :value, :string
    field :created_at, :utc_datetime
    field :exp, :utc_datetime
  end

  def changeset(token, data) do
    token
    |> cast(data, @required_fields)
    |> validate_required(@required_fields)
  end

  def get_by_value(query \\ __MODULE__, value) do
    from u in query,
      where: u.value == ^value,
      limit: 1
  end
end
