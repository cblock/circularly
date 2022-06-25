defmodule CircularlyWeb.Components.AuthLayout.Example02 do
  @moduledoc """
  Example with header.
  """

  use Surface.Catalogue.Example,
    subject: CircularlyWeb.Components.AuthLayout,
    height: "480px",
    title: "Default"

  alias CircularlyWeb.Components.AuthLayout

  def render(assigns) do
    ~F"""
    <AuthLayout>
    <:header>
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        Register a new account
      </h2>
      <p class="mt-2 text-center text-sm text-gray-600">
        or
        <a href="#" class="default">sign in to your account</a>
      </p>
    </:header>
    <form class="space-y-6">
      <div class="relative">
        <input id="name_input" type="email" class="peer default" placeholder="Name"/>
        <label for="name_input" class="default">Name</label>
      </div>
      <div class="relative">
        <input id="pw_input" type="password" class="peer default" placeholder="Password"/>
        <label for="pw_input" class="default">Password</label>
      </div>
    </form>
    </AuthLayout>
    """
  end
end
