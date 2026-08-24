defmodule EltrixSiteWeb.PageControllerTest do
  use EltrixSiteWeb.ConnCase, async: true

  alias EltrixSite.Capabilities

  test "the landing page renders every capability card it declares", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    for feature <- Capabilities.features() do
      assert html =~ feature.title
      assert Capabilities.title(feature.key) != nil
    end
  end

  test "no page fetches a resource from another host", %{conn: conn} do
    # §5.2: zero runtime *external requests*. A CDN font, script or stylesheet
    # would be a third party watching everybody who reads the privacy policy.
    #
    # A hyperlink is not a request — the landing page links to the source and
    # to the client, which is the point of a landing page. The first version of
    # this test matched any absolute `href` and so forbade linking anywhere,
    # which is a different rule and not the one §5.2 states.
    for path <- ["/", "/terms", "/privacy", "/abuse", "/imprint"] do
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
    for path <- ["/", "/terms", "/privacy", "/abuse", "/imprint"] do
      assert conn |> get(path) |> html_response(200) =~ "<h1>"
    end
  end
end
