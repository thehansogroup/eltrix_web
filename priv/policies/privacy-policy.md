# Privacy policy

> **Draft, not yet in force.** Written 2026-08-11 so that `www.eltrix.org` has
> something true to publish when it exists (§5). **It has not been reviewed by a
> lawyer.**
>
> The parts describing what the server stores are drawn from the schema and are
> checkable against it. The parts making commitments are proposals.

## What is stored

**Your account.** User ID, a password hash, display name and avatar if you set
them, and — if you bind one — an email address (§4.2.1, email only; no phone
numbers).

**Your devices.** One row per signed-in client: a device ID, a display name, an
access token, and the address and time it was last seen. That last-seen address
is what makes "somebody is signed in from somewhere I do not recognise"
answerable.

**Your messages.** Events in the rooms you are in, with their sender, timestamp
and content. **Where a room is end-to-end encrypted, the content is ciphertext
and the operator cannot read it.** Most private rooms here are encrypted by
default; the server decides that at creation rather than leaving it to a client
to remember.

**Your keys.** Public device keys, one-time keys, cross-signing signatures, and
— if you turn on key backup — your encrypted room keys. The backup is encrypted
with a key the server never has.

**Ephemeral things**, in memory and never in the database: who is typing, who is
online. They expire by themselves and do not survive a restart.

**Operational records.** Which administrator looked at which account
(`Eltrix.AdminAudit`), rate-limit counters, and abuse reports you file.

## What is not stored

- **No analytics, no tracking, no third-party scripts.** The web client makes no
  request to anything except the homeserver you point it at. There is no
  advertising identifier and nothing is shared with an analytics provider —
  this was proposed on 2026-08-11 and declined, because page paths in a Matrix
  client carry room identifiers.
- **No message content in logs.** Request bodies are never logged. Account data
  carries cross-signing private-key material and federation bodies carry
  ciphertext, so this is a rule in `CLAUDE.md` rather than a habit.
- **No IP address history.** One last-seen address per device, overwritten, not
  a log.
- **No read receipts sold, shared, or mined.** They exist because clients need
  them.

## Who else sees it

**Other people in your rooms**, which is what a room is.

**Other homeservers**, when you share a room with somebody on one. This is
federation and it is not reversible: an event sent to a room with a remote
member has been copied to that server, and this server cannot make them delete
it. `docs/erasure-policy.md` is explicit about what that means for erasure.

Federation here is **closed by default** and runs against a named allowlist
(**D3**), so the set of servers is small and deliberate rather than the whole
network.

**Nobody else.** No processor, no analytics provider, no advertising network.
Infrastructure — the server, the database, object storage for files — is
operated by the same person who operates the service, on hardware they control.

## Email

Only for verifying an address you bound and for password reset. Sent through
Postal, self-hosted, on infrastructure the operator runs — *not* through a
third-party sending service, because this domain's DMARC posture allows only
Stalwart and Postal to send as it.

Your address is never used for anything else and is never given to anybody.

## Your rights

**See it** — `GET /_eltrix/client/v1/account/export`, self-service, no ticket.
`docs/data-export.md` describes what it contains.

**Correct it** — display name, avatar and email are yours to change from any
client.

**Erase it** — deactivate from any client. What that does, and the limits
federation imposes, are in `docs/erasure-policy.md`, which is deliberate about
what cannot be promised rather than quiet about it.

**Object or complain** — the abuse and operator contacts on `www.eltrix.org`,
and the supervisory authority in the operator's jurisdiction.

## How long it is kept

**Nothing expires unless somebody asked it to.** There is no default lifetime;
`docs/retention-policy.md` explains why a server that quietly deletes after
ninety days has destroyed a conversation nobody asked it to touch.

A deactivated account keeps its row so the user ID can never be re-registered by
somebody else — every event it sent still names it as the sender.

## Security

Passwords are hashed with PBKDF2-SHA512. Access tokens are random and revocable
per device. TLS terminates at the edge; the server never speaks plaintext to the
internet. End-to-end encrypted rooms are encrypted on your device, and the
operator holds no key to them.

`docs/incident-process.md` describes what happens when something goes wrong,
including what is alerted and deliberately what is not.

## Changes

Published at the same URL with a date. Material changes are announced in a room
any account can join.
