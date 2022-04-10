defmodule Circularly.Accounts.Roles do
  @moduledoc """
  defines available roles a `User` can be assigned
  """
  def viewer, do: :viewer
  def editor, do: :editor
  def admin, do: :admin

  def viewer?(role), do: role == :viewer
  def editor?(role), do: role == :editor
  def admin?(role), do: role == :admin

  def list, do: [:viewer, :editor, :admin]
end
