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
    if_delegating(conn, fn -> %{"m.server" => host() <> ":443"} end)
  end

  @doc "Where a client should point itself when given only the domain."
  def client(conn, _params) do
    if_delegating(conn, fn -> %{"m.homeserver" => %{"base_url" => "https://" <> host()}} end)
  end

  # A delegation naming a homeserver that does not exist is worse than none.
  #
  # `www.eltrix.org` serves the site before `matrix.eltrix.org` exists, and a
  # `.well-known` document there would be a published pointer to a dead host.
  # Nothing consumes it — discovery resolves the `server_name`, which is the
  # apex — but publishing something untrue because nobody is currently reading
  # it is exactly the habit §3.1 exists to prevent.
  #
  # 404, not an empty document: by this project's own convention that means
  # "not implemented", which is what a client feature-detects on. An empty or
  # malformed JSON body would instead read as a broken delegation.
  defp if_delegating(conn, build) do
    if Application.get_env(:eltrix_site, :delegate_matrix, true) do
      json(conn, build.())
    else
      conn
      |> put_status(:not_found)
      |> json(%{"errcode" => "M_UNRECOGNIZED", "error" => "No delegation is published here."})
    end
  end

  defp host, do: Application.fetch_env!(:eltrix_site, :homeserver_host)
end
