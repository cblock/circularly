defmodule Circularly.Accounts.Organization.Policy do
  @moduledoc """
  Defines user access policies for reading and manipulating organization entities
  """

  @behaviour Bodyguard.Policy

  alias Circularly.Accounts.{Roles, UserOrgMembership}

  # @spec authorize(:delete_organization, User.t(), UserOrgMembership.t()) :: true | false
  def authorize(:delete_organization, _user, %UserOrgMembership{} = user_org_membership) do
    Enum.any?(user_org_membership.roles, fn role -> Roles.admin?(role) end)
  end

  # @spec authorize(:update_organization, User.t(), UserOrgMembership.t()) :: true | false
  def authorize(:update_organization, _user, %UserOrgMembership{} = user_org_membership) do
    Enum.any?(user_org_membership.roles, fn role -> Roles.admin?(role) end)
  end
end
