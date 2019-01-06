defmodule Odyssey.Auth do
  import Ecto.Query, warn: false

  alias Odyssey.Repo
  alias Comeonin.Bcrypt
  alias Odyssey.Accounts.User

  def authenticate_user(email, password) do
    query = from u in User, where: u.email == ^email
    Repo.one(query)
    |> check_password(password)
  end

  defp check_password(nil, _), do: {:error, "Incorrect email or password"}
  defp check_password(user, password) do
    case Bcrypt.checkpw(password, user.password) do
      true -> {:ok, user}
      false -> {:error, "Incorrect email or password"}
    end
  end
end
