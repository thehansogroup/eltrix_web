defmodule EltrixSite.StatusTest do
  @moduledoc """
  The check that lets this site be believed.

  `claim!/1` runs at compile time, so these tests drive it directly. What is
  worth pinning is that it refuses the two cases that would let a page
  overstate the server: a capability that is only partly built, and a key
  nobody generates — the second being how a typo would otherwise become a
  silent claim.
  """
  use ExUnit.Case, async: true

  alias EltrixSite.Status

  test "a finished capability may be claimed" do
    assert Status.claim!("e2ee") == "e2ee"
  end

  test "a partial capability may not" do
    # Federation works, against one peer, with the Complement suite at 29.2%.
    # That is exactly the kind of thing a site says "we federate" about.
    assert Status.status("federation") == :partial

    assert_raise RuntimeError, ~r/status\.json says partial/, fn ->
      Status.claim!("federation")
    end
  end

  test "a key nobody generates may not be claimed at all" do
    assert_raise RuntimeError, ~r/is not a key in status\.json/, fn ->
      Status.claim!("quantum_resistant_telepathy")
    end
  end

  test "an unknown key is :unknown rather than :none" do
    # The distinction matters: :none is a generated fact about a capability that
    # is tracked and absent; :unknown means nothing is tracking it, which is a
    # different problem and must not read as a truthful "not built yet".
    assert Status.status("nothing_tracks_this") == :unknown
    assert Status.status("voip") == :none
  end

  test "statuses are only ever the four we handle" do
    for {key, status} <- Status.all() do
      assert status in [:done, :partial, :none], "#{key} has an unexpected status"
    end
  end
end
