defmodule EltrixSite.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EltrixSiteWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:eltrix_site, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: EltrixSite.PubSub},
      # Start a worker by calling: EltrixSite.Worker.start_link(arg)
      # {EltrixSite.Worker, arg},
      # Start to serve requests, typically the last entry
      EltrixSiteWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EltrixSite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EltrixSiteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
