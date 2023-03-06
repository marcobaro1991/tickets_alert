defmodule TicketsAlert.Graphql.UserTest do
  use ExUnit.Case

  alias TicketsAlert.Graphql.Schema

  alias TicketsAlert.Application.Jwt, as: JwtApplication

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
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TicketsAlert.Repo)
  end

  describe "Login" do
    test "succeed", _context do
      assert {:ok, %{data: %{"login" => %{"__typename" => "LoginSuccess"}}}} =
               Absinthe.run(
                 @login_mutation,
                 Schema,
                 context: nil,
                 variables: @user_active_credentials
               )
    end

    test "failed, the user is not active", _context do
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
                 context: nil,
                 variables: @user_not_active_credentials
               )
    end

    test "failed, the user does not exist", _context do
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
                 context: nil,
                 variables: @user_does_not_exist_credentials
               )
    end

    test "succeed, check token validity", _context do
      {:ok, %{data: %{"login" => %{"token" => token}}}} =
        Absinthe.run(
          @login_mutation,
          Schema,
          context: nil,
          variables: @user_active_credentials
        )

      assert true == JwtApplication.is_valid_format?(token)
    end
  end
end
