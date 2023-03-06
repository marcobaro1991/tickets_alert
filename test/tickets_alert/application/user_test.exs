defmodule TicketsAlert.Application.UserTest do
  @moduledoc false

  use TicketsAlert.ChannelCase

  alias TicketsAlert.Application.User, as: UserApplication
  alias TicketsAlert.Domain.User, as: UserDomain

  @user_does_not_exist_identifier "c5d82b40-11c7-4fd6-9c16-063d7020d366"

  @user_active_identifier "6dd39b15-8e58-49d2-85b4-718e36af2c6b"
  @user_active_email "baroni.marco.91+active@gmail.com"
  @user_active_password "user_active_password"

  @user_not_active_identifier "5108058f-4b35-4ffd-8308-b2e5576693ff"
  @user_not_active_email "baroni.marco.91+not_active@gmail.com"
  @user_not_active_password "user_not_active_password"

  test "get user that exist and is active" do
    @user_active_identifier
    |> UserApplication.get_by_identifier()
    |> case do
      {:ok, %UserDomain{status: :active}} -> assert true
      _ -> assert false
    end
  end

  test "get user that exist but is not active" do
    @user_not_active_identifier
    |> UserApplication.get_by_identifier()
    |> case do
      {:ok, %UserDomain{status: :not_active}} -> assert true
      _ -> assert false
    end
  end

  test "get user that does not exist" do
    @user_does_not_exist_identifier
    |> UserApplication.get_by_identifier()
    |> case do
      {:error, nil} -> assert true
      _ -> assert false
    end
  end

  test "get ony active user, happy path" do
    @user_active_identifier
    |> UserApplication.get_active_by_identifier()
    |> case do
      {:ok, %UserDomain{}} -> assert true
      _ -> assert false
    end
  end

  test "get only active user, not found" do
    @user_not_active_identifier
    |> UserApplication.get_active_by_identifier()
    |> case do
      {:error, nil} -> assert true
      _ -> assert false
    end
  end

  test "get only active user that does not exist" do
    @user_does_not_exist_identifier
    |> UserApplication.get_active_by_identifier()
    |> case do
      {:error, nil} -> assert true
      _ -> assert false
    end
  end

  test "login happy path" do
    @user_active_email
    |> UserApplication.login(@user_active_password)
    |> case do
      {:ok, _token} -> assert true
      _ -> assert false
    end
  end

  test "login error, the user exist and is active but the password is wrong" do
    @user_active_email
    |> UserApplication.login("wrong-password")
    |> case do
      {:error, _} -> assert true
      _ -> assert false
    end
  end

  test "login error, error expected cause the user is not active" do
    @user_not_active_email
    |> UserApplication.login(@user_not_active_password)
    |> case do
      {:error, _} -> assert true
      _ -> assert false
    end
  end

  test "login error, user does not exist" do
    "user-email-does-not-exist@gmail.com"
    |> UserApplication.login("password-of-user-that-does-not-exist")
    |> case do
      {:error, _error} -> assert true
      _ -> assert false
    end
  end

  test "logout happy path" do
    with {:ok, token} <- UserApplication.login(@user_active_email, @user_active_password),
         {:ok, message} <- UserApplication.logout(token) do
      assert true
    else
      _ -> assert false
    end
  end

  test "logout with token that does not exist" do
    "token-that-does-not-exist"
    |> UserApplication.logout()
    |> case do
      {:error, _error} -> assert true
      _ -> assert false
    end
  end

  test "logout error, use a token already used for logged out" do
    with {:ok, token} <- UserApplication.login(@user_active_email, @user_active_password),
         {:ok, _message} <- UserApplication.logout(token),
         {:error, _error} <- UserApplication.logout(token) do
      assert true
    else
      _ -> assert false
    end
  end
end
