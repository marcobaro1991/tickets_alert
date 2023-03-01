defmodule TicketsAlert.Schema.Token do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  import Ecto.Query

  @required_fields [:value, :jti, :sub, :created_at, :exp]

  @type t() :: %__MODULE__{}

  schema "tokens" do
    field :value, :string
    field :jti, :string
    field :sub, :string
    field :created_at, :utc_datetime_usec
    field :exp, :utc_datetime_usec
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
