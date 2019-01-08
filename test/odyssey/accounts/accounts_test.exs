defmodule Odyssey.AccountsTest do
  use Odyssey.DataCase

  alias Odyssey.Accounts

  describe "accounts" do
    alias Odyssey.Accounts.User

    @default_permissions %{"default" => ["my_profile"]}
    @admin_permissions %{"admin" => ["view_all_users", "edit_users"]}

    @valid_attrs %{
      name: "Test User",
      email: "user@test.com",
      password: "password",
      password_confirmation: "password"
    }
    @update_attrs %{name: "Test Update User", email: "user_update@test.com"}
    @admin_update_attrs %{name: "Test Update User", permissions: @admin_permissions}
    @invalid_attrs %{name: nil, email: nil, password: nil, password_confirmation: "password"}


    def fixture(:user, user_params \\ @valid_attrs) do
      {:ok, user} = Accounts.create_user(user_params)
      user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == @valid_attrs[:name]
      assert user.email == @valid_attrs[:email]
      assert user.password_hash != @valid_attrs[:password]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "list_users/0 returns all users" do
      users = [%{name: "John", email: "john@example.com", password: "john pass", password_confirmation: "john pass"},
               %{name: "Jane", email: "jane@example.com", password: "jane pass", password_confirmation: "jane pass"}]

      # create users local to this database connection and test
      [{:ok, user1},{:ok, user2}] = Enum.map(users, &Accounts.create_user(&1))
      user1 = %{user1 | password: nil, password_confirmation: nil, permissions: @default_permissions}
      user2 = %{user2 | password: nil, password_confirmation: nil, permissions: @default_permissions}
      assert Accounts.list_users() == [user1, user2]
    end

    test "get_user!/1 returns the user with given id" do
      user = fixture(:user)
      user = %{user | password: nil, password_confirmation: nil, permissions: @default_permissions}
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user/2 with valid data updates the user" do
      user = fixture(:user)
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.name == @update_attrs[:name]
      assert user.email == @update_attrs[:email]
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = fixture(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      user = %{user | password: nil, password_confirmation: nil, permissions: @default_permissions}
      assert user == Accounts.get_user!(user.id)
    end

    test "admin_update_user/2 with valid data updates the user" do
      user = fixture(:user)
      assert {:ok, %User{} = user} = Accounts.update_user(user, @admin_update_attrs)
      assert user.name == @admin_update_attrs[:name]
      assert user.permissions == @admin_permissions
    end

    test "delete_user/1 deletes the user" do
      user = fixture(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end
  end
end
