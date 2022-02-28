defmodule Circularly.Accounts.Permission do
  @moduledoc """
    Permissions define the rights of a particular user in a particular organization.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "permissions" do
    field :rights, {:array, Ecto.Enum}, values: [:user, :admin, :owner]
    belongs_to :user, Circularly.Accounts.User

    belongs_to :organization, Circularly.Accounts.Organization,
      foreign_key: :org_id,
      references: :org_id

    timestamps()
  end

  @doc """
  Grants admin role to the given user in the given organization
  """
  def grant_admin_changeset(permission, attrs) do
    permission
    |> cast(attrs, [:org_id, :user_id])
    |> validate_required([:org_id, :user_id])
    |> change(rights: [:admin])
  end

  @doc """
  Grants owner role to the given user in the given organization
  """
  def grant_owner_changeset(permission, attrs) do
    permission
    |> cast(attrs, [:org_id, :user_id])
    |> validate_required([:org_id, :user_id])
    |> change(rights: [:owner])
  end
end
