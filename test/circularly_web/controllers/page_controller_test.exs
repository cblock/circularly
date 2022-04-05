defmodule CircularlyWeb.PageControllerTest do
  use CircularlyWeb.ConnCase, async: true

  setup :register_and_log_in_user

  describe "GET /" do
    test "renders organization list", %{conn: conn} do
      conn = get(conn, Routes.organization_index_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ "<h1>Listing Organizations</h1>"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.organization_index_path(conn, :index))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "GET /:org_slug" do
    test "renders the org specific start page for an authorized user", %{
      conn: conn,
      organization: organization
    } do
      conn = get(conn, Routes.page_path(conn, :index, organization.slug))
      response = html_response(conn, 200)
      assert response =~ "<h2>Current Organization:"
    end

    test "redirects user when trying to access an unauthorized organization", %{
      conn: conn,
      organization: organization
    } do
      second_organization = Circularly.AccountsFixtures.organization_fixture()
      conn = get(conn, Routes.page_path(conn, :index, second_organization.slug))
      assert conn.halted
      assert redirected_to(conn) == Routes.organization_index_path(conn, :index)
      assert get_flash(conn, :error) == "Organization does not exist or not accessible."
    end
  end
end
