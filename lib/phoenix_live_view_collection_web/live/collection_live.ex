defmodule LiveViewCollectionWeb.CollectionLive do
  use LiveViewCollectionWeb, :live_view
  require Logger
  alias LiveViewCollection.Collection

  @impl true
  def mount(_params, _session, socket) do
    page = 1
    search = ""
    collection = Collection.fetch(page: page, search: search)
    collection_count = Collection.count()

    {:ok,
     assign(socket,
       page: page,
       search: search,
       collection: collection,
       collection_count: collection_count
     )}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    path = Routes.collection_path(socket, :index, search: search, page: 1)
    socket = push_patch(socket, to: path)
    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    search = Map.get(params, "search", "")
    page = params |> Map.get("page", "1") |> String.to_integer()
    collection = Collection.fetch(search: search, page: page)
    {:noreply, assign(socket, collection: collection, search: search, page: page)}
  end

  ## Helpers

  def pages(search) do
    collection_count = Collection.count(search)
    pages = (collection_count / Collection.default_page_size()) |> Float.ceil() |> round()
    if pages <= 1, do: 1, else: pages
  end
end
