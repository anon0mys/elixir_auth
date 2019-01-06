defmodule Odyssey.AccountsTest do
  use Odyssey.DataCase

  alias Odyssey.Accounts

  describe "accounts" do
    alias Odyssey.Accounts.User

    @valid_attrs %{
      name: "Test User",
      email: "user@test.com",
      password: "password",
      password_confirmation: "password"
    }
    # @update_attrs %{name: "Test Update User", email: "user_update@test.com"}
    @invalid_attrs %{name: nil, email: nil, password: nil}

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == @valid_attrs[:name]
      assert user.email == @valid_attrs[:email]
      assert user.password_hash != @valid_attrs[:password]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end
  end
end
