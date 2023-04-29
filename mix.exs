defmodule LiveViewCollection.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_live_view_collection,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  def application do
    [
      mod: {LiveViewCollection.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.9"},
      {:esbuild, "~> 0.6", runtime: Mix.env() == :dev},
      {:floki, "~> 0.34", only: :test},
      {:gettext, "~> 0.21"},
      {:jason, "~> 1.4"},
      {:phoenix, "1.6.6"},
      {:phoenix_html, "~> 3.2"},
      {:phoenix_live_dashboard, "0.6.2"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_live_view, "0.17.5"},
      {:plug_cowboy, "~> 2.6"},
      {:req, "~> 0.3"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:yaml_elixir, "~> 2.9"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
