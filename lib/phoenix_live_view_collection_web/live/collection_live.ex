defmodule LiveViewCollectionWeb.CollectionLive do
  use LiveViewCollectionWeb, :live_view
  require Logger
  alias LiveViewCollection.Collection

  @impl true
  def mount(_params, _session, socket) do
    collection = Collection.fetch()
    collection_count = length(collection)
    {:ok, assign(socket, query: "", collection: Collection.fetch(), collection_count: collection_count)}
  end

  @impl true
  def handle_event("search", %{"search" => query}, socket) do
    {:noreply, redirect_attrs(socket, query: query, page: 1)}
  end

  defp redirect_attrs(socket, attrs) do
    query = attrs[:query] || socket.assigns[:query]

    path = Routes.collection_path(socket, :index, query: query)
    push_patch(socket, to: path)
  end

  @impl true
  def handle_params(params, _url, socket) do
    query = Map.get(params, "query", "")
    collection = Collection.fetch(query)
    {:noreply, assign(socket, collection: collection, query: query)}
  end
end
