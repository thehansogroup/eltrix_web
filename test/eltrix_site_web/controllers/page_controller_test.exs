defmodule EltrixSiteWeb.PageControllerTest do
  use EltrixSiteWeb.ConnCase, async: true

  alias EltrixSite.Capabilities

  test "the landing page lists what works, from status.json", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    for capability <- Capabilities.works() do
      assert html =~ capability.title
    end
  end

  test "the landing page also lists what does not work", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    # The half that is easy to drop. A site showing only its finished features
    # is not lying by sentence and is lying by shape, and this is the assertion
    # that stops somebody "tidying" the second list away.
    absent = Capabilities.absent()
    assert absent != [], "nothing is partial or missing, which is implausible — check status.json"

    for capability <- absent do
      assert html =~ capability.title
    end
  end

  test "no page makes a request to another host", %{conn: conn} do
    # §5.2: zero runtime external requests. A CDN font or script would be a
    # third party watching everybody who reads the privacy policy.
    for path <- ["/", "/status", "/terms", "/privacy", "/abuse", "/imprint"] do
      html = conn |> get(path) |> html_response(200)

      refute html =~ ~r/(src|href)="https?:\/\//,
             "#{path} references an external host"
    end
  end

  test "every page is reachable and has a heading", %{conn: conn} do
    for path <- ["/", "/status", "/terms", "/privacy", "/abuse", "/imprint"] do
      assert conn |> get(path) |> html_response(200) =~ "<h1>"
    end
  end

  test "the status page lists every key", %{conn: conn} do
    html = conn |> get(~p"/status") |> html_response(200)

    for {key, _status} <- EltrixSite.Status.all() do
      assert html =~ Capabilities.title(key)
    end
  end
end
