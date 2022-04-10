defmodule Circularly.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add :org_id, :binary_id, primary_key: true
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create table(:user_org_memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add(
        :org_id,
        references(:organizations, column: :org_id, type: :binary_id, on_delete: :delete_all),
        null: false
      )

      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :roles, {:array, :string}
      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_org_memberships, [:org_id, :user_id])
  end
end
