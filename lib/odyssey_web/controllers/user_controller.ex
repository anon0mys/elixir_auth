defmodule OdysseyWeb.UserController do
  use OdysseyWeb, :controller
  alias Odyssey.Accounts
  alias Odyssey.Accounts.User
  alias Odyssey.Auth

  action_fallback OdysseyWeb.FallbackController
  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:view_all_users]}] when action in [:index]

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
         {:ok, token, _claims} <- Auth.Guardian.encode_and_sign(user, %{}, permissions: user.permissions) do
      conn |> render("jwt.json", jwt: token)
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

  def show(conn, _params) do
    user = Auth.Guardian.Plug.current_resource(conn)
    conn |> render("user.json", user: user)
  end

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end
end
