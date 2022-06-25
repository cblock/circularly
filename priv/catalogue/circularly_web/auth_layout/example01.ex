defmodule CircularlyWeb.Components.AuthLayout.Example01 do
  @moduledoc """
  Example without header.
  """

  use Surface.Catalogue.Example,
    subject: CircularlyWeb.Components.AuthLayout,
    height: "480px",
    title: "Default"

  alias CircularlyWeb.Components.AuthLayout

  def render(assigns) do
    ~F"""
    <AuthLayout>
    Some content
    </AuthLayout>
    """
  end
end
