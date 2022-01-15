defmodule Circularly.Accounts.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Phoenix.Param, key: :org_id}

  @primary_key {:org_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string

    has_many :permissions, Circularly.Accounts.Permission,
      foreign_key: :org_id,
      references: :org_id

    has_many :permitted_users, through: [:permissions, :user]
    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name])
  end
end
