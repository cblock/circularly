defmodule Circularly.Accounts.Roles do
  @moduledoc """
  defines available roles a `User` can be assigned
  """

  @spec viewer :: :viewer
  @doc """
  Viewers (readonly): A restricted role to allow readonly access to the organization. Viewers are free and do not affect billing.
  """
  def viewer, do: :viewer

  @spec editor :: :editor
  @doc """
  The default role for most people. Editors can particpate in mapping the organization through creating / updating people, domains and circles
  """
  def editor, do: :editor

  @spec admin :: :admin
  @doc """
  Admins have access to most management screens and can handle access requests, manage organization workspaces and users
  """
  def admin, do: :admin

  #  LATER: Implement once we implement subscriptions and billing
  # @doc """
  # The highest level of control. This role includes all Admin functionality and additionally billing management
  # """
  # def owner, do: :owner

  @spec viewer?(any) :: boolean
  def viewer?(role), do: role == :viewer

  @spec editor?(any) :: boolean
  def editor?(role), do: role == :editor

  @spec admin?(any) :: boolean
  def admin?(role), do: role == :admin

  @spec list :: [:admin | :editor | :viewer, ...]
  def list, do: [:viewer, :editor, :admin]
end
