defmodule EltrixSite.Policies do
  @moduledoc """
  The terms, the privacy policy and the abuse-reporting document — GOAL.md §4.7.

  Written in `eltrix_server/docs/` and vendored here as Markdown. Rendered at
  **compile time**: the HTML is baked into the beam, so serving a policy makes
  no filesystem read and cannot half-render if the file goes missing under a
  running pod.

  Vendored rather than restated. §4.7 requires these to be *live*, and a policy
  that exists twice is one that will disagree with itself — the version people
  are held to has to be the version somebody edits.

  Each document carries its own "Draft, not yet in force" banner in its first
  lines, and that banner is deliberately not stripped in rendering. When they
  come into force, that is an edit to the source document, not a flag here.
  """

  @dir Path.expand("../../priv/policies", __DIR__)

  @documents [
    %{
      slug: "terms",
      file: "terms-of-service.md",
      title: "Terms of service",
      summary: "What this service is, what it does not promise, and what you may not do with it."
    },
    %{
      slug: "privacy",
      file: "privacy-policy.md",
      title: "Privacy policy",
      summary: "What the server stores, who else can see it, and how long it is kept."
    },
    %{
      slug: "abuse",
      file: "abuse-reporting.md",
      title: "Reporting abuse",
      summary: "The three ways to report something, where a report goes, and what happens next."
    }
  ]

  for %{file: file} <- @documents do
    @external_resource Path.join(@dir, file)
  end

  @rendered Map.new(@documents, fn %{slug: slug, file: file} ->
              html =
                @dir
                |> Path.join(file)
                |> File.read!()
                |> Earmark.as_html!(%Earmark.Options{compact_output: false})

              {slug, html}
            end)

  @doc "Every policy document, in the order the footer lists them."
  @spec all() :: [%{slug: String.t(), title: String.t(), summary: String.t()}]
  def all, do: Enum.map(@documents, &Map.take(&1, [:slug, :title, :summary]))

  @doc "One document's metadata, or `nil` for a slug nobody publishes."
  @spec get(String.t()) :: %{slug: String.t(), title: String.t(), summary: String.t()} | nil
  def get(slug), do: Enum.find(all(), &(&1.slug == slug))

  @doc "The rendered HTML for a slug. Raises for an unknown one, which is a routing bug."
  @spec html!(String.t()) :: String.t()
  def html!(slug), do: Map.fetch!(@rendered, slug)
end
