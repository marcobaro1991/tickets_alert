defmodule TicketsAlert.Domain.User do
  @moduledoc false

  alias TicketsAlert.Schema.User, as: UserSchema

  defstruct [
    :identifier,
    :first_name,
    :last_name,
    :password,
    :email,
    :registration_type,
    :status
  ]

  @type t :: %__MODULE__{
          identifier: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          password: String.t(),
          email: String.t(),
          registration_type: registration_type(),
          status: status()
        }

  @type registration_type :: :default | :google

  @type status :: :active | :not_active

  @spec new(UserSchema.t()) :: nil | t()
  def new(%UserSchema{
        identifier: identifier,
        first_name: first_name,
        last_name: last_name,
        password: password,
        email: email,
        registration_type: registration_type,
        status: status
      }) do
    %__MODULE__{
      identifier: identifier,
      first_name: first_name,
      last_name: last_name,
      password: password,
      email: email,
      registration_type: registration_type,
      status: status
    }
  end

  def new(_) do
    nil
  end
end
