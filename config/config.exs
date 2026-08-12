# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :eltrix_site,
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :eltrix_site, EltrixSiteWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: EltrixSiteWeb.ErrorHTML, json: EltrixSiteWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: EltrixSite.PubSub,
  live_view: [signing_salt: "lHT4NcZO"]

# Configure LiveView
config :phoenix_live_view,
  # the attribute set on all root tags. Used for Phoenix.LiveView.ColocatedCSS.
  root_tag_attribute: "phx-r"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  eltrix_site: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ],
  # The stylesheet, which nothing else builds.
  #
  # Tailwind used to be what copied CSS into priv/static. Removing it took the
  # whole CSS pipeline with it and left the layout linking a file that was
  # never written — so the deployed site rendered in Times New Roman with blue
  # underlined links, and every test passed: the pages were correct, the
  # "no external requests" check greps for absolute URLs, and a relative href
  # to a missing file is neither. `assets_test.exs` now asserts the file exists.
  css: [
    args: ~w(css/app.css --bundle --outdir=../priv/static/assets/css),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# No Tailwind and no daisyUI. The design language is the web client's, which is
# a few hundred lines of hand-written CSS built on nine custom properties — and
# a utility framework would be a second, larger vocabulary describing the same
# thing. §5.2 also forbids any runtime external request, so the stylesheet is
# served from here and nothing is fetched.

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# The homeserver this domain delegates to. Configured rather than hardcoded
# because beta and www delegate to different hosts, and getting it wrong is not
# a visible fault — it is a peer quietly talking to the wrong server, or to
# nothing.
config :eltrix_site, homeserver_host: "matrix.eltrix.org"

# Where the source lives.
#
# Configured, not written into a template, because the public mirror is not the
# canonical remote — and because the previous site hardcoded a GitHub URL for a
# repository that did not exist, which is the kind of claim §5.1 exists to stop.
config :eltrix_site,
  source_url: System.get_env("SOURCE_URL", "https://forge.oddie.app/thehansogroup/eltrix_server")
