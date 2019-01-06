defmodule Odyssey.Repo.Migrations.AddPasswordToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password, :string, null: true
    end
  end
end
