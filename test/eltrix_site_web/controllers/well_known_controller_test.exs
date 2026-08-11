defmodule EltrixSiteWeb.WellKnownControllerTest do
  @moduledoc """
  Federation discovery on the apex — §5.1.

  These two must be *served*, not redirected. The apex is the `server_name` in
  every user ID and event signature while the listener answers elsewhere, so
  this is the only thing telling a peer where to go.
  """
  use EltrixSiteWeb.ConnCase, async: true

  test "the server document names the homeserver and a port", %{conn: conn} do
    assert %{"m.server" => server} =
             conn |> get("/.well-known/matrix/server") |> json_response(200)

    assert server =~ ~r/^[a-z0-9.-]+:\d+$/
  end

  test "the client document is an absolute https base URL", %{conn: conn} do
    assert %{"m.homeserver" => %{"base_url" => url}} =
             conn |> get("/.well-known/matrix/client") |> json_response(200)

    assert String.starts_with?(url, "https://")
  end

  test "neither is a redirect", %{conn: conn} do
    # A blanket apex-to-www rule would answer discovery with a 301, which a peer
    # is not obliged to follow — federation then fails with nothing logged here.
    for path <- ["/.well-known/matrix/server", "/.well-known/matrix/client"] do
      assert conn |> get(path) |> Map.fetch!(:status) == 200
    end
  end
end
