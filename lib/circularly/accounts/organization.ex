defmodule Circularly.Accounts.Organization do
  @moduledoc """
   Organization entity
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  @derive {Phoenix.Param, key: :slug}

  @primary_key {:org_id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string
    field :slug, :string

    has_many :user_org_memberships, Circularly.Accounts.UserOrgMembership,
      foreign_key: :org_id,
      references: :org_id

    has_many :permitted_users, through: [:user_org_memberships, :user]
    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name])
  end
end
