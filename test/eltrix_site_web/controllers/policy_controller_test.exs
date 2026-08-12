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

  test "the privacy policy describes the analytics the site actually runs", %{conn: conn} do
    html = conn |> get("/privacy") |> html_response(200)

    # The site counts page views with self-hosted Plausible. A policy that did
    # not say so would be a document the page serving it contradicts, which is
    # the one failure this whole codebase is arranged against.
    assert html =~ "Plausible"
    assert html =~ "self-hosted"

    # And the client is still excluded, which is the part that matters: page
    # addresses in a Matrix client carry room identifiers.
    assert html =~ "does not run on the web client"
  end
end
