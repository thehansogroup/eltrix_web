defmodule EltrixSiteWeb.PageController do
  @moduledoc """
  The landing page, the full status table, and the imprint.

  Nothing here writes a capability claim in prose. The page names keys and
  `EltrixSite.Capabilities` answers for them, so a claim the tests stopped
  backing fails the build rather than staying on the page — §5.3.
  """
  use EltrixSiteWeb, :controller

  alias EltrixSite.Capabilities
  alias EltrixSite.Status

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

  def status(conn, _params) do
    rows =
      Status.all()
      |> Enum.map(fn {key, status} ->
        %{key: key, title: Capabilities.title(key), status: status}
      end)
      |> Enum.sort_by(& &1.title)

    conn
    |> assign(:page_title, "Status")
    |> assign(:rows, rows)
    |> render(:status)
  end

  def imprint(conn, _params) do
    conn
    |> assign(:page_title, "Imprint")
    |> render(:imprint)
  end
end
