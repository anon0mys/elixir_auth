defmodule OdysseyWeb.UserControllerTest do
  use OdysseyWeb.ConnCase

  describe "create/2" do
    test "creates a user and returns a jwt token if params are valid", %{conn: conn} do
      user_params = %{
        name: "Test User",
        email: "user@test.com",
        password: "password",
        password_confirmation: "password"
      }

      response =
        conn
        |> post(Routes.user_path(conn, :create, %{"user" => user_params}))
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
end
