defmodule TicketsAlert.Graphql.Types.Custom.Decimal do
  @moduledoc false

  use Absinthe.Schema.Notation

  scalar :decimal, description: "numero decimale (da non usare come float)" do
    parse(fn
      %Absinthe.Blueprint.Input.Null{} -> {:ok, nil}
      %Absinthe.Blueprint.Input.String{value: value} -> {:ok, Decimal.new(value)}
      %Absinthe.Blueprint.Input.Integer{value: value} -> {:ok, Decimal.new(value)}
      %Absinthe.Blueprint.Input.Float{value: value} -> {:ok, Decimal.from_float(value)}
    end)

    serialize(&serialize_decimal/1)
  end

  defp serialize_decimal(decimal) when is_binary(decimal), do: decimal
  defp serialize_decimal(decimal = %Decimal{}), do: Decimal.to_string(decimal)
end
