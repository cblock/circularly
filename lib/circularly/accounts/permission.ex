defmodule Circularly.Accounts.Permission do
  @moduledoc """
    Permissions define the rights of a particular user in a particular organization.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "permissions" do
    field :rights, {:array, Ecto.Enum}, values: [:User, :Admin]
    belongs_to :user, Circularly.Accounts.User
    belongs_to :organization, Circularly.Accounts.Organization, foreign_key: :org_id

    timestamps()
  end

  @doc """
  Grants admin role to the given user in the given organization
  """
  def grant_admin_changeset(permission, attrs) do
    permission
    |> cast(attrs, [:org_id, :user_id])
    |> validate_required([:org_id, :user_id])
    |> change(rights: [:Admin])
  end
end
