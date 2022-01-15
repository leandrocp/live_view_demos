defmodule LiveViewCollection.Collection do
  @moduledoc "Source of truth for collection entries"
  use GenServer
  require Logger

  @default_page_size 15

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec all() :: [map()]
  def all do
    GenServer.call(__MODULE__, :all)
  end

  @spec count() :: non_neg_integer()
  def count do
    GenServer.call(__MODULE__, :count)
  end

  @spec count(String.t()) :: non_neg_integer()
  def count(search) do
    search = cast_search(search)
    GenServer.call(__MODULE__, {:count, search})
  end

  @spec pages(String.t()) :: pos_integer()
  def pages(search) do
    collection_count = count(search)
    pages = (collection_count / @default_page_size()) |> Float.ceil() |> round()
    if pages <= 1, do: 1, else: pages
  end

  @spec fetch(Keyword.t()) :: [map()]
  def fetch(opts \\ []) do
    search = opts |> Keyword.get(:search) |> cast_search()
    page = opts |> Keyword.get(:page) |> cast_page()
    GenServer.call(__MODULE__, {:fetch, search, page})
  end

  defp cast_search(search) when is_binary(search) do
    String.trim(search)
  end

  defp cast_search(_), do: ""

  defp cast_page(page) when is_integer(page) and page >= 1, do: page
  defp cast_page(_), do: 1

  ## Callbacks

  @impl GenServer
  def init(opts) do
    if entries = Keyword.get(opts, :override_entries) do
      {:ok, entries}
    else
      send(self(), :load_collection)
      {:ok, []}
    end
  end

  @impl GenServer
  def handle_info(:load_collection, _state) do
    collection =
      with {:ok, collection} <- YamlElixir.read_from_file(Path.join(File.cwd!(), "collection.yml")),
           :ok <- Logger.debug(fn -> "[Collection] Loading #{length(collection)} entries from collection.yml" end),
           {:ok, collection} <- request_embeded_tweets(collection),
           :ok <- Logger.debug(fn -> "[Collection] Loaded #{length(collection)} entries from twitter" end) do
        collection
      else
        {:error, error} ->
          Logger.error(fn -> "[Collection] Error loading collection: #{inspect(error)}" end)
          []
      end

    {:noreply, collection}
  end

  defp request_embeded_tweets([]), do: {:ok, []}

  defp request_embeded_tweets(collection) do
    {:ok,
     collection
     |> Enum.map(&fetch_tweet(&1))
     |> Enum.reject(&is_nil/1)}
  end

  defp fetch_tweet(tweet_url) when is_nil(tweet_url) or tweet_url == "", do: nil

  defp fetch_tweet(tweet_url) when is_binary(tweet_url) do
    with {:ok, %{body: body, status_code: 200}} <-
           Mojito.request(
             method: :get,
             url: "https://publish.twitter.com/oembed?url=#{tweet_url}&omit_script=true&hide_thread=true&dnt=true"
           ),
         {:ok, tweet} <- Jason.decode(body) do
      id = tweet_url |> String.split("/") |> List.last()
      Map.put(tweet, "id", id)
    else
      _ ->
        Logger.error(fn -> "[Collection] Error fetching embeded tweet: #{tweet_url}" end)
        nil
    end
  end

  @impl GenServer
  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:count, _from, state) do
    {:reply, length(state), state}
  end

  def handle_call({:count, search}, _from, state) do
    count = state |> do_filter(search) |> length()
    {:reply, count, state}
  end

  def handle_call({:fetch, search, page}, _from, state) do
    result =
      state
      |> do_filter(search)
      |> do_paginate(page)

    {:reply, result, state}
  end

  defp do_filter(collection, ""), do: collection

  defp do_filter(collection, search) do
    {:ok, regex} = Regex.compile(search, "i")

    Enum.filter(collection, fn
      %{"html" => search} -> String.match?(search, regex)
      _ -> false
    end)
  end

  defp do_paginate(collection, page) do
    Enum.slice(collection, (page - 1) * @default_page_size(), @default_page_size())
  end
end
