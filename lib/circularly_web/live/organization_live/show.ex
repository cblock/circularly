defmodule CircularlyWeb.OrganizationLive.Show do
  @moduledoc false
  use CircularlyWeb, :live_view

  alias Circularly.Accounts

  @impl true

  def mount(_params, %{"user_token" => token} = _session, socket) do
    {:ok,
     socket
     |> assign_current_user_to_socket(token)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{current_user: user}} = socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:organization, Accounts.get_organization_for!(user, id))}
  end

  defp page_title(:show), do: "Show Organization"
  defp page_title(:edit), do: "Edit Organization"
end
