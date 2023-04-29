defmodule LiveViewCollection.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveViewCollectionWeb.Telemetry,
      {Phoenix.PubSub, name: LiveViewCollection.PubSub},
      LiveViewCollectionWeb.Endpoint,
      {Task.Supervisor, name: LiveViewCollection.TaskSupervisor}
    ]

    :ets.new(:phx_lv_collection, [:ordered_set, :named_table, :public, read_concurrency: true])

    opts = [strategy: :one_for_one, name: LiveViewCollection.Supervisor]
    sup = Supervisor.start_link(children, opts)

    :ok = LiveViewCollection.load_collection()

    sup
  end

  @impl true
  def config_change(changed, _new, removed) do
    LiveViewCollectionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
