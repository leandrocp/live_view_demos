defmodule LiveViewCollection.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveViewCollectionWeb.Telemetry,
      {Phoenix.PubSub, name: LiveViewCollection.PubSub},
      LiveViewCollectionWeb.Endpoint
    ]

    children =
      if Mix.env() == :test do
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
