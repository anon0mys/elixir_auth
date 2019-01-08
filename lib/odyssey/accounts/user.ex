defmodule Odyssey.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Odyssey.Accounts.User


  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :permissions, :map, default: %{default: [:my_profile]}
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  def update_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :permissions])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :password_confirmation])
    |> validate_required([:name, :email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  def put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
