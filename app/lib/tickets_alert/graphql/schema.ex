defmodule TicketsAlert.Graphql.Schema do
  @moduledoc false

  use Absinthe.Schema

  import_types(TicketsAlert.Graphql.Types.Custom.Date)
  import_types(TicketsAlert.Graphql.Types.Custom.Uuid)
  import_types(TicketsAlert.Graphql.Types.Custom.Decimal)
  import_types(TicketsAlert.Graphql.Types.User)

  def context(context) do
    loader = Dataloader.new()

    Map.put(context, :loader, loader)
  end

  def plugins, do: [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]

  query do
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:user_mutations)
  end
end
