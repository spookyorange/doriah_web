defmodule DoriahWeb.ScriptLiveTest do
  use DoriahWeb.ConnCase

  import Phoenix.LiveViewTest
  import Doriah.ScriptingFixtures

  @create_attrs %{description: "some description", title: "some title"}
  @update_attrs %{description: "some updated description", title: "some updated title"}
  @invalid_attrs %{description: nil, title: nil}

  defp create_script(_) do
    script = script_fixture()
    %{script: script}
  end

  describe "Index" do
    setup [:create_script]

    test "lists all scripts", %{conn: conn, script: script} do
      {:ok, _index_live, html} = live(conn, ~p"/scripts")

      assert html =~ "Listing Scripts"
      assert html =~ script.description
    end

    test "saves new script", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/scripts")

      assert index_live |> element("a", "New Script") |> render_click() =~
               "New Script"

      assert_patch(index_live, ~p"/scripts/new")

      assert index_live
             |> form("#script-form", script: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#script-form", script: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/scripts")

      html = render(index_live)
      assert html =~ "Script created successfully"
      assert html =~ "some description"
    end

    test "updates script in listing", %{conn: conn, script: script} do
      {:ok, index_live, _html} = live(conn, ~p"/scripts")

      assert index_live |> element("#scripts-#{script.id} a", "Edit") |> render_click() =~
               "Edit Script"

      assert_patch(index_live, ~p"/scripts/#{script}/edit")

      assert index_live
             |> form("#script-form", script: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#script-form", script: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/scripts")

      html = render(index_live)
      assert html =~ "Script updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes script in listing", %{conn: conn, script: script} do
      {:ok, index_live, _html} = live(conn, ~p"/scripts")

      assert index_live |> element("#scripts-#{script.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#scripts-#{script.id}")
    end
  end

  describe "Show" do
    setup [:create_script]

    test "displays script", %{conn: conn, script: script} do
      {:ok, _show_live, html} = live(conn, ~p"/scripts/#{script}")

      assert html =~ "Show Script"
      assert html =~ script.description
    end

    test "updates script within modal", %{conn: conn, script: script} do
      {:ok, show_live, _html} = live(conn, ~p"/scripts/#{script}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Script"

      assert_patch(show_live, ~p"/scripts/#{script}/show/edit")

      assert show_live
             |> form("#script-form", script: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#script-form", script: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/scripts/#{script}")

      html = render(show_live)
      assert html =~ "Script updated successfully"
      assert html =~ "some updated description"
    end
  end
end
