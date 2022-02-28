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
end
