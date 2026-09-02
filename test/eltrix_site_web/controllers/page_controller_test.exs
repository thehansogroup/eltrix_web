defmodule EltrixSiteWeb.PageControllerTest do
  @moduledoc """
  What its "third-party" test covers, and what it does not.

  It renders the marketing pages and asserts their `<head>` reaches only the
  one disclosed, self-hosted analytics host. That is the privacy policy's
  *"no third-party script runs on any page"* clause and nothing more.

  It does **not** reach the two places the *"no processor, no analytics
  provider"* clause actually lives: the homeserver's outbound calls and the
  dependency lock files. A page-fetching test cannot see either, and a green
  here is not evidence about them. Those were verified by hand on 2026-09-02
  (Postal SMTP to `smtp.postal.oddie.app`, Garage S3 from env, allowlisted
  federation only; no HTTP-client dep in `eltrix_web`; no phone-home library in
  any `mix.lock`) and would need their own instruments to hold under a test.
  """
  use EltrixSiteWeb.ConnCase, async: false

  alias EltrixSite.Capabilities

  @marketing_pages ~w(/ /terms /privacy /abuse /imprint)
  # Self-hosted Plausible on operator infrastructure. Verified 2026-09-02 to
  # resolve to the same anycast address as `www.eltrix.org` (203.24.209.4)
  # rather than a plausible.io CNAME, which is the observation that makes
  # "self-hosted" a fact rather than a word. The privacy policy discloses it.
  @disclosed_host "https://stats.oddie.app"

  test "the landing page renders every capability card it declares", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    for feature <- Capabilities.features() do
      assert html =~ feature.title
      assert Capabilities.title(feature.key) != nil
    end
  end

  test "the rendered marketing pages reach only the one disclosed self-hosted host",
       %{conn: conn} do
    # The privacy policy claims no third-party script runs on any page. A CDN
    # font, script or stylesheet would be a third party watching everybody who
    # reads the privacy policy, and none contains the word "analytics".
    #
    # A hyperlink is not a request, so `<a href>` to the source or the client is
    # not counted. Only loads are: `src`, `<link href>`, `<iframe src>`,
    # `@import`, and CSS `url()`.
    #
    # Rendered with analytics ON, because that is the state the clause is about
    # and the only state in which the disclosed host appears. The Plausible tag
    # is gated on `:analytics_domain` (`root.html.heex:29`), unset in `:test`,
    # so without this the disclosed host is absent and the control below cannot
    # fire. `fetch_env`, not `get_env`, so an absent key is restored to absent
    # rather than to a stored `nil`.
    saved = Application.fetch_env(:eltrix_site, :analytics_domain)
    Application.put_env(:eltrix_site, :analytics_domain, "eltrix.org")

    on_exit(fn ->
      case saved do
        {:ok, value} -> Application.put_env(:eltrix_site, :analytics_domain, value)
        :error -> Application.delete_env(:eltrix_site, :analytics_domain)
      end
    end)

    external =
      Enum.flat_map(@marketing_pages, fn path ->
        html = conn |> get(path) |> html_response(200)
        Enum.map(external_hosts(html), &{path, &1})
      end)

    # The order matters. This is a negative — "reaches only the disclosed
    # host" — and a negative passes when the page list is empty, when a fetch
    # fails, or when the HTML parses to nothing. So the control is asserted
    # *before* the absence: the disclosed host must actually be found. A run
    # that reports zero external hosts has failed to parse the page, not proved
    # the site clean, and those two are the same green without this line.
    disclosed = Enum.filter(external, fn {_path, host} -> host == @disclosed_host end)

    assert disclosed != [],
           "no page loaded #{@disclosed_host} with analytics configured. Either the " <>
             "render broke or the host extraction did, so a clean result here would be " <>
             "a green that proves nothing."

    foreign = Enum.reject(external, fn {_path, host} -> host == @disclosed_host end)

    assert foreign == [],
           "a marketing page loads a third-party host, which the privacy policy forbids: " <>
             inspect(foreign)
  end

  # Every external host a page *loads* — `src`, `<link href>`, `<iframe src>`,
  # `@import`, CSS `url()`. Not `<a href>`, which is navigation and reaches
  # nothing until clicked.
  defp external_hosts(html) do
    patterns = [
      ~r/\ssrc="(https?:\/\/[^\/"]+)/,
      ~r/<link[^>]+href="(https?:\/\/[^\/"]+)/,
      ~r/@import\s+"?(https?:\/\/[^\/"]+)/,
      ~r/url\(\s*"?(https?:\/\/[^\/")]+)/
    ]

    patterns
    |> Enum.flat_map(fn re ->
      Regex.scan(re, html, capture: :all_but_first) |> List.flatten()
    end)
    |> Enum.uniq()
  end

  test "no page claims a guarantee the build no longer makes", %{conn: conn} do
    # The claim gate went on 2026-08-25 (#7) and the footer went on saying it
    # was there — "the capability statuses on this site are generated from the
    # project's own criteria, and the build fails if a page claims more than
    # they say" — on every page, for as long as nobody read the footer. That is
    # #8's failure mode arriving through #8's own removal: a public page
    # asserting a mechanism, in the present tense, twenty-four hours after the
    # mechanism was deleted.
    #
    # Deliberately narrow. This cannot tell whether a *capability* card is true,
    # which is what #8 is for and what needs Forgejo rather than a regex. It
    # asserts only that the site does not advertise the check that is gone.
    forbidden = [
      ~r/build fails if/i,
      ~r/generated from the project's own (test status|criteria)/i,
      ~r/statuses on this site are generated/i
    ]

    for path <- ["/", "/terms", "/privacy", "/abuse", "/imprint"] do
      html = conn |> get(path) |> html_response(200)

      for pattern <- forbidden do
        refute html =~ pattern,
               "#{path} still advertises the compile-time claim gate (#{inspect(pattern)}), " <>
                 "which was removed in #7"
      end
    end
  end

  test "every page is reachable and has a heading", %{conn: conn} do
    for path <- ["/", "/terms", "/privacy", "/abuse", "/imprint"] do
      assert conn |> get(path) |> html_response(200) =~ "<h1>"
    end
  end
end
