defmodule OdysseyWeb.UserControllerTest do
  use OdysseyWeb.ConnCase

  alias Odyssey.Accounts
  alias Odyssey.Auth.Guardian

  @user_params %{
    name: "Test User",
    email: "user@test.com",
    password: "password",
    password_confirmation: "password"
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_params)
    user
  end

  def sign_in(user) do
    Guardian.encode_and_sign(user)
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

  describe "show/1" do
    test "allows signed in user to view their information", %{conn: conn} do
      user = fixture(:user)
      with {:ok, token, _claims} <- sign_in(user) do
        response =
          conn
          |> put_req_header("authorization", "Bearer #{token}")
          |> get(Routes.user_path(conn, :show))
          |> json_response(200)

        expected = %{"email" => user.email, "id" => user.id, "name" => user.name}

        assert response == expected
      end
    end
  end
end
