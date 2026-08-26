defmodule EltrixSiteWeb.PageController do
  @moduledoc """
  The landing page and the imprint.

  The capability cards come from `EltrixSite.Capabilities`. Nothing verifies
  them any more — see `thehansogroup/eltrix_web#8`.
  """
  use EltrixSiteWeb, :controller

  alias EltrixSite.Capabilities

  def home(conn, _params) do
    conn
    |> assign(:page_title, nil)
    |> assign(:features, Capabilities.features())
    |> assign(:done_count, length(Capabilities.works()))
    |> assign(:source_url, Application.fetch_env!(:eltrix_site, :source_url))
    |> assign(:shots, shots())
    |> render(:home)
  end

  # Placeholders, and deliberately placeholders rather than mockups.
  #
  # The previous site showed a product that did not exist — a Helm chart, an
  # admin API, OIDC. An invented screenshot is the same lie in a different
  # medium, and the one people believe fastest. These say what will go here and
  # what its state is; the web client one is replaced first because that client
  # is live.
  defp shots do
    [
      %{
        title: "Web client",
        note: "Live at app-beta.eltrix.org",
        placeholder: "screenshot pending",
        ratio: "16 / 10",
        state: "live"
      },
      %{
        title: "iOS",
        note: "In development",
        placeholder: "screenshot pending",
        ratio: "9 / 16",
        state: "building"
      },
      %{
        title: "iPadOS",
        note: "In development",
        placeholder: "screenshot pending",
        ratio: "4 / 3",
        state: "building"
      }
    ]
  end

  def imprint(conn, _params) do
    conn
    |> assign(:page_title, "Imprint")
    |> render(:imprint)
  end
end
