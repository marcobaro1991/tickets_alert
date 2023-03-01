defmodule TicketsAlert.Schema.User do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @type t() :: %__MODULE__{}

  @required_fields [:first_name, :last_name, :password, :email, :status, :registration_type]
  @optional_fields []

  schema "users" do
    field :identifier, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string
    field :email, :string
    field :registration_type, Ecto.Enum, values: [:default, :google]
    field :status, Ecto.Enum, values: [:active, :not_active]

    timestamps()
  end

  def get_by_email_and_password(query \\ __MODULE__, email, password, status) do
    from u in query,
      where: u.email == ^email and u.password == ^password and u.status == ^status,
      limit: 1
  end

  def get_by_identifier(query \\ __MODULE__, identifier) do
    from u in query,
      where: u.identifier == ^identifier,
      limit: 1
  end

  def get_by_identifier_and_status(query \\ __MODULE__, identifier, status) do
    from u in query,
      where: u.identifier == ^identifier and u.status == ^status,
      limit: 1
  end

  def update_changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
