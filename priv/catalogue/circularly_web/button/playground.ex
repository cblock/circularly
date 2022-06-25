defmodule CircularlyWeb.Components.Button.Playground do
  use Surface.Catalogue.Playground,
    subject: CircularlyWeb.Components.Button,
    height: "250px",
    body: [style: "padding: 1.5rem;"]

  data props, :map, default: %{
    width: "default",
    color: "primary",
    size: "base"
  }

  def render(assigns) do
    ~F"""
    <Button {...@props}>
    A simple Button
    </Button>
    """
  end
end
