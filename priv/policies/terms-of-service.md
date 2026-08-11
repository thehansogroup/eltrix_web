# Terms of service

> **Draft, not yet in force.** Written 2026-08-11 so that `www.eltrix.org` has
> something true to publish when it exists (§5), and so §4.7's requirement is a
> document somebody can read and correct rather than a blank waiting for the
> moment it is needed. **It has not been reviewed by a lawyer.** Nothing here
> takes effect until it is published at a URL with a date on it.
>
> Where it describes what the software does, it is accurate and checkable — that
> half comes from the code. Where it makes commitments, it is a proposal.

## Who runs this

Eltrix is operated by Julian Lindner. The full imprint, including a postal
address, is published on `www.eltrix.org`.

## What the service is

A Matrix homeserver. It carries messages between people using Matrix clients,
stores what is needed to deliver them, and exchanges traffic with other
homeservers where an operator has allowed it.

It is **not** a backup service, an archive, or a guarantee that anything sent
through it will still be there tomorrow. Where a room is end-to-end encrypted,
the operator cannot read it and cannot recover it for you.

## Accounts

Registration is by invitation. An account is for one person; an application
service's users belong to the service that created them.

You are responsible for what your account does. If you lose access to it, an
email address bound to it is the only self-service way back in — an operator can
reset a password, but that is a manual act, not a right.

## What you may not do

- Anything illegal where the operator is, or where you are.
- Harassment, threats, or content sexualising children.
- Using the server to attack other systems, including as a relay or a proxy.
- Automated use that degrades the service for others. Bridges and bots are
  welcome and are registered deliberately (§4.2.6); unregistered automation at
  scale is not.

Reporting is described in `docs/abuse-reporting.md`. Enforcement is an
operator's decision and may include removing content, closing an account, or
declining to federate with a server.

## What is not promised

**No uptime guarantee.** This is a small, self-hosted service. It will be down
sometimes, including for deliberate maintenance and including without notice.

**No support commitment.** Questions are answered when there is time.

**No response-time promise on abuse reports.** Reports are read; see
`docs/abuse-reporting.md` for why no number appears here.

## Your data

Covered separately in `docs/privacy-policy.md`. In short: what is stored is what
is needed to run a homeserver, you can export it
(`GET /_eltrix/client/v1/account/export`), and you can ask for it to be erased
(`docs/erasure-policy.md`) — with the limits federation imposes, which that
document is explicit about.

## Ending it

**You** may deactivate your account at any time from any client. What that does
and does not remove is in `docs/erasure-policy.md`.

**The operator** may close an account for a breach of these terms, and will say
why unless saying so would compromise somebody's safety.

**The service** may close entirely. If it does, the intention is at least thirty
days' notice at `www.eltrix.org` and time to export — an intention, stated
plainly as one, because a promise that survives the operator being unable to
keep it is not a promise.

## Changes

Changes are published at the same URL with a date. Material changes are
announced in a room on this server that any account can join. Continuing to use
the service after a change is acceptance of it.

## Law

The law of the operator's jurisdiction applies. This is one of the several
places a lawyer needs to replace a sentence written by an engineer.
