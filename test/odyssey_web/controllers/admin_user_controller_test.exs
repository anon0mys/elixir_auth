defmodule OdysseyWeb.Admin.UserControllerTest do
  use OdysseyWeb.ConnCase

  alias Odyssey.Accounts
  alias Odyssey.Accounts.User
  alias Odyssey.Auth.Guardian
  alias Odyssey.Repo

  @user_params %{
    name: "Test User",
    email: "user@test.com",
    password: "password",
    password_confirmation: "password"
  }

  @admin_params %User{
    name: "Test Admin",
    email: "admin@test.com",
    password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
    password: "password",
    password_confirmation: "password",
    permissions: %{admin: [:view_all_users, :edit_users]}
  }

  def fixture(_, user_params \\ @user_params)

  def fixture(:user, user_params) do
    {:ok, user} = Accounts.create_user(user_params)
    user
  end

  def fixture(:admin, _) do
    Repo.insert!(@admin_params)
  end

  def sign_in(user) do
    Guardian.encode_and_sign(user, %{}, permissions: user.permissions)
  end

  describe "index/1" do
    test "lists all users when current user has admin permissions", %{conn: conn} do
      users = [%{name: "John", email: "john@example.com", password: "john pass", password_confirmation: "john pass"},
               %{name: "Jane", email: "jane@example.com", password: "jane pass", password_confirmation: "jane pass"}]

      # create users local to this database connection and test
      [{:ok, user1},{:ok, user2}] = Enum.map(users, &Accounts.create_user(&1))

      admin = fixture(:admin)
      with {:ok, token, _claims} <- sign_in(admin) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> get(Routes.admin_user_path(conn, :index))
          |> json_response(200)

        expected = %{
          "data" => [
            %{ "name" => user1.name, "id" => user1.id, "email" => user1.email },
            %{ "name" => user2.name, "id" => user2.id, "email" => user2.email },
            %{ "name" => admin.name, "id" => admin.id, "email" => admin.email },
          ]
        }
        assert response == expected
      end
    end

    test "returns unauthorized error when current user has invalid permissions", %{conn: conn} do
      users = [%{name: "John", email: "john@example.com", password: "john pass", password_confirmation: "john pass"},
               %{name: "Jane", email: "jane@example.com", password: "jane pass", password_confirmation: "jane pass"}]

      # create users local to this database connection and test
      Enum.map(users, &Accounts.create_user(&1))

      user = fixture(:user)
      with {:ok, token, _claims} <- sign_in(user) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> get(Routes.admin_user_path(conn, :index))

        assert response.status == 401
        assert response.resp_body == "{\"error\":\"unauthorized\"}"
      end
    end
  end

  describe "show/2" do
    test "shows a user when current user has admin permissions", %{conn: conn} do
      user = fixture(:user)
      admin = fixture(:admin)
      with {:ok, token, _claims} <- sign_in(admin) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> get(Routes.admin_user_path(conn, :show, user.id))
          |> json_response(200)

        expected = %{
          "name" => user.name, "id" => user.id, "email" => user.email
        }
        assert response == expected
      end
    end

    test "returns unauthorized error for invalid permissions", %{conn: conn} do
      user_params = %{
        name: "Test Visible user",
        email: "user2@test.com",
        password: "password",
        password_confirmation: "password"
      }

      user = fixture(:user, user_params)
      current_user = fixture(:user)
      with {:ok, token, _claims} <- sign_in(current_user) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> get(Routes.admin_user_path(conn, :show, user.id))

        assert response.status == 401
        assert response.resp_body == "{\"error\":\"unauthorized\"}"
      end
    end
  end

  describe "create/2" do
    test "creates a user and returns a jwt token if user is admin", %{conn: conn} do
      admin = fixture(:admin)
      with {:ok, token, _claims} <- sign_in(admin) do
        conn =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> get(Routes.admin_user_path(conn, :create, %{"user" => @user_params}))

        assert [%{"name" => name, "id" => id, "email" => email}] = json_response(conn, 200)["data"]
      end
    end

    test "returns an error and does not create user if user not admin", %{conn: conn} do
      user_params = %{
        name: "Test Visible user",
        email: "user2@test.com",
        password: "password",
        password_confirmation: "password"
      }

      current_user = fixture(:user)
      with {:ok, token, _claims} <- sign_in(current_user) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> post(Routes.admin_user_path(conn, :create, user: %{"user" => user_params}))

        assert response.status == 401
        assert response.resp_body == "{\"error\":\"unauthorized\"}"
      end
    end
  end

  describe "update/2" do
    test "updates a user and returns information when user is admin", %{conn: conn} do
      user_params = %{
        name: "User to update",
        email: "user2@test.com",
        password: "password",
        password_confirmation: "password"
      }

      update_params = %{name: "Test Updated Name"}

      update_user = fixture(:user, user_params)
      admin = fixture(:admin)

      with {:ok, token, _claims} <- sign_in(admin) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> patch(Routes.admin_user_path(conn, :update, update_user.id, %{"user" => update_params}))
          |> json_response(200)

        expected = %{"data" => %{"email" => update_user.email, "id" => update_user.id, "name" => "Test Updated Name"}}

        assert response == expected
      end
    end

    test "returns an error and does not update user if user is not admin", %{conn: conn} do
      user_params = %{
        name: "User to update",
        email: "user2@test.com",
        password: "password",
        password_confirmation: "password"
      }

      update_params = %{name: "Test Updated Name"}

      update_user = fixture(:user, user_params)
      current_user = fixture(:user)

      with {:ok, token, _claims} <- sign_in(current_user) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> patch(Routes.admin_user_path(conn, :update, update_user.id, %{"user" => update_params}))

        assert response.status == 401
        assert response.resp_body == "{\"error\":\"unauthorized\"}"
      end
    end
  end

  describe "delete/1" do
    test "deletes a user when current user has admin permissions", %{conn: conn} do
      user = fixture(:user)
      admin = fixture(:admin)
      with {:ok, token, _claims} <- sign_in(admin) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> delete(Routes.admin_user_path(conn, :delete, user.id))

        assert response.status == 204
      end

      assert Repo.get(User, user.id) == nil
    end

    test "does not delete a user when current user is not admin", %{conn: conn} do
      user_params = %{
        name: "Test Visible user",
        email: "user2@test.com",
        password: "password",
        password_confirmation: "password"
      }

      user = fixture(:user, user_params)
      current_user = fixture(:user)
      with {:ok, token, _claims} <- sign_in(current_user) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> delete(Routes.admin_user_path(conn, :delete, user.id))

        assert response.status == 401
        assert response.resp_body == "{\"error\":\"unauthorized\"}"
      end

      assert Repo.get(User, user.id) != nil
    end
  end
end
