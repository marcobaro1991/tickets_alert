defmodule TicketsAlert.Graphql.Types.User do
  @moduledoc false

  use Absinthe.Schema.Notation

  alias TicketsAlert.Graphql.Resolver.User
  alias TicketsAlert.Graphql.Middleware.UserAuthentication

  object :user_queries do
  end

  object :user_mutations do
    field :login, non_null(:login_response) do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      resolve(&User.login/2)
    end

    field :logout, non_null(:logout_response) do
      middleware(UserAuthentication)
      resolve(&User.logout/2)
    end
  end

  union :login_response do
    types([:login_success, :login_failure])

    resolve_type(fn
      %{token: _}, _ -> :login_success
      %{error: _}, _ -> :login_failure
    end)
  end

  union :logout_response do
    types([:logout_success, :logout_failure])

    resolve_type(fn
      %{message: _}, _ -> :logout_success
      _, _ -> :logout_failure
    end)
  end

  object :login_success, is_type_of: :login_response do
    field :token, non_null(:string)
    field :identifier, non_null(:string)
  end

  object :login_failure, is_type_of: :login_response do
    field :error, non_null(:login_error)
  end

  object :logout_success, is_type_of: :logout_response do
    field :message, non_null(:string)
  end

  object :logout_failure, is_type_of: :logout_response do
    field :error, non_null(:logout_error)
  end

  enum :login_error do
    value(:already_logged_in)
    value(:wrong_credential)
    value(:unknown)
  end

  enum :logout_error do
    value(:token_not_stored)
    value(:unknown)
  end
end
