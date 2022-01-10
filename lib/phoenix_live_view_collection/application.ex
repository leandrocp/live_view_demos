defmodule LiveViewCollection.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveViewCollectionWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveViewCollection.PubSub},
      # Start the Endpoint (http/https)
      LiveViewCollectionWeb.Endpoint
      # Start a worker by calling: LiveViewCollection.Worker.start_link(arg)
      # {LiveViewCollection.Worker, arg}
    ]

    children =
      if Mix.env() == :test do
        children
      else
        children ++ [{LiveViewCollection.Collection, []}]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveViewCollection.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveViewCollectionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
