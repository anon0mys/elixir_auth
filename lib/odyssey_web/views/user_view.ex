defmodule OdysseyWeb.UserView do
  use OdysseyWeb, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, OdysseyWeb.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      email: user.email
    }
  end

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end
