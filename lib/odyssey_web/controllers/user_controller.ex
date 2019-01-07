defmodule OdysseyWeb.UserController do
  use OdysseyWeb, :controller
  alias Odyssey.Accounts
  alias Odyssey.Accounts.User
  alias Odyssey.Auth

  action_fallback OdysseyWeb.FallbackController
  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:view_all_users]}] when action in [:index, :show]

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
         {:ok, token, _claims} <- Auth.Guardian.encode_and_sign(user, %{}, permissions: user.permissions) do
      conn |> render("jwt.json", jwt: token)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    target_user = Accounts.get_user!(id)
    current_user = Auth.Guardian.Plug.current_resource(conn)

    if current_user.id == target_user.id do
      with {:ok, %User{} = user} <- Accounts.update_user(target_user, user_params) do
        render(conn, "show.json", user: user)
      end
    else
      {:error, :no_permission}
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        conn |> render("jwt.json", jwt: token)
      _ ->
        {:error, :unauthorized}
    end
  end

  def my_account(conn, _params) do
    user = Auth.Guardian.Plug.current_resource(conn)
    conn |> render("user.json", user: user)
  end
end
