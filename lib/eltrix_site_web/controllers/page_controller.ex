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
    |> assign(:works, Capabilities.works())
    |> assign(:absent, Capabilities.absent())
    |> render(:home)
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
