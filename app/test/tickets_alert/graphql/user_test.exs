defmodule TicketsAlert.Graphql.UserTest do
  use ExUnit.Case, async: false

  alias TicketsAlert.Graphql.Schema

  alias TicketsAlert.Application.Jwt, as: JwtApplication
  alias TicketsAlert.Application.User, as: UserApplication
  alias Noether.Either

  @user_active_identifier "6dd39b15-8e58-49d2-85b4-718e36af2c6b"

  @user_active_credentials %{
    "email" => "baroni.marco.91+active@gmail.com",
    "password" => "user_active_password"
  }

  @user_not_active_credentials %{
    "email" => "baroni.marco.91+not_active@gmail.com",
    "password" => "user_not_active_password"
  }

  @user_does_not_exist_credentials %{
    "email" => "baroni.marco.91+not_exist@gmail.com",
    "password" => "user_not_exist_password"
  }

  @login_mutation """
  mutation($email: String!, $password: String!)  {
    login(email: $email, password: $password) {
      __typename
      ... on LoginSuccess {
        token
      }
      ... on LoginFailure {
        error
      }
    }
  }
  """

  @logout_mutation """
  mutation {
    logout {
      __typename
      ... on LogoutSuccess {
        message
      }
      ... on LogoutFailure {
        error
      }
    }
  }
  """

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(TicketsAlert.Repo)

    {:ok,
     non_authenticated_context: %{
       current_user: nil,
       authorization_token: nil
     },
     invalid_token_context: %{
       authorization_token: "invalid_token",
       current_user: nil
     }}
  end

  describe "Login" do
    test "succeed", context do
      assert {:ok, %{data: %{"login" => %{"__typename" => "LoginSuccess"}}}} =
               Absinthe.run(
                 @login_mutation,
                 Schema,
                 context: context.non_authenticated_context,
                 variables: @user_active_credentials
               )
    end

    test "failed, the user is not active", context do
      assert {:ok,
              %{
                data: %{
                  "login" => %{
                    "__typename" => "LoginFailure",
                    "error" => "UNKNOWN"
                  }
                }
              }} =
               Absinthe.run(
                 @login_mutation,
                 Schema,
                 context: context.non_authenticated_context,
                 variables: @user_not_active_credentials
               )
    end

    test "failed, the user does not exist", context do
      assert {:ok,
              %{
                data: %{
                  "login" => %{
                    "__typename" => "LoginFailure",
                    "error" => "UNKNOWN"
                  }
                }
              }} =
               Absinthe.run(
                 @login_mutation,
                 Schema,
                 context: context.non_authenticated_context,
                 variables: @user_does_not_exist_credentials
               )
    end

    test "succeed, check token validity", context do
      {:ok, %{data: %{"login" => %{"token" => token}}}} =
        Absinthe.run(
          @login_mutation,
          Schema,
          context: context.non_authenticated_context,
          variables: @user_active_credentials
        )

      assert true == JwtApplication.is_valid_format?(token)
    end

    test "failed user is already logged in", context do
      user_domain =
        @user_active_identifier
        |> UserApplication.get_by_identifier()
        |> Either.unwrap()

      {:ok, %{data: %{"login" => %{"token" => token}}}} =
        Absinthe.run(
          @login_mutation,
          Schema,
          context: nil,
          variables: @user_active_credentials
        )

      assert {:ok, %{data: %{"login" => %{"__typename" => "LoginFailure", "error" => "ALREADY_LOGGED_IN"}}}} =
               Absinthe.run(
                 @login_mutation,
                 Schema,
                 context: %{
                   authorization_token: token,
                   current_user: user_domain
                 },
                 variables: @user_active_credentials
               )
    end
  end
end
