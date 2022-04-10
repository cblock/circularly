defmodule Circularly.Accounts.UserOrgMembership do
  @moduledoc """
    A UserOrgMembership defines the granted roles a particular user has in a particular organization.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Circularly.Accounts.Roles

  @type t() :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_org_memberships" do
    field :roles, {:array, Ecto.Enum}, values: Roles.list()
    belongs_to :user, Circularly.Accounts.User

    belongs_to :organization, Circularly.Accounts.Organization,
      foreign_key: :org_id,
      references: :org_id

    timestamps()
  end

  @doc """
  Grants admin role to the given user in the given organization
  """
  def grant_admin_changeset(user_org_membership, attrs) do
    user_org_membership
    |> cast(attrs, [:org_id, :user_id])
    |> validate_required([:org_id, :user_id])
    |> change(roles: [Roles.admin()])
  end

  @doc """
  Grants viewer role to the given user in the given organization
  """
  def grant_viewer_changeset(user_org_membership, attrs) do
    user_org_membership
    |> cast(attrs, [:org_id, :user_id])
    |> validate_required([:org_id, :user_id])
    |> change(roles: [Roles.viewer()])
  end

  @doc """
  Grants editor role to the given user in the given organization
  """
  def grant_editor_changeset(user_org_membership, attrs) do
    user_org_membership
    |> cast(attrs, [:org_id, :user_id])
    |> validate_required([:org_id, :user_id])
    |> change(roles: [Roles.editor()])
  end
end
