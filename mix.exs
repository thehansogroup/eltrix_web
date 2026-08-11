defmodule EltrixSite.MixProject do
  use Mix.Project

  def project do
    [
      app: :eltrix_site,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {EltrixSite.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test, ci: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8.9"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.2.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      # Markdown for the policy documents, rendered at compile time. Not a
      # runtime dependency of a page: see EltrixSite.Policies.
      {:earmark, "~> 1.4"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["compile", "esbuild eltrix_site"],
      "assets.deploy": ["esbuild eltrix_site --minify", "phx.digest"],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"],
      # The same shape as eltrix_server's gate: CI runs this alias and nothing
      # else. `compile --force` matters — the claims in EltrixSite.Capabilities
      # are checked while compiling, so an incremental build with a warm beam
      # would skip the one check this site exists to make.
      ci: [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "compile --force --warnings-as-errors",
        "test"
      ]
    ]
  end
end
