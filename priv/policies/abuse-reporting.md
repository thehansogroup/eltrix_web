# Abuse reporting

How somebody reports content on this server, where the report goes, and who
looks at it. GOAL.md §4.7 requires the reporting path to be *"published,
reachable, and monitored"* and `/report` *"routed somewhere a human reads"* —
this is the document those two halves point at.

## The three ways in

**From a client.** Every Matrix client has a report button. It calls
`POST /_matrix/client/v3/rooms/{roomId}/report/{eventId}` for one message, or
`POST /_matrix/client/v3/rooms/{roomId}/report` for a whole room. Nothing has to
be installed and nobody has to know an address.

**By email.** `abuse@eltrix.org`, for anybody who is not on this server — the
person being harassed frequently has no account here, which is exactly why an
in-client button cannot be the only route.

**By post to the operator.** The imprint on `www.eltrix.org` carries a postal
address, because some jurisdictions require one and because a legal notice
should not depend on a web form.

> **Not yet live:** the address and the imprint need `www.eltrix.org`, which
> does not exist (§5). Until it does, the client path is the only published one
> and this document overstates the position. It is written now so that the site,
> when built, has something true to render rather than being the moment somebody
> invents a policy.

## Where a report goes

Into the `reports` table, and from there to `/admin/reports` in the
administration console. Unreviewed first; "reviewed" is a state an operator
sets deliberately.

That path existed only halfway until 2026-08-11: reports were *stored* from the
day the endpoint was built, and nothing displayed them. A report written to a
table nobody opens is worse than no report button, because somebody trusted the
server with a complaint, the endpoint answered `200`, and it went nowhere.

## What the console does not show

**The reported content.** Two reasons, and neither is squeamishness:

- The event may be in an encrypted room, where there is nothing for the server
  to render. Showing "cannot decrypt" would be honest and useless.
- In a plaintext room, rendering it would put whatever somebody reported — by
  definition the worst thing on the server — into an operator's browser at page
  load, with no warning and no choice.

The room and event are addressable. An operator opens them deliberately.

The reason field *is* shown, and is escaped: it is free text from a stranger,
and an operator's browser is the last place a reported string should run.

## What happens next

There is no automated action. A report does not hide a message, suspend an
account, or notify the reported party. Every consequence is an operator's,
taken through the console or the admin API:

| Action | Where |
|---|---|
| Read the room's state and members | `/admin/rooms/{roomId}` |
| Deactivate an account | `/admin/users/{userId}` |
| Delete a room and its events | `/admin/rooms/{roomId}` |
| Redact a single event | the operator's own client, with power in the room |

Deactivation deliberately does **not** redact what the account sent — see
`docs/erasure-policy.md`. An operator closing an abusive account is not the same
as that person asking to be forgotten, and conflating them destroys the evidence
of why the account was closed.

Every one of those actions is recorded by `Eltrix.AdminAudit`, so "who looked at
what" is answerable after the fact.

## Response times

**None are promised here.** This server is operated by one person. A promise of
"24 hours" that is kept when convenient is worth less than no promise, and §3.1
forbids claims that are not backed by something.

What is committed to: reports are read, and the console shows what is
outstanding rather than letting a backlog become invisible.

## Federation

A report about a user on another server can be *filed* here and cannot be
*acted on* here beyond removing them from rooms this server hosts. Their account
belongs to their homeserver. Where the peer is one this server federates with
deliberately — the allowlist is closed by default (**D3**) — the operator
contacts that server's operator directly.

## What this server does not do

- **No automated scanning of message content.** Nothing reads messages looking
  for anything. Most rooms here are encrypted and the server could not read them
  if it wanted to; in the ones it can, it does not.
- **No malware scanning on upload yet.** `docs/media-scanning.md` records what
  exists and what does not, and it does not currently include a scanner.
- **No proactive moderation.** Nobody reviews content that has not been
  reported.
