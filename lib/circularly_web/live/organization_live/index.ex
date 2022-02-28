defmodule CircularlyWeb.OrganizationLive.Index do
  @moduledoc false

  use CircularlyWeb, :live_view

  alias Circularly.Accounts
  alias Circularly.Accounts.Organization

  @impl true
  def mount(_params, %{"user_token" => token} = _session, socket) do
    {:ok,
     socket
     |> assign_current_user_to_socket(token)
     |> assign_organizations()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(%{assigns: %{current_user: user}} = socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Organization")
    |> assign(:organization, Accounts.get_organization_for!(user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Organization")
    |> assign(:organization, %Organization{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Organizations")
    |> assign(:organization, nil)
  end

  @impl true
  def handle_event("delete", %{"slug" => slug}, %{assigns: %{current_user: user}} = socket) do
    organization = Accounts.get_organization_for!(user, slug)
    {:ok, _} = Accounts.delete_organization_for(user, organization)

    {:noreply, assign(socket, :organizations, Accounts.list_organizations_for(user))}
  end

  defp assign_organizations(socket) do
    user = socket.assigns.current_user
    organizations = Accounts.list_organizations_for(user)
    assign(socket, :organizations, organizations)
  end
end
