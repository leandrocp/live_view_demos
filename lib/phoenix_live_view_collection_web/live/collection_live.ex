defmodule LiveViewCollectionWeb.CollectionLive do
  use LiveViewCollectionWeb, :live_view
  require Logger

  @default_per_page 15

  @impl true
  def mount(params, _session, socket) do
    count = LiveViewCollection.count()

    {:ok,
     assign(socket,
       current_page: 1,
       query: "",
       tweets: fetch(params),
       total_count: count,
       total_query_count: count
     ), temporary_assigns: [tweets: []]}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    path = Routes.collection_path(socket, :index, query: query, page: 1)
    socket = push_patch(socket, to: path)
    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    query = Map.get(params, "query", "")
    page = params |> Map.get("page", "1") |> String.to_integer()

    tweets = fetch(params)
    total_query_count = LiveViewCollection.count(query)

    {:noreply,
     assign(socket,
       page_title: query,
       current_page: page,
       query: query,
       tweets: tweets,
       total_query_count: total_query_count
     )}
  end

  def fetch(params) do
    query = Map.get(params, "query", "")
    page = params |> Map.get("page", "1") |> String.to_integer()
    LiveViewCollection.fetch(query: query, page: page, per_page: @default_per_page)
  end

  def pages(total_query_count) do
    pages = (total_query_count / @default_per_page) |> Float.ceil() |> round()
    if pages <= 1, do: 1, else: pages
  end
end
