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
  Generate a user, an organization and an admin permission for the user in the organization.
  """
  def user_permission_organization_fixture(attrs \\ %{}) do
    {:ok, %{organization: organization, user: user, permission: permission}} =
      attrs
      |> valid_user_attributes()
      |> Circularly.Accounts.register_user()

    %{organization: organization, user: user, permission: permission}
  end

  @spec user_fixture(any) :: User.t()
  def user_fixture(attrs \\ %{}) do
    %{user: user} = user_permission_organization_fixture(attrs)
    user
  end

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    %{organization: organization} = user_permission_organization_fixture(attrs)
    organization
  end
end
