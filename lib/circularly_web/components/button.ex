defmodule CircularlyWeb.Components.Button do
  @moduledoc """
  Renders a button element in different colors, sizes, widths, and types
  """
  use Surface.Component

  @default_classes [
    "flex",
    "border",
    "rounded-md",
    "shadow-sm",
    "font-medium",
    "focus:outline-none",
    "focus:ring-2",
    "focus:ring-offset-2",
    "focus:ring-teal-500"
  ]

  @colors %{
    "primary" => ["border-transparent", "text-white", "bg-teal-600", "hover:bg-teal-700"],
    "secondary" => ["border-transparent", "text-teal-700", "bg-teal-100", "hover:bg-teal-200"],
    "white" => ["border-gray-300", "text-gray-700", "bg-white", "hover:bg-gray-50"]
  }
  @default_color "primary"

  @sizes %{
    "xs" => ["px-2.5", "py-1.5", "text-xs"],
    "sm" => ["px-4", "py-2", "text-sm"],
    "base" => ["px-4", "py-2", "text-base"],
    "lg" => ["px-6", "py-3", "text-base"]
  }
  @default_size "base"

  @widths %{
    "full" => ["w-full", "justify-center"],
    "regular" => ["items-center"]
  }
  @default_width "regular"

  @types ~w(button submit reset)

  @doc "The content of the button"
  slot default, required: true

  @doc "Optional additional css classes for the button"
  prop class, :css_class, default: []

  @doc """
  The button type, defaults to "submit", mainly used for form submissions. Setting to nil makes button have no type.
  """
  prop type, :string, default: "submit", values!: @types

  @doc """
  The color of the button
  """
  prop color, :string, default: @default_color, values!: Map.keys(@colors)

  @doc """
  The size of the button
  """
  prop size, :string, default: @default_size, values!: Map.keys(@sizes)

  @doc """
  The width of the button
  """
  prop width, :string, default: @default_width, values!: Map.keys(@widths)

  def render(assigns) do
    ~F"""
    <button type={button_type(assigns)} class={@class ++ button_classes(assigns)}>
      <#slot />
    </button>
    """
  end

  defp button_classes(assigns) do
    @default_classes ++
      button_color(assigns) ++
      button_size(assigns) ++
      button_width(assigns)
  end

  defp button_color(%{color: color}) do
    with {:ok, css_class_list} <- Map.fetch(@colors, color) do
      css_class_list
    else
      _ ->
        Map.fetch!(@colors, @default_color)
    end
  end

  defp button_size(%{size: size}) do
    with {:ok, css_class_list} <- Map.fetch(@sizes, size) do
      css_class_list
    else
      _ ->
        Map.fetch!(@sizes, @default_size)
    end
  end

  defp button_width(%{width: width}) do
    with {:ok, css_class_list} <- Map.fetch(@widths, width) do
      css_class_list
    else
      _ ->
        Map.fetch!(@widths, @default_width)
    end
  end

  defp button_type(%{type: button_type}) when button_type in @types do
    button_type
  end

  defp button_type(_), do: "submit"
end
