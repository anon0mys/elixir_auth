defmodule OdysseyWeb.FallbackController do
  use OdysseyWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(OdysseyWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(OdysseyWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Login error"})
  end
end
