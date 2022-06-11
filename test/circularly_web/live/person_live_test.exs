defmodule CircularlyWeb.PersonLiveTest do
  use CircularlyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Circularly.PeopleFixtures

  setup :register_and_log_in_user

  @create_attrs %{
    description: "some description",
    joined_at: %{day: 17, hour: 19, minute: 30, month: 4, year: 2022},
    name: "some name"
  }
  @update_attrs %{
    description: "some updated description",
    joined_at: %{day: 18, hour: 19, minute: 30, month: 4, year: 2022},
    name: "some updated name"
  }
  @invalid_attrs %{
    description: nil,
    joined_at: %{day: 30, hour: 19, minute: 30, month: 2, year: 2022},
    name: nil
  }

  defp create_person(org_id) do
    Circularly.Repo.put_org_id(org_id)
    person = person_fixture()
    %{person: person}
  end

  describe "Index" do
    setup(%{organization: organization}) do
      create_person(organization.org_id)
    end

    test "lists all people", %{conn: conn, person: person, organization: organization} do
      {:ok, _index_live, html} = live(conn, Routes.person_index_path(conn, :index, organization))

      assert html =~ "Listing People"
      assert html =~ person.description
    end

    test "saves new person", %{conn: conn, organization: organization} do
      {:ok, index_live, _html} = live(conn, Routes.person_index_path(conn, :index, organization))

      assert index_live |> element("a", "Add Person") |> render_click() =~
               "Add Person"

      assert_patch(index_live, Routes.person_index_path(conn, :new, organization))

      assert index_live
             |> form("#person-form", person: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#person-form", person: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.person_index_path(conn, :index, organization))

      assert html =~ "Person created successfully"
      assert html =~ "some description"
    end

    test "updates person in listing", %{conn: conn, person: person, organization: organization} do
      {:ok, index_live, _html} = live(conn, Routes.person_index_path(conn, :index, organization))

      assert index_live |> element("#person-#{person.id} a", "Edit") |> render_click() =~
               "Edit Person"

      assert_patch(index_live, Routes.person_index_path(conn, :edit, organization, person))

      assert index_live
             |> form("#person-form", person: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#person-form", person: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.person_index_path(conn, :index, organization))

      assert html =~ "Person updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes person in listing", %{conn: conn, person: person, organization: organization} do
      {:ok, index_live, _html} = live(conn, Routes.person_index_path(conn, :index, organization))

      assert index_live |> element("#person-#{person.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#person-#{person.id}")
    end
  end

  describe "Show" do
    setup(%{organization: organization}) do
      create_person(organization.org_id)
    end

    test "displays person", %{conn: conn, person: person, organization: organization} do
      {:ok, _show_live, html} =
        live(conn, Routes.person_show_path(conn, :show, organization, person))

      assert html =~ "Show Person"
      assert html =~ person.description
    end

    test "updates person within modal", %{conn: conn, person: person, organization: organization} do
      {:ok, show_live, _html} =
        live(conn, Routes.person_show_path(conn, :show, organization, person))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Person"

      assert_patch(show_live, Routes.person_show_path(conn, :edit, organization, person))

      assert show_live
             |> form("#person-form", person: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#person-form", person: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.person_show_path(conn, :show, organization, person))

      assert html =~ "Person updated successfully"
      assert html =~ "some updated description"
    end
  end
end
