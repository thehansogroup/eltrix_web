# eltrix_web — the site

Phoenix. Serves `www.eltrix.org`: what the homeserver can do, the policy
documents a real service needs, and the Matrix discovery documents on the apex.

Anything with a state — what is built, what is left, what is blocked — lives in
Forgejo issues and milestones, not here. `README.md` is the human landing page.

## The build fails if a page claims what the criteria do not back

This is the one idea in the repository and everything else follows from it.

`priv/artefacts/status.json` is generated from `GOAL.md`'s checkboxes in
`eltrix_server`. `EltrixSite.Capabilities` names **keys**, never capabilities,
and `EltrixSite.Status.claim!/1` asserts each is `done` **while the module
compiles**. Downgrade something in `GOAL.md`, regenerate, and this site stops
compiling until somebody changes what the page says.

**Compile time, not runtime.** Read at runtime it would degrade to a wrong page
instead of a red build, which is the failure the design exists to prevent. That
is also why `status.json` is an `@external_resource`: without it, a capability
that regressed to `partial` would keep rendering as `done` out of a stale beam
until something unrelated forced a rebuild.

**And why `mix ci` runs `compile --force`.** The claims are checked while
compiling, so a warm incremental build skips the only check this site exists to
make. Removing `--force` to speed CI up removes the gate.

The previous site said things the server had never done — an Admin API, a Helm
chart, Redis caching, read-replica routing. None of it was malicious; somebody
wrote a roadmap in the present tense and nothing anywhere could tell.

## The same page renders what is partial and what is missing

`absent/0` is the other half of `Capabilities` and it matters more than
`works/0`. **A site that lists only finished features is not lying by sentence
and is lying by shape.** Both lists come from the same file, and there is
deliberately no way to render one and quietly drop the other. Do not add one.

## The artefacts and policies are vendored copies, and a copy can drift

`priv/artefacts/*.json` and `priv/policies/*.md` come from `eltrix_server`. They
are copies because the site is a separate repository and a separate deploy, so
it has to read them without building the homeserver.

The policies are **vendored rather than restated** so that the version people
are held to is the version somebody edits. Never paraphrase a policy into a
template here; copy the file.

## Assets are built before tests, and not only for the asset test

`priv/static/assets` is gitignored, so without the `assets.setup` and
`assets.build` steps CI never runs the asset pipeline at all. That is how a site
once shipped with no stylesheet and a green build.

## Never log request bodies

The published privacy policy this site serves says request bodies are never
logged, and says it **is a rule in `AGENTS.md` rather than a habit** — so this
paragraph is what makes that sentence true here rather than only in
`eltrix_server`.

It applies independently: this site takes form submissions. It is not inherited
from the homeserver's version of the rule, and it is not weakened by the fact
that this repository holds no message content.

## The policy documents gate the first real account

Eltrix is a real service, not a demo: terms, a privacy policy and an abuse
contact must be **live before the first non-operator account exists**. That puts
part of this repository ahead of the server work rather than parallel to it.
