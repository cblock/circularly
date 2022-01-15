defmodule CircularlyWeb.OrganizationLive.FormComponent do
  use CircularlyWeb, :live_component

  alias Circularly.Accounts

  @impl true
  def update(%{organization: organization} = assigns, socket) do
    changeset = Accounts.change_organization(organization)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"organization" => organization_params}, socket) do
    changeset =
      socket.assigns.organization
      |> Accounts.change_organization(organization_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"organization" => organization_params}, socket) do
    save_organization(socket, socket.assigns.action, organization_params)
  end

  defp save_organization(%{assigns: %{current_user: user}} = socket, :edit, organization_params) do
    case Accounts.update_organization_for(user, socket.assigns.organization, organization_params) do
      {:ok, _organization} ->
        {:noreply,
         socket
         |> put_flash(:info, "Organization updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_organization(%{assigns: %{current_user: user}} = socket, :new, organization_params) do
    case Accounts.create_organization_for(user, organization_params) do
      {:ok, _organization} ->
        {:noreply,
         socket
         |> put_flash(:info, "Organization created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
