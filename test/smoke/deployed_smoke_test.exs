defmodule EltrixSite.DeployedSmokeTest do
  @moduledoc """
  The site as it is actually served, over the public internet, through the edge.

  `GOAL.md` §10.8 asks for this by name, and §5.5 is the criterion. Everything
  else in `test/` asserts on a router in this VM, which cannot answer the
  questions that have actually gone wrong here: whether a route is reachable
  *through the edge*, whether a link on a page goes anywhere, and whether the
  Matrix delegation is served as JSON without a redirect.

      ELTRIX_SITE_SMOKE_URL=https://beta.eltrix.org mix smoke

  Skipped, not failed, when the variable is unset: a suite that goes red on a
  laptop with no deployment teaches people to ignore red.

  ## Why the route list is derived and not written down

  `Router.__routes__/0` is the same list the site serves from, so a route added
  tomorrow is smoked tomorrow. A hand-kept copy is a second place to be wrong,
  and the failure mode is silent — the new page is simply never checked, which
  is how `/relations` on the wrong version survived in the other repository.

  ## `:httpc`, not a client library

  Two reasons. It adds no dependency to a site that has no HTTP client and
  needs none at runtime. And it makes *not* following redirects the explicit
  default, which matters: the whole point of the well-known assertions is that
  those two paths answer directly, and a client that quietly follows a 301
  cannot tell a served document from a redirected one.
  """
  use ExUnit.Case, async: false

  @moduletag :smoke
  @moduletag timeout: 120_000

  defp base, do: System.fetch_env!("ELTRIX_SITE_SMOKE_URL") |> String.trim_trailing("/")

  setup_all do
    unless System.get_env("ELTRIX_SITE_SMOKE_URL") do
      raise "ELTRIX_SITE_SMOKE_URL is unset — run this through `mix smoke`"
    end

    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)
    :ok
  end

  describe "every route the site actually serves" do
    test "answers through the edge" do
      for path <- smokeable_paths() do
        {status, _headers, _body} = get(path)

        assert status == 200,
               "#{path} answered #{status} through the edge — a route the router serves " <>
                 "and the deployment does not is a page nobody can reach"
      end
    end
  end

  describe "the Matrix delegation" do
    # §5.1: these must never 301. A homeserver's server_name is `eltrix.org`, so
    # a peer resolving where to talk to it fetches this path — and a peer is not
    # obliged to follow a redirect, so an apex→www rule in front of these turns
    # federation discovery off.
    test "/.well-known/matrix/server is JSON, served directly" do
      {status, headers, body} = get("/.well-known/matrix/server")

      assert status == 200, "the server delegation answered #{status}"
      assert header(headers, "content-type") =~ "application/json"

      assert {:ok, %{"m.server" => server}} = Jason.decode(body)
      assert is_binary(server) and server != ""

      # A host and a port. Without the port every peer tries 8448 and finds
      # nothing, which is the failure §4.6 names in the other repository.
      assert String.contains?(server, ":"), "m.server names no port: #{server}"
    end

    test "/.well-known/matrix/client is JSON, served directly" do
      {status, headers, body} = get("/.well-known/matrix/client")

      assert status == 200, "the client delegation answered #{status}"
      assert header(headers, "content-type") =~ "application/json"

      assert {:ok, %{"m.homeserver" => %{"base_url" => url}}} = Jason.decode(body)
      assert String.starts_with?(url, "https://"), "the homeserver base_url is not https: #{url}"
    end
  end

  describe "the links on the pages" do
    test "no internal link 404s" do
      # Collected across every page rather than checked per page, so a footer
      # link is followed once instead of once per page that carries the footer.
      links =
        smokeable_paths()
        |> Enum.flat_map(fn path ->
          {_status, _headers, body} = get(path)
          body |> internal_links() |> Enum.map(&{path, &1})
        end)
        |> Enum.uniq_by(fn {_from, link} -> link end)

      assert links != [], "no internal links were found at all, which is not a page"

      broken =
        for {from, link} <- links,
            {status, _h, _b} = get(link),
            status >= 400,
            do: "#{link} (#{status}), linked from #{from}"

      assert broken == [], "internal links that go nowhere:\n  " <> Enum.join(broken, "\n  ")
    end
  end

  # --- the wire ------------------------------------------------------------

  defp get(path) do
    url = String.to_charlist(base() <> path)

    {:ok, {{_v, status, _r}, headers, body}} =
      :httpc.request(
        :get,
        {url, [{~c"user-agent", ~c"eltrix-site-smoke"}]},
        [
          # Never followed. Whether a path answers or redirects is exactly what
          # the well-known assertions are about, and a redirect this suite could
          # not see would make a broken delegation look like a working one.
          {:autoredirect, false},
          {:timeout, 20_000}
        ],
        []
      )

    {status, headers, IO.iodata_to_binary(body)}
  end

  defp header(headers, name) do
    headers
    |> Enum.find_value("", fn {key, value} ->
      if to_string(key) |> String.downcase() == name, do: to_string(value)
    end)
  end

  @doc false
  defp smokeable_paths do
    EltrixSiteWeb.Router
    |> apply(:__routes__, [])
    |> Enum.filter(&(&1.verb == :get))
    |> Enum.map(& &1.path)
    # A route with a segment nobody can fill in is not a page to fetch, and the
    # dev dashboard is not served in production.
    |> Enum.reject(&String.contains?(&1, ":"))
    |> Enum.reject(&String.starts_with?(&1, "/dev"))
    |> Enum.uniq()
    |> Enum.sort()
  end

  # `href` values that stay on this site. Anchors, mail and external hosts are
  # somebody else's to keep working.
  defp internal_links(html) do
    Regex.scan(~r/href="([^"]+)"/, html)
    |> Enum.map(fn [_whole, href] -> href end)
    |> Enum.filter(&String.starts_with?(&1, "/"))
    |> Enum.reject(&String.starts_with?(&1, "//"))
    |> Enum.map(&(&1 |> String.split("#") |> hd()))
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end
end
