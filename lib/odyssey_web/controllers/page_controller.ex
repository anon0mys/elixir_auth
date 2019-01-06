defmodule OdysseyWeb.PageController do
  use OdysseyWeb, :controller

  alias Odyssey.Auth
  alias Odyssey.Auth.Guardian
  alias Odyssey.Accounts.User

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    Auth.authenticate_user(email, password)
    |> login_reply(conn)
  end

  defp login_reply({:ok, user}, conn) do
    conn
    |> put_status(:success)
    |> Guardian.Plug.sign_in(user)
    |> render(:"200")
  end
end
