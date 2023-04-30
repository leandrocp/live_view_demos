defmodule LiveViewDemosWeb.TweetsLive do
  use LiveViewDemosWeb, :live_view

  @default_per_page 15

  @impl true
  def mount(params, _session, socket) do
    count = LiveViewDemos.count()

    {:ok,
     assign(socket,
       current_page: 1,
       page_title: "#{count} demos",
       query: "",
       tweets: fetch(params),
       total_count: count,
       total_query_count: count
     ), temporary_assigns: [tweets: []]}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    path = ~p"/?query=#{query}&page=1"
    {:noreply, push_patch(socket, to: path)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    query = Map.get(params, "query", "")
    page = params |> Map.get("page", "1") |> String.to_integer()
    tweets = fetch(params)
    total_query_count = LiveViewDemos.count(query)
    page_title = if query == "", do: "#{total_query_count} demos", else: query

    {:noreply,
     assign(socket,
       page_title: page_title,
       current_page: page,
       query: query,
       tweets: tweets,
       total_query_count: total_query_count
     )}
  end

  def fetch(params) do
    query = Map.get(params, "query", "")
    page = params |> Map.get("page", "1") |> String.to_integer()
    LiveViewDemos.fetch(query: query, page: page, per_page: @default_per_page)
  end

  def pages(total_query_count) do
    pages = (total_query_count / @default_per_page) |> Float.ceil() |> round()
    if pages <= 1, do: 1, else: pages
  end
end
