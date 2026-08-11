defmodule EltrixSite.Status do
  @moduledoc """
  What the server can actually do, read from `status.json` — GOAL.md §5.3.

  The file is generated from `GOAL.md`'s own checkboxes by `mix eltrix.docs` in
  `eltrix_server` and vendored here. `[x]` becomes `done`, `[~]` becomes
  `partial`, `[ ]` becomes `none`. Nothing on this site restates a capability by
  hand; a page names a **key** and this module answers for it.

  That indirection is the whole point of §3.1: a claim lives in one place. The
  previous site said things the server had never done — an Admin API, a Helm
  chart, Redis caching, read-replica routing — and none of it was malicious.
  Somebody wrote a roadmap in the present tense and nothing anywhere could tell.

  ## Why this is read at compile time

  `claim!/1` raises during compilation, so a page that claims something the
  tests do not back **fails the build** rather than shipping. Read at runtime it
  would degrade to a wrong page rather than a red build, which is the failure
  this design exists to prevent.

  The file is an `@external_resource`, so editing it recompiles the pages that
  depend on it — otherwise a capability that regressed to `partial` would keep
  rendering as `done` from a stale beam until something unrelated forced a
  rebuild.
  """

  @path Path.expand("../../priv/artefacts/status.json", __DIR__)
  @external_resource @path
  @statuses @path |> File.read!() |> JSON.decode!()

  @typedoc "What is known about a capability. Anything else is a missing key."
  @type status :: :done | :partial | :none | :unknown

  @doc "Every key and its status, for the page that lists the lot."
  @spec all() :: %{String.t() => status()}
  def all, do: Map.new(@statuses, fn {key, value} -> {key, cast(value)} end)

  @doc "The status of one capability. An unknown key is `:unknown`, never `:none`."
  @spec status(String.t()) :: status()
  def status(key), do: @statuses |> Map.get(key) |> cast()

  @doc "Keys with a given status, sorted, so the page order is stable."
  @spec with_status(status()) :: [String.t()]
  def with_status(wanted) do
    all() |> Enum.filter(fn {_key, status} -> status == wanted end) |> Enum.map(&elem(&1, 0))
  end

  @doc """
  Asserts at **compile time** that `key` is `done`, and returns it.

  Called from a module attribute so the raise happens while compiling the page.
  A key that is `partial`, `none` or absent stops the build with the reason,
  which is the only way a site can promise not to overstate itself and be
  believed.
  """
  @spec claim!(String.t()) :: String.t()
  def claim!(key) do
    case status(key) do
      :done ->
        key

      :unknown ->
        raise """
        #{inspect(key)} is claimed by a page and is not a key in status.json.

        Either the key is misspelled, or GOAL.md has no `<!-- status: #{key} -->`
        marker on the criterion that would prove it. Add the marker there and
        regenerate; do not add the key here.
        """

      other ->
        raise """
        #{inspect(key)} is claimed by a page and status.json says #{other}.

        A claim on this site maps to a key whose value is `done` (§5.1). If the
        capability really is finished, the criterion in GOAL.md is what says so
        — tick it and regenerate the artefacts. Do not weaken this check.
        """
    end
  end

  defp cast("done"), do: :done
  defp cast("partial"), do: :partial
  defp cast("none"), do: :none
  defp cast(_absent), do: :unknown
end
