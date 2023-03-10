defmodule TicketsAlert.Graphql.Types.Custom.Uuid do
  @moduledoc false

  use Absinthe.Schema.Notation

  scalar :uuid, description: "uuid v4 unique identifier" do
    parse(fn
      %Absinthe.Blueprint.Input.Null{} -> {:ok, nil}
      %Absinthe.Blueprint.Input.String{value: value} -> Ecto.UUID.cast(value)
    end)

    serialize(& &1)
  end
end
