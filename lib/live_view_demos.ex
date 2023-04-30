defmodule LiveViewDemos do
  import Ecto.Changeset
  require Logger
  alias LiveViewDemos.Tweet
  alias LiveViewDemos.TaskSupervisor

  @ets_table :live_view_demos

  def load_collection do
    Path.join(File.cwd!(), "collection.yml")
    |> YamlElixir.read_from_file!()
    |> Enum.uniq()
    |> Enum.map(fn url ->
      id = url |> String.split("/") |> List.last()
      %{id: id, url: url}
    end)
    |> Enum.sort_by(& &1.id)
    |> Enum.each(fn tweet ->
      Task.Supervisor.async(TaskSupervisor, fn ->
        Logger.debug("Loading tweet #{tweet.url}")

        "https://publish.twitter.com/oembed?url=#{tweet.url}&omit_script=true&limit=1&hide_thread=true&dnt=true"
        |> Req.get!(
          pool_timeout: 10_000,
          receive_timeout: 30_000,
          connect_options: [timeout: 60_000]
        )
        |> Map.get(:body)
        |> insert_tweet!()
      end)
    end)

    :ok
  end

  def insert_tweet!(%{"url" => url, "html" => _html} = body) do
    body = Map.put(body, "id", url |> String.split("/") |> List.last())
    types = %{id: :string, url: :string, html: :string}

    {%Tweet{}, types}
    |> cast(body, Map.keys(types))
    |> validate_required([:id, :url, :html])
    |> apply_action(:insert)
    |> case do
      {:ok, tweet} ->
        true = :ets.insert(@ets_table, {tweet.id, tweet})
        {:ok, tweet}

      error ->
        error
    end
  end

  def insert_tweet!(_body), do: :skip

  def all do
    case :ets.match(@ets_table, {:_, :"$1"}) do
      [] -> []
      tweets -> List.flatten(tweets)
    end
  end

  def count do
    :ets.select_count(@ets_table, [{{:"$1", :"$2"}, [], [true]}])
  end

  def count(query) when query in [nil, ""], do: count()

  def count(query) do
    match = Regex.compile!(query, "i")

    :ets.foldl(
      fn
        {_id, %Tweet{html: html}}, count = acc ->
          cond do
            String.match?(html, match) -> count + 1
            true -> acc
          end
      end,
      0,
      @ets_table
    )
  end

  def fetch(opts \\ []) do
    query = Keyword.get(opts, :query, "") || ""
    query = String.trim(query)
    match = Regex.compile!(query, "i")
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 15)
    limit = per_page * page

    {_count, records} =
      :ets.foldl(
        fn
          _, {count, records} when count >= limit ->
            {count, records}

          {_id, %Tweet{html: html} = tweet}, {count, records} = acc ->
            cond do
              query == "" ->
                {count + 1, [tweet | records]}

              String.match?(html, match) ->
                {count + 1, [tweet | records]}

              true ->
                acc
            end
        end,
        {0, []},
        @ets_table
      )

    case records do
      [] ->
        []

      records ->
        records
        |> Enum.reverse()
        |> Enum.chunk_every(per_page)
        |> Enum.at(page - 1) || []
    end
  end
end
