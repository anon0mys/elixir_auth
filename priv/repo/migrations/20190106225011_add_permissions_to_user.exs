defmodule Odyssey.Repo.Migrations.AddPermissionsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :permissions, :map
    end
  end
end
