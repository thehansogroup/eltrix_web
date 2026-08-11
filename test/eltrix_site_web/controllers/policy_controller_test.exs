defmodule EltrixSiteWeb.PolicyControllerTest do
  @moduledoc """
  The three documents §4.7 requires to be published and reachable.
  """
  use EltrixSiteWeb.ConnCase, async: true

  alias EltrixSite.Policies

  test "each document is served", %{conn: conn} do
    for %{slug: slug, title: title} <- Policies.all() do
      html = conn |> get("/#{slug}") |> html_response(200)
      assert html =~ title
    end
  end

  test "the draft banner is rendered, not stripped", %{conn: conn} do
    # These have not been read by a lawyer and each says so in its first lines.
    # Rendering the body while dropping that caveat would turn a document that
    # is careful about its own standing into one that quietly claims force.
    for slug <- ["terms", "privacy", "abuse"] do
      assert conn |> get("/#{slug}") |> html_response(200) =~ "not yet in force" or
               conn |> get("/#{slug}") |> html_response(200) =~ "Not yet live"
    end
  end

  test "the privacy policy still says there is no analytics", %{conn: conn} do
    # Pinned because it is the claim most likely to quietly stop being true.
    assert conn |> get("/privacy") |> html_response(200) =~ "No analytics"
  end
end
