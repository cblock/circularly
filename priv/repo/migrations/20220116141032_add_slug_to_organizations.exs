defmodule Circularly.Repo.Migrations.AddSlugToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :slug, :text, null: false
    end

    create unique_index(:organizations, [:slug])
  end
end
