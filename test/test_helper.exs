# `:smoke` talks to a *deployed* site over the internet, so it can never be part
# of the default run — see `mix smoke`, and GOAL.md §3.5 for why the layer
# exists at all.
ExUnit.start(exclude: [:smoke])
