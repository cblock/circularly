defmodule CircularlyWeb.Components.AuthLayout do
  @moduledoc """
  Renders a full screen navigation-less layout with centered form field.
  """
  use Surface.Component

  @doc """
  The header
  """
  slot header

  @doc """
  The main content
  """
  slot default, required: true

  def render(assigns) do
    ~F"""
    <div class="min-h-full flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div :if={slot_assigned?(:header)} class="sm:mx-auto sm:w-full sm:max-w-md">
      <#slot name="header" />
      </div>
      <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <#slot />
        </div>
      </div>
    </div>
    """
  end
end
