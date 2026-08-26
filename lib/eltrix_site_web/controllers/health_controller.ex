defmodule EltrixSiteWeb.HealthController do
  @moduledoc """
  `GET /health`, unauthenticated, for the Kubernetes probes.

  A site with no database has little to check, and saying so is better than
  inventing a check that always passes. This used to assert that the status
  artefact was loaded and non-empty — the one thing that could be wrong while
  the process still answered — and that artefact was removed on 2026-08-25.

  So this reports that the process is up and which version it is, and claims
  nothing else. If a check is added later it must be able to fail.
  """
  use EltrixSiteWeb, :controller

  def show(conn, _params) do
    payload = %{
      status: "healthy",
      version: Application.spec(:eltrix_site, :vsn) |> to_string(),
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    json(conn, payload)
  end
end
