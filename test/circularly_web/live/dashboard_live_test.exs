defmodule CircularlyWeb.DashboardLiveTest do
  use CircularlyWeb.ConnCase, async: true

  import Circularly.AccountsFixtures
  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  describe "GET /:org_slug" do
    test "renders the dashboard", %{conn: conn, user: user, organization: organization} do
      {:ok, _index_live, html} =
        live(conn, Routes.dashboard_index_path(conn, :index, organization))

      assert html =~ "Dashboard"
      assert html =~ user.email
      assert html =~ organization.slug
    end

    test "redirects if user is not logged in", %{organization: organization} do
      conn = build_conn()
      conn = live(conn, Routes.dashboard_index_path(conn, :index, organization))

      assert {:error,
              {:redirect,
               %{flash: %{"error" => "You must log in to access this page."}, to: "/users/log_in"}}} ==
               conn
    end

    test "redirects if user is not authorized", %{conn: conn} do
      organization = organization_fixture()
      conn = live(conn, Routes.dashboard_index_path(conn, :index, organization))

      assert {:error,
              {:redirect,
               %{
                 flash: %{"error" => "This resource does not exist or cannot be accessed"},
                 to: "/users/log_in"
               }}} ==
               conn
    end
  end
end
