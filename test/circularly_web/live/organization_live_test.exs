defmodule CircularlyWeb.OrganizationLiveTest do
  use CircularlyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  # @invalid_attrs %{name: nil}

  setup :register_and_log_in_user

  describe "Index" do
    test "lists all organizations", %{conn: conn, organization: organization} do
      {:ok, index_live, html} = live(conn, Routes.organization_index_path(conn, :index))

      assert html =~ "Listing Organizations"
      assert has_element?(index_live, "#organization-#{organization.org_id}")
    end

    test "saves new organization", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.organization_index_path(conn, :index))

      assert index_live |> element("a", "New Organization") |> render_click() =~
               "New Organization"

      assert_patch(index_live, Routes.organization_index_path(conn, :new))

      # Organization name is currently only editable attribute and optional
      # assert index_live
      #        |> form("#organization-form", organization: @invalid_attrs)
      #        |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#organization-form", organization: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.organization_index_path(conn, :index))

      assert html =~ "Organization created successfully"
      assert html =~ "some name"
    end

    test "updates organization in listing", %{conn: conn, organization: organization} do
      {:ok, index_live, _html} = live(conn, Routes.organization_index_path(conn, :index))

      assert index_live
             |> element("#organization-#{organization.org_id} a", "Edit")
             |> render_click() =~
               "Edit Organization"

      assert_patch(index_live, Routes.organization_index_path(conn, :edit, organization))

      # Organization name is currently only editable attribute and optional
      # assert index_live
      #        |> form("#organization-form", organization: @invalid_attrs)
      #        |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#organization-form", organization: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.organization_index_path(conn, :index))

      assert html =~ "Organization updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes organization in listing", %{conn: conn, organization: organization} do
      {:ok, index_live, _html} = live(conn, Routes.organization_index_path(conn, :index))

      assert index_live
             |> element("#organization-#{organization.org_id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#organization-#{organization.org_id}")
    end
  end

  describe "Show" do
    test "displays organization", %{conn: conn, organization: organization} do
      {:ok, _show_live, html} =
        live(conn, Routes.organization_show_path(conn, :show, organization))

      assert html =~ "Show Organization"
      # Default organization name ist not - organization.name
      assert html =~ "My Organization"
    end

    test "updates organization within modal", %{conn: conn, organization: organization} do
      {:ok, show_live, _html} =
        live(conn, Routes.organization_show_path(conn, :show, organization))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Organization"

      assert_patch(show_live, Routes.organization_show_path(conn, :edit, organization))

      # Organization name is currently only editable attribute and optional
      # assert show_live
      #        |> form("#organization-form", organization: @invalid_attrs)
      #        |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#organization-form", organization: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.organization_show_path(conn, :show, organization))

      assert html =~ "Organization updated successfully"
      assert html =~ "some updated name"
    end
  end
end
