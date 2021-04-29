defmodule LiveViewCollection.Collection do
  use GenServer
  require Logger

  @default_query ""

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec fetch(String.t() | nil) :: :ok
  def fetch(query \\ @default_query) do
    GenServer.call(__MODULE__, {:fetch, query})
  end

  ## Callbacks

  @impl GenServer
  def init(state) do
    send(self(), :load_collection)
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:load_collection, _state) do
    collection =
      with {:ok, collection} <- YamlElixir.read_from_file(Path.join(File.cwd!(), "collection.yml")),
           {:ok, collection} <- request_embeded_tweets(collection) do
        collection
      else
        {:error, error} ->
          Logger.error(fn -> "Error loading collection: #{inspect(error)}" end)
          []
      end

    {:noreply, collection}
  end

  defp request_embeded_tweets([]), do: {:ok, []}

  defp request_embeded_tweets(collection) do
    fetch_tweet = fn tweet_url ->
      with {:ok, %{body: body}} <-
             Mojito.request(
               method: :get,
               url: "https://publish.twitter.com/oembed?url=#{tweet_url}&omit_script=true&hide_thread=true"
             ),
           {:ok, tweet} <- Jason.decode(body) do
        tweet
      else
        {:error, error} ->
          Logger.error(fn -> "Error fetching embeded tweet: #{inspect(error)}" end)
          nil
      end
    end

    {:ok,
     collection
     |> Enum.map(&fetch_tweet.(&1["tweet_url"]))
     |> Enum.reject(&is_nil/1)}
  end

  @impl GenServer
  def handle_call({:fetch, query}, _from, state) do
    result = do_filter(state, query)
    {:reply, result, state}
  end

  defp do_filter(collection, query) when is_nil(query) or query == "", do: collection

  defp do_filter(collection, query) do
    {:ok, regex} = Regex.compile(query, "i")

    Enum.filter(collection, fn %{"html" => search} ->
      String.match?(search, regex)
    end)
  end
end
