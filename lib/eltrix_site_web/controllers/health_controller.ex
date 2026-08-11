defmodule EltrixSiteWeb.HealthController do
  @moduledoc """
  `GET /health`, unauthenticated, for the Kubernetes probes.

  A site with no database has little to check, and saying so is better than
  inventing a check that always passes. What this does assert is that the
  status artefact is loaded and non-empty — which is the one thing that could
  be wrong while the process still answers, and the thing every page depends on.
  """
  use EltrixSiteWeb, :controller

  alias EltrixSite.Status

  def show(conn, _params) do
    keys = map_size(Status.all())

    payload = %{
      status: if(keys > 0, do: "healthy", else: "unhealthy"),
      version: Application.spec(:eltrix_site, :vsn) |> to_string(),
      checks: %{status_artefact: if(keys > 0, do: "ok", else: "empty")},
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    conn
    |> put_status(if(keys > 0, do: 200, else: 503))
    |> json(payload)
  end
end
