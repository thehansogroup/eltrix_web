defmodule EltrixSiteWeb.Router do
  use EltrixSiteWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EltrixSiteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :well_known do
    plug :accepts, ["json"]
  end

  # Matrix discovery, served as JSON from wherever it is asked for.
  #
  # These must **not** 301 to www (§5.1). A homeserver's server_name is
  # `eltrix.org`, so a peer resolving where to talk to it fetches
  # `eltrix.org/.well-known/matrix/server` — and a blanket apex→www redirect
  # turns federation discovery into a redirect a peer is not obliged to follow.
  # The rule that sends everything else to www is below, and this scope sits in
  # front of it deliberately.
  scope "/.well-known/matrix", EltrixSiteWeb do
    pipe_through :well_known

    get "/server", WellKnownController, :server
    get "/client", WellKnownController, :client
  end

  scope "/", EltrixSiteWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/status", PageController, :status
    get "/terms", PolicyController, :terms
    get "/privacy", PolicyController, :privacy
    get "/abuse", PolicyController, :abuse
    get "/imprint", PageController, :imprint
  end

  if Application.compile_env(:eltrix_site, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EltrixSiteWeb.Telemetry
    end
  end
end
