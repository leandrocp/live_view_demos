defmodule LiveViewCollection.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveViewCollectionWeb.Telemetry,
      {PhoenixProfiler, name: LiveViewCollection.Profiler},
      {Phoenix.PubSub, name: LiveViewCollection.PubSub},
      LiveViewCollectionWeb.Endpoint
    ]

    children =
      if Application.get_env(:phoenix_live_view_collection, :env) == :test do
        children
      else
        children ++ [{LiveViewCollection.Collection, []}]
      end

    opts = [strategy: :one_for_one, name: LiveViewCollection.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    LiveViewCollectionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
