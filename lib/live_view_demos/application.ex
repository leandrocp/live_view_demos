defmodule LiveViewDemos.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveViewDemosWeb.Telemetry,
      {Phoenix.PubSub, name: LiveViewDemos.PubSub},
      {Finch, name: LiveViewDemos.Finch},
      LiveViewDemosWeb.Endpoint,
      {Task.Supervisor, name: LiveViewDemos.TaskSupervisor}
    ]

    :ets.new(:live_view_demos, [:ordered_set, :named_table, :public, read_concurrency: true])

    opts = [strategy: :one_for_one, name: LiveViewDemos.Supervisor]
    sup = Supervisor.start_link(children, opts)

    :ok = LiveViewDemos.load_collection()

    sup
  end

  @impl true
  def config_change(changed, _new, removed) do
    LiveViewDemosWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
