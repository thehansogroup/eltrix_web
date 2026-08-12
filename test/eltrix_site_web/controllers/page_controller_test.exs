defmodule EltrixSiteWeb.PageControllerTest do
  use EltrixSiteWeb.ConnCase, async: true

  alias EltrixSite.Capabilities

  test "the landing page sells on capabilities that are actually done", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    for feature <- Capabilities.features() do
      assert html =~ feature.title
      assert Capabilities.title(feature.key) != nil
    end
  end

  test "the status page lists what works", %{conn: conn} do
    html = conn |> get(~p"/status") |> html_response(200)

    for capability <- Capabilities.works() do
      assert html =~ capability.title
    end
  end

  test "the status page also lists what does not work", %{conn: conn} do
    # The half that is easy to drop. A site showing only its finished features
    # is not lying by sentence and is lying by shape, and this is the assertion
    # that stops somebody "tidying" the second list away. It moved here with the
    # lists themselves when the landing page became a landing page.
    html = conn |> get(~p"/status") |> html_response(200)

    absent = Capabilities.absent()
    assert absent != [], "nothing is partial or missing, which is implausible — check status.json"

    for capability <- absent do
      assert html =~ capability.title
    end
  end

  test "the landing page links to the full status rather than hiding it", %{conn: conn} do
    # A marketing page that shows six good things and no way to the rest is the
    # shape this project exists not to be.
    assert conn |> get(~p"/") |> html_response(200) =~ ~s(href="/status")
  end

  test "no page fetches a resource from another host", %{conn: conn} do
    # §5.2: zero runtime *external requests*. A CDN font, script or stylesheet
    # would be a third party watching everybody who reads the privacy policy.
    #
    # A hyperlink is not a request — the landing page links to the source and
    # to the client, which is the point of a landing page. The first version of
    # this test matched any absolute `href` and so forbade linking anywhere,
    # which is a different rule and not the one §5.2 states.
    for path <- ["/", "/status", "/terms", "/privacy", "/abuse", "/imprint"] do
      html = conn |> get(path) |> html_response(200)

      # One exception, deliberately named rather than a loosened pattern:
      # self-hosted Plausible on infrastructure the operator runs. Cookie-free,
      # no personal data, and the privacy policy says so. Any *other* external
      # host still fails, which is the rule §5.2 is actually protecting.
      external =
        Regex.scan(~r/\ssrc="(https?:\/\/[^\/"]+)/, html, capture: :all_but_first)
        |> List.flatten()
        |> Enum.reject(&(&1 == "https://stats.oddie.app"))

      assert external == [], "#{path} loads a resource from #{inspect(external)}"

      refute html =~ ~r/<link[^>]+href="https?:\/\//,
             "#{path} links a stylesheet or icon from an external host"

      refute html =~ ~r/@import/, "#{path} imports a stylesheet"
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
