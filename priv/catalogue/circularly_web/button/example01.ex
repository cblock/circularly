defmodule CircularlyWeb.Components.Button.Example01 do
  @moduledoc """
  Example using `size` property.
  """

  use Surface.Catalogue.Example,
    subject: CircularlyWeb.Components.Button,
    height: "480px",
    title: "Size"

  alias CircularlyWeb.Components.Button

  def render(assigns) do
    ~F"""
    <Button size="xs">xs size</Button>
    <br>
    <Button size="sm">sm size</Button>
    <br>
    <Button size="base">base size</Button>
    <br>
    <Button size="lg">lg size</Button>
    """
  end
end
