defmodule PhoenixLiveViewCollectionWeb.Live.CollectionLiveTest do
  use LiveViewCollectionWeb.ConnCase
  import Phoenix.LiveViewTest
  alias LiveViewCollection.Collection

  @entries for i <- 1..21, do: %{"html" => "entry #{i}"}

  setup do
    start_supervised!({Collection, override_entries: @entries}, restart: :temporary)
    :ok
  end

  describe "pagination" do
    test "next clicking on page number", %{conn: conn} do
      assert {:ok, view, html} = live(conn, "/")

      assert html =~ "entry 15"
      refute html =~ "entry 16"

      {_, {:redirect, %{to: to}}} =
        reason =
        view
        |> element("#page-2")
        |> render_click()

      {:ok, conn} = follow_redirect(reason, conn, to)
      assert {:ok, _view, html} = live(conn, to)

      refute html =~ "entry 15"
      assert html =~ "entry 16"
    end

    test "next clicking on next button", %{conn: conn} do
      assert {:ok, view, html} = live(conn, "/")

      assert html =~ "entry 15"
      refute html =~ "entry 16"

      {_, {:redirect, %{to: to}}} =
        reason =
        view
        |> element("#page-next")
        |> render_click()

      {:ok, conn} = follow_redirect(reason, conn, to)
      assert {:ok, _view, html} = live(conn, to)

      refute html =~ "entry 15"
      assert html =~ "entry 16"
    end

    test "previous clicking on page number", %{conn: conn} do
      assert {:ok, view, html} = live(conn, "/?page=2")

      refute html =~ "entry 15"
      assert html =~ "entry 16"

      {_, {:redirect, %{to: to}}} =
        reason =
        view
        |> element("#page-1")
        |> render_click()

      {:ok, conn} = follow_redirect(reason, conn, to)
      assert {:ok, _view, html} = live(conn, to)

      assert html =~ "entry 15"
      refute html =~ "entry 16"
    end

    test "previous clicking on previous button", %{conn: conn} do
      assert {:ok, view, html} = live(conn, "/?page=2")

      refute html =~ "entry 15"
      assert html =~ "entry 16"

      {_, {:redirect, %{to: to}}} =
        reason =
        view
        |> element("#page-previous")
        |> render_click()

      {:ok, conn} = follow_redirect(reason, conn, to)
      assert {:ok, _view, html} = live(conn, to)

      assert html =~ "entry 15"
      refute html =~ "entry 16"
    end
  end

  test "search", %{conn: conn} do
    assert {:ok, view, html} = live(conn, "/")

    assert html =~ "Search 21 demos"

    assert view
           |> element("form")
           |> render_change(%{search: "entry 21"}) =~ "entry 21"
  end
end
