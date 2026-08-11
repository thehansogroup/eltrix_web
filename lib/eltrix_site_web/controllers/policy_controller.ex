defmodule EltrixSiteWeb.PolicyController do
  @moduledoc """
  The three documents §4.7 requires to be published and reachable.

  One action per document rather than a `:slug` parameter. The set is fixed and
  small, and a parameterised route invites a path that renders whatever file is
  named — which is precisely the traversal Sobelow flagged in the server's own
  docs generator the first time that gate ran.
  """
  use EltrixSiteWeb, :controller

  alias EltrixSite.Policies

  def terms(conn, _params), do: render_policy(conn, "terms")
  def privacy(conn, _params), do: render_policy(conn, "privacy")
  def abuse(conn, _params), do: render_policy(conn, "abuse")

  defp render_policy(conn, slug) do
    document = Policies.get(slug)

    conn
    |> assign(:page_title, document.title)
    |> assign(:document, document)
    |> assign(:html, Policies.html!(slug))
    |> render(:show)
  end
end
