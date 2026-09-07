# eltrix_web — the site

Phoenix. Serves `www.eltrix.org`: what the homeserver can do, the policy
documents a real service needs, and the Matrix discovery documents on the apex.

Anything with a state — what is built, what is left, what is blocked — lives in
Forgejo issues and milestones, not here. `README.md` is the human landing page.

## Nothing checks that the landing page tells the truth

`EltrixSite.Capabilities` holds the capability cards. Every key used to pass
through `EltrixSite.Status.claim!/1` in a module attribute, so a capability
downgraded in `eltrix_server`'s `GOAL.md` stopped this site compiling until
somebody changed what the page said, and `mix ci` ran `compile --force` so a
warm build could not skip the check.

**All of that was removed on 2026-08-25**, along with `GOAL.md`, the
`status.json` artefact and the `/status` page. Adding a card now puts a claim on
the landing page on the author's word alone.

That is the state the previous site was in when it advertised an Admin API, a
Helm chart, Redis caching and read-replica routing — **none of it malicious**;
somebody wrote a roadmap in the present tense and nothing anywhere could tell.
Issue #8 records what was guaranteed and what a replacement would have to read
from, which is Forgejo rather than a file.

Until then this is discipline, not a check. Write a card only for something you
have watched work.

## The artefacts and policies are vendored copies, and a copy can drift

`priv/artefacts/*.json` and `priv/policies/*.md` come from `eltrix_server`. They
are copies because the site is a separate repository and a separate deploy, so
it has to read them without building the homeserver.

The policies are **vendored rather than restated** so that the version people
are held to is the version somebody edits. Never paraphrase a policy into a
template here; copy the file.

## `main` is branch-protected, and only the Quality gate gates it

Armed 2026-08-27 (`jlxq0/mantis#141`). Direct push to `main` is refused;
a merge waits on one required status context; approvals required **0**, so you
still merge your own work once it is green.

Required: `CI / Quality gate*` — a glob, because the job posts `CI / Quality
gate (push)` on a branch push and `CI / Quality gate (pull_request)` on a PR
head, and a literal matches one only.

Measured on this repository's own commits, not read off the job list:

| context | job | why excluded |
|---|---|---|
| `CI / Quality gate` | `check`, no `needs:` | **required** — the only job on every push *and* every PR |
| `CI / Build and push image` | `docker`, `needs: check`, main/tag-only | never posts on a PR head, so requiring it blocks every PR; a skipped `needs:` job can post `success`, a gate green because nothing ran |
| `Deploy Jekyll site to Pages / build`, `/ deploy` | Pages workflow, push-only | not a correctness gate, and it has only ever posted on `(push)` — it would never appear on a PR head |

## A green build depends on a warm cache, so a green is not a green about the code

CI restores a branch-scoped `actions/cache` before `mix deps.get`, and the
Quality gate passes only because that cache carries a pre-built `lazy_html`.
`lazy_html` (an `only: :test` NIF) cannot be built cold in `ci-elixir`: its
precompiled binary 404s and the source fallback dies `make Error 127` for want
of a C toolchain. Any cold path hits it: a new branch, a cache eviction, a
cache-key change, or a tag, whose cache is cold because caches are branch-scoped
and a tag inherits none. `oddie-apps/infrastructure#98` is the fix and it is
clark's; two other repositories carry the same dependency and have not hit it
yet.

That cold cache cost `v0.1.0` its first build, and two consequences are now in
the workflow. The `check` job is skipped on tag refs (`refs/tags/v*`), because
the commit was already gated on `main`, so re-running the gate is redundant and
a tag is the one ref where the cold cache makes it fail. And because a skipped
job reports `success`, the `docker` job refuses a tag whose commit is not on
main (`compare main...<sha>`, `total_commits == 0`, failing closed) rather than
trusting that green.

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
