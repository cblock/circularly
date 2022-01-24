defmodule Circularly.Repo.Migrations.AddSlugToPermissions do
  use Ecto.Migration

  def change do
    alter table(:permissions) do
      add :slug, :text, null: false
    end

    create unique_index(:permissions, [:slug])
  end
end
