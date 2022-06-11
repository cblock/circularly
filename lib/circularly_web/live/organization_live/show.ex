defmodule CircularlyWeb.OrganizationLive.Show do
  @moduledoc false
  use CircularlyWeb, :live_view

  alias Circularly.Accounts

  @impl true
  def handle_params(%{"id" => id}, _, %{assigns: %{current_user: user}} = socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:organization, Accounts.get_user_organization!(user, id))}
  end

  defp page_title(:show), do: "Show Organization"
  defp page_title(:edit), do: "Edit Organization"
end
