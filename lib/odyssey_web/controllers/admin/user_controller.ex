defmodule OdysseyWeb.Admin.UserController do
  use OdysseyWeb, :controller
  alias Odyssey.Accounts
  alias Odyssey.Accounts.User

  action_fallback OdysseyWeb.FallbackController
  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:view_all_users]}] when action in [:index, :show]
  plug Guardian.Permissions.Bitwise, [ensure: %{admin: [:edit_users]}] when action in [:create, :update, :delete]


  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    conn |> render("user.json", user: user)
  end

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
