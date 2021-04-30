defmodule PhoenixLiveViewCollection.CollectionTest do
  use ExUnit.Case, async: true
  alias LiveViewCollection.Collection

  describe "with empty collection" do
    setup do
      start_supervised!({Collection, override_entries: []}, restart: :temporary)
      :ok
    end

    test "operations" do
      assert Collection.all() == []
      assert Collection.count() == 0
      assert Collection.count("A") == 0
      assert Collection.fetch(search: "A") == []
      assert Collection.pages("A") == 1
    end
  end

  describe "with filled collection" do
    @entries for i <- 1..21, do: %{"html" => "entry #{i}"}
    @first_page for i <- 1..15, do: %{"html" => "entry #{i}"}

    setup do
      start_supervised!({Collection, override_entries: @entries}, restart: :temporary)
      :ok
    end

    test "all" do
      assert Collection.all() == @entries
    end

    test "count" do
      assert Collection.count() == 21
      assert Collection.count(nil) == 21
      assert Collection.count("") == 21
      assert Collection.count("entry") == 21
      assert Collection.count("entry 21") == 1
    end

    test "pages" do
      assert Collection.pages("entry") == 2
      assert Collection.pages("entry 21") == 1
      assert Collection.pages("") == 2
      assert Collection.pages(nil) == 2
      assert Collection.pages("null") == 1
    end

    test "fetch pagination" do
      assert Collection.fetch(page: 1) == @first_page
      assert Collection.fetch(page: nil) == @first_page
      assert Collection.fetch(page: -1) == @first_page
      assert Collection.fetch(page: 0) == @first_page

      assert Collection.fetch(page: 2) == [
               %{"html" => "entry 16"},
               %{"html" => "entry 17"},
               %{"html" => "entry 18"},
               %{"html" => "entry 19"},
               %{"html" => "entry 20"},
               %{"html" => "entry 21"}
             ]

      assert Collection.fetch(page: 3) == []
    end

    test "fetch search" do
      assert Collection.fetch(search: nil) == @first_page
      assert Collection.fetch(search: "") == @first_page
      assert Collection.fetch(search: "entry") == @first_page
      assert Collection.fetch(search: "entry 21") == [%{"html" => "entry 21"}]
    end

    test "fetch pagination and search" do
      assert Collection.fetch(page: 1, search: "entry") == @first_page

      assert Collection.fetch(page: 2, search: "entry") == [
               %{"html" => "entry 16"},
               %{"html" => "entry 17"},
               %{"html" => "entry 18"},
               %{"html" => "entry 19"},
               %{"html" => "entry 20"},
               %{"html" => "entry 21"}
             ]

      assert Collection.fetch(page: 3, search: "entry") == []
      assert Collection.fetch(page: 1, search: "entry 21") == [%{"html" => "entry 21"}]
      assert Collection.fetch(page: 2, search: "entry 21") == []
      assert Collection.fetch(page: 1, search: "null") == []
      assert Collection.fetch(page: nil, search: nil) == @first_page
      assert Collection.fetch(page: "", search: "") == @first_page
    end
  end
end
