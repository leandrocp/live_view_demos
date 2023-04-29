defmodule LiveViewCollectionWeb.CollectionLiveTest do
  use LiveViewCollectionWeb.ConnCase
  import Phoenix.LiveViewTest

  @entries for tweet_id <- 100..121, do: %{"url" => "//#{tweet_id}", "html" => "<div></div>"}

  setup do
    for entry <- @entries, do: {:ok, _} = LiveViewCollection.insert_tweet!(entry)
    on_exit(fn -> :ets.delete_all_objects(:phx_lv_collection) end)
    :ok
  end

  describe "pagination" do
    test "next clicking on page number", %{conn: conn} do
      assert {:ok, view, _html} = live(conn, "/")

      assert has_element?(view, "#tweet-id-114")
      refute has_element?(view, "#tweet-id-115")

      view
      |> element("#page-2")
      |> render_click()

      refute has_element?(view, "#tweet-id-114")
      assert has_element?(view, "#tweet-id-115")
    end

    test "next clicking on next button", %{conn: conn} do
      assert {:ok, view, _html} = live(conn, "/")

      assert has_element?(view, "#tweet-id-114")
      refute has_element?(view, "#tweet-id-115")

      view
      |> element("#page-next")
      |> render_click()

      refute has_element?(view, "#tweet-id-114")
      assert has_element?(view, "#tweet-id-115")
    end

    test "previous clicking on page number", %{conn: conn} do
      assert {:ok, view, _html} = live(conn, "/?page=2")

      refute has_element?(view, "#tweet-id-114")
      assert has_element?(view, "#tweet-id-115")

      view
      |> element("#page-1")
      |> render_click()

      assert has_element?(view, "#tweet-id-114")
      refute has_element?(view, "#tweet-id-115")
    end

    test "previous clicking on previous button", %{conn: conn} do
      assert {:ok, view, _html} = live(conn, "/?page=2")

      refute has_element?(view, "#tweet-id-114")
      assert has_element?(view, "#tweet-id-115")

      view
      |> element("#page-previous")
      |> render_click()

      assert has_element?(view, "#tweet-id-114")
      refute has_element?(view, "#tweet-id-115")
    end
  end

  test "search", %{conn: conn} do
    assert {:ok, view, html} = live(conn, "/")

    assert html =~ "Search 22 tweets"

    assert view
           |> element("form")
           |> render_change(%{query: "tweet-id-22"}) =~ "tweet-id-22"
  end
end
