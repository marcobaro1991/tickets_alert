defmodule TicketsAlert.Graphql.Middleware.UserAuthentication do
  @moduledoc """
  this middleware allows you to check if the user who made the graphql request is properly authenticated
  via jwt token (look the resolution in the context plug)
  """

  @behaviour Absinthe.Middleware

  alias Absinthe.Resolution
  alias TicketsAlert.Domain.User, as: UserDomain

  def call(
        resolution = %Resolution{
          context: %{
            current_user: %UserDomain{},
            authorization_token: _authorization_token
          }
        },
        _config
      ) do
    resolution
  end

  def call(resolution, _config) do
    unauthenticated(resolution)
  end

  defp unauthenticated(resolution) do
    Absinthe.Resolution.put_result(resolution, {:error, "unauthenticated"})
  end
end
