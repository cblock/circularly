defmodule Circularly.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Circularly.Accounts` context.
  """

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "Hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  @doc """
  Generate a user, an organization and an admin user_org_membership for the user in the organization.
  """
  def user_org_membership_organization_fixture(attrs \\ %{}) do
    {:ok, %{organization: organization, user: user, user_org_membership: user_org_membership}} =
      attrs
      |> valid_user_attributes()
      |> Circularly.Accounts.register_user()

    %{organization: organization, user: user, user_org_membership: user_org_membership}
  end

  def user_fixture(attrs \\ %{}) do
    %{user: user} = user_org_membership_organization_fixture(attrs)
    user
  end

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    %{organization: organization} = user_org_membership_organization_fixture(attrs)
    organization
  end

  @doc """
  Generate a user_org_membership.
  """
  def user_org_membership_fixture(attrs \\ %{}) do
    %{user_org_membership: user_org_membership} = user_org_membership_organization_fixture(attrs)
    user_org_membership
  end
end
