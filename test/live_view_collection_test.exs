defmodule LiveViewCollectionTest do
  use ExUnit.Case, async: true

  alias LiveViewCollection.Tweet

  defp fixture_tweet_chris do
    LiveViewCollection.insert_tweet!(%{
      "url" => "https://twitter.com/chris_mccord/status/1106291353670045696",
      "html" => "tweet chris"
    })
  end

  defp fixture_tweet_mike do
    LiveViewCollection.insert_tweet!(%{
      "url" => "https://twitter.com/1stAvenger/status/1111740746036592640",
      "html" => "tweet mike"
    })
  end

  defp fixture_tweet_sasa do
    LiveViewCollection.insert_tweet!(%{
      "url" => "https://twitter.com/sasajuric/status/1111987993529729025",
      "html" => "tweet sasa"
    })
  end

  setup do
    on_exit(fn -> :ets.delete_all_objects(:phx_lv_collection) end)
  end

  test "all" do
    fixture_tweet_sasa()

    assert [%Tweet{html: "tweet sasa"}] = LiveViewCollection.all()
  end

  test "count" do
    fixture_tweet_chris()
    fixture_tweet_sasa()

    assert LiveViewCollection.count() == 2
  end

  test "count with search" do
    fixture_tweet_chris()
    fixture_tweet_mike()

    assert LiveViewCollection.count("tweet") == 2
    assert LiveViewCollection.count("chris") == 1
  end

  describe "fetch" do
    test "no query returns all" do
      fixture_tweet_chris()
      fixture_tweet_mike()
      fixture_tweet_sasa()

      assert [%Tweet{html: "tweet chris"}, %Tweet{html: "tweet mike"}, %Tweet{html: "tweet sasa"}] =
               LiveViewCollection.fetch(page: 1, per_page: 3)
    end

    test "empty query" do
      fixture_tweet_chris()

      assert [%Tweet{html: "tweet chris"}] = LiveViewCollection.fetch(query: nil)
      assert [%Tweet{html: "tweet chris"}] = LiveViewCollection.fetch(query: "")
      assert [%Tweet{html: "tweet chris"}] = LiveViewCollection.fetch(query: " ")
    end

    test "contains string" do
      fixture_tweet_chris()
      fixture_tweet_mike()

      assert [%Tweet{html: "tweet chris"}] = LiveViewCollection.fetch(query: "chris")
    end

    test "contains case insensitive string" do
      fixture_tweet_chris()
      fixture_tweet_mike()
      fixture_tweet_sasa()

      assert [%Tweet{html: "tweet chris"}] = LiveViewCollection.fetch(query: "CHRIS")
    end

    test "do not contains string" do
      fixture_tweet_mike()
      fixture_tweet_sasa()

      assert [] = LiveViewCollection.fetch(query: "chris")
    end

    test "limit results per_page" do
      fixture_tweet_chris()
      fixture_tweet_sasa()

      assert [%Tweet{html: "tweet chris"}] = LiveViewCollection.fetch(query: "tweet", per_page: 1)
    end

    test "order by id" do
      # insert sasa tweet first, published after chris
      fixture_tweet_sasa()
      fixture_tweet_chris()

      assert [%Tweet{html: "tweet chris"}, %Tweet{html: "tweet sasa"}] = LiveViewCollection.fetch(query: "tweet")
    end

    test "pagination" do
      fixture_tweet_chris()
      fixture_tweet_mike()
      fixture_tweet_sasa()

      assert [%Tweet{html: "tweet chris"}, %Tweet{html: "tweet mike"}, %Tweet{html: "tweet sasa"}] =
               LiveViewCollection.fetch(page: 1, per_page: 3)

      assert [%Tweet{html: "tweet chris"}] = LiveViewCollection.fetch(page: 1, per_page: 1)
      assert [%Tweet{html: "tweet mike"}] = LiveViewCollection.fetch(page: 2, per_page: 1)
      assert [] = LiveViewCollection.fetch(page: 4, per_page: 1)

      assert [%Tweet{html: "tweet chris"}, %Tweet{html: "tweet mike"}] = LiveViewCollection.fetch(page: 1, per_page: 2)

      assert [%Tweet{html: "tweet sasa"}] = LiveViewCollection.fetch(page: 2, per_page: 2)
      assert [] = LiveViewCollection.fetch(page: 2, per_page: 3)
    end
  end
end
