# eltrix_web — the site

Phoenix. Serves `www.eltrix.org`: what the homeserver can do, the policy
documents §4.7 requires, and the Matrix discovery documents on the apex.

## The one idea

**The build fails if a page claims what the project's own criteria do not
back.** `priv/artefacts/status.json` is generated from `GOAL.md`'s checkboxes
in `eltrix_server`; `EltrixSite.Capabilities` names keys and
`EltrixSite.Status.claim!/1` asserts each is `done` **while the module
compiles**. Read at runtime this would degrade to a wrong page instead of a red
build, which is the failure the design exists to prevent.

The previous site said things the server had never done — an Admin API, a Helm
chart, Redis caching, read-replica routing. None of it was malicious; somebody
wrote a roadmap in the present tense and nothing could tell.

The same page renders what is **partial and missing**, from the same file. A
site listing only finished features is not lying by sentence and is lying by
shape.

## Running it

    mix setup
    mix phx.server     # http://localhost:4012

Port 4012 deliberately: 4000 is reserved and 4011 is the homeserver's dev
listener.

## Gate

    mix ci

Format, unused deps, `--warnings-as-errors`, tests. `compile --force` is in
there on purpose — the claims are checked at compile time, so a warm incremental
build would skip the only check that matters.

## Artefacts

`priv/artefacts/*.json` and `priv/policies/*.md` are vendored from
`eltrix_server`. They are copies, and a copy can drift; the policies are
vendored rather than restated so that the version people are held to is the
version somebody edits.
