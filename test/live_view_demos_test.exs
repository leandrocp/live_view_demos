defmodule LiveViewDemosTest do
  use ExUnit.Case, async: true

  alias LiveViewDemos.Tweet

  defp fixture_tweet_chris do
    LiveViewDemos.insert_tweet!(%{
      "url" => "https://twitter.com/chris_mccord/status/1106291353670045696",
      "html" => "tweet chris"
    })
  end

  defp fixture_tweet_mike do
    LiveViewDemos.insert_tweet!(%{
      "url" => "https://twitter.com/1stAvenger/status/1111740746036592640",
      "html" => "tweet mike"
    })
  end

  defp fixture_tweet_sasa do
    LiveViewDemos.insert_tweet!(%{
      "url" => "https://twitter.com/sasajuric/status/1111987993529729025",
      "html" => "tweet sasa"
    })
  end

  setup do
    on_exit(fn -> :ets.delete_all_objects(:live_view_demos) end)
  end

  test "all" do
    fixture_tweet_sasa()

    assert [%Tweet{html: "tweet sasa"}] = LiveViewDemos.all()
  end

  test "count" do
    fixture_tweet_chris()
    fixture_tweet_sasa()

    assert LiveViewDemos.count() == 2
  end

  test "count with search" do
    fixture_tweet_chris()
    fixture_tweet_mike()

    assert LiveViewDemos.count("tweet") == 2
    assert LiveViewDemos.count("chris") == 1
  end

  describe "fetch" do
    test "no query returns all" do
      fixture_tweet_chris()
      fixture_tweet_mike()
      fixture_tweet_sasa()

      assert [%Tweet{html: "tweet chris"}, %Tweet{html: "tweet mike"}, %Tweet{html: "tweet sasa"}] =
               LiveViewDemos.fetch(page: 1, per_page: 3)
    end

    test "empty query" do
      fixture_tweet_chris()

      assert [%Tweet{html: "tweet chris"}] = LiveViewDemos.fetch(query: nil)
      assert [%Tweet{html: "tweet chris"}] = LiveViewDemos.fetch(query: "")
      assert [%Tweet{html: "tweet chris"}] = LiveViewDemos.fetch(query: " ")
    end

    test "contains string" do
      fixture_tweet_chris()
      fixture_tweet_mike()

      assert [%Tweet{html: "tweet chris"}] = LiveViewDemos.fetch(query: "chris")
    end

    test "contains case insensitive string" do
      fixture_tweet_chris()
      fixture_tweet_mike()
      fixture_tweet_sasa()

      assert [%Tweet{html: "tweet chris"}] = LiveViewDemos.fetch(query: "CHRIS")
    end

    test "do not contains string" do
      fixture_tweet_mike()
      fixture_tweet_sasa()

      assert [] = LiveViewDemos.fetch(query: "chris")
    end

    test "limit results per_page" do
      fixture_tweet_chris()
      fixture_tweet_sasa()

      assert [%Tweet{html: "tweet chris"}] = LiveViewDemos.fetch(query: "tweet", per_page: 1)
    end

    test "order by id" do
      # insert sasa tweet first, published after chris
      fixture_tweet_sasa()
      fixture_tweet_chris()

      assert [%Tweet{html: "tweet chris"}, %Tweet{html: "tweet sasa"}] = LiveViewDemos.fetch(page: 1, per_page: 2)
      assert [%Tweet{html: "tweet chris"}] = LiveViewDemos.fetch(page: 1, per_page: 1)
      assert [%Tweet{html: "tweet sasa"}] = LiveViewDemos.fetch(page: 2, per_page: 1)
      assert [] = LiveViewDemos.fetch(page: 3, per_page: 1)
    end
  end
end
