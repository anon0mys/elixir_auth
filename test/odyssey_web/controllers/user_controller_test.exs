defmodule OdysseyWeb.UserControllerTest do
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
    permissions: %{admin: [:view_all_users]}
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
          |> get(Routes.user_path(conn, :index))
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
          |> get(Routes.user_path(conn, :index))

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
          |> get(Routes.user_path(conn, :show, user.id))
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

      fixture(:user, user_params)
      current_user = fixture(:user)
      with {:ok, token, _claims} <- sign_in(current_user) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> get(Routes.user_path(conn, :index))

        assert response.status == 401
        assert response.resp_body == "{\"error\":\"unauthorized\"}"
      end
    end
  end

  describe "create/2" do
    test "creates a user and returns a jwt token if params are valid", %{conn: conn} do
      response =
        conn
        |> post(Routes.user_path(conn, :create, %{"user" => @user_params}))
        |> json_response(200)

      assert response["jwt"] != nil
    end

    test "returns an error and does not create user if params are invalid", %{conn: conn} do
      user_params = %{name: nil, email: nil, password: nil, password_confirmation: nil}
      expected = %{
        "errors" => %{
          "email" => ["can't be blank"],
          "name" => ["can't be blank"],
          "password" => ["can't be blank"],
          "password_confirmation" => ["can't be blank"]
        }
      }

      response =
        conn
        |> post(Routes.user_path(conn, :create, user: %{"user" => user_params}))
        |> json_response(422)

      assert response == expected
    end
  end

  describe "sign_in/2" do
    test "signs in a user and returns a jwt token if params are valid", %{conn: conn} do
      fixture(:user)
      sign_in_params = %{"email" => @user_params[:email], "password" => @user_params[:password]}

      response =
        conn
        |> post(Routes.user_path(conn, :sign_in, sign_in_params))
        |> json_response(200)

      assert response["jwt"] != nil
    end

    test "returns an error and does not create user if params are invalid", %{conn: conn} do
      fixture(:user)
      sign_in_params = %{email: nil, password: nil}

      response =
        conn
        |> post(Routes.user_path(conn, :sign_in, sign_in_params))
        |> json_response(401)

      expected = %{"error" => "Login error"}

      assert response == expected
    end
  end

  describe "my_account/1" do
    test "allows signed in user to view their information", %{conn: conn} do
      user = fixture(:user)
      with {:ok, token, _claims} <- sign_in(user) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> get(Routes.user_path(conn, :my_account))
          |> json_response(200)

        expected = %{"email" => user.email, "id" => user.id, "name" => user.name}

        assert response == expected
      end
    end
  end
end
