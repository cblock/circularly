defmodule Circularly.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do
    create table(:people, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :text
      add :joined_at, :utc_datetime

      add :org_id,
          references(:organizations, on_delete: :delete_all, type: :binary_id, column: :org_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:people, [:org_id])
  end
end
