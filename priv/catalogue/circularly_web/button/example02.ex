defmodule CircularlyWeb.Components.Button.Example02 do
  @moduledoc """
  Example using the `color` property.
  """

  use Surface.Catalogue.Example,
    subject: CircularlyWeb.Components.Button,
    height: "480px",
    title: "Color"

  alias CircularlyWeb.Components.Button

  def render(assigns) do
    ~F"""
    <Button color="primary">Primary</Button>
    <br>
    <Button color="secondary">Secondary</Button>
    <br>
    <Button color="white">White</Button>
    """
  end
end
