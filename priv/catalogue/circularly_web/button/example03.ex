defmodule CircularlyWeb.Components.Button.Example03 do
  @moduledoc """
  Example using the `width`, property.
  """

  use Surface.Catalogue.Example,
    subject: CircularlyWeb.Components.Button,
    height: "480px",
    title: "Width"

  alias CircularlyWeb.Components.Button

  def render(assigns) do
    ~F"""
    <Button width="regular">Regular width (default)</Button>
    <br>
    <Button width="full">Full width</Button>
    """
  end
end
