defmodule EltrixSiteWeb.WellKnownController do
  @moduledoc """
  Matrix discovery on the apex — GOAL.md §5.1.

  `ELTRIX_DOMAIN` is `eltrix.org` and the homeserver answers at
  `matrix.eltrix.org`. That split is permanent: an event signed under one
  `server_name` can never be re-signed under another. These two documents are
  the only thing that tells a peer or a client where to go, which is why §5.1
  says they are *served*, not redirected — a blanket apex-to-www rule would
  answer federation discovery with a 301 no peer is obliged to follow.
  """
  use EltrixSiteWeb, :controller

  @doc "Where other homeservers should talk to us. Port 443, via the edge."
  def server(conn, _params) do
    json(conn, %{"m.server" => host() <> ":443"})
  end

  @doc "Where a client should point itself when given only the domain."
  def client(conn, _params) do
    json(conn, %{
      "m.homeserver" => %{"base_url" => "https://" <> host()}
    })
  end

  defp host, do: Application.fetch_env!(:eltrix_site, :homeserver_host)
end
