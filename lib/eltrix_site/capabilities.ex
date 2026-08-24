defmodule EltrixSite.Capabilities do
  @moduledoc """
  What the landing page says, and the keys that entitle it to say so.

  Every key here used to pass through `EltrixSite.Status.claim!/1` inside a
  module attribute, so a capability downgraded in `eltrix_server`'s `GOAL.md`
  stopped this file compiling until somebody changed what the page said. That
  mechanism was removed on 2026-08-25 along with the file it read.

  **Nothing now checks that these claims are true.** Adding an entry here puts
  it on the landing page on the author's word alone, which is the state the
  previous site was in when it advertised an Admin API, a Helm chart, Redis
  caching and read-replica routing. See `thehansogroup/eltrix_web#8`.
  """

  @titles %{
    "accounts" => "Accounts and sessions",
    "admin_api" => "Administration",
    "appservices" => "Bridges and bots",
    "clustering" => "Horizontal scale",
    "e2ee" => "End-to-end encryption",
    "federation" => "Federation",
    "history_visibility" => "History visibility",
    "key_backup" => "Key backup",
    "media" => "Media",
    "media_speed" => "Media at speed",
    "messages" => "Messages",
    "moderation" => "Moderation tooling",
    "presence" => "Presence",
    "push" => "Push notifications",
    "rate_limiting" => "Rate limiting",
    "rooms" => "Rooms and state",
    "search" => "Server-side search",
    "sliding_sync" => "Sliding sync",
    "spaces" => "Spaces",
    "sso" => "Single sign-on",
    "sync" => "Sync",
    "threads" => "Threads",
    "threepid" => "Email verification",
    "voip" => "Voice and video"
  }

  @works [
    %{
      key: "accounts",
      body:
        "Registration, login, refreshable access tokens and a real user-interactive " <>
          "authentication handshake. Registration can be closed behind invitations."
    },
    %{
      key: "rooms",
      body:
        "Rooms, membership, power levels and state resolution, on room versions 10, 11 and 12."
    },
    %{
      key: "sync",
      body:
        "A four-stream sync token, typing indicators, read receipts, read markers, " <>
          "account data and filters."
    },
    %{
      key: "messages",
      body: "Sending, editing, reactions, redaction, permalinks, aliases and a room directory."
    },
    %{
      key: "e2ee",
      body:
        "Device keys, one-time and fallback keys, to-device messages, cross-signing and " <>
          "device-list change tracking."
    },
    %{
      key: "key_backup",
      body:
        "Server-side key backup with restore. The backup is encrypted with a key this " <>
          "server never holds."
    },
    %{
      key: "media",
      body: "Upload, download and thumbnails, stored in object storage rather than on a disk."
    },
    %{
      key: "history_visibility",
      body: "Enforced on every read path, by the same code the sync path uses."
    },
    %{
      key: "rate_limiting",
      body: "Per-node limits on the endpoints worth limiting."
    },
    %{
      key: "admin_api",
      body: "A console and an API, mirrored at the Synapse admin paths so existing tooling works."
    },
    %{
      key: "clustering",
      body:
        "More than one node, with one process per room and per outbound sender across the " <>
          "whole cluster rather than per machine."
    }
  ]

  # The six the landing page sells on, in the order it shows them. Same
  # `claim!/1` gate as everything else: a key that slips to partial stops the
  # build rather than leaving a feature card describing something that broke.
  @features [
    %{
      key: "e2ee",
      eyebrow: "Private by default",
      title: "End-to-end encryption",
      body:
        "Private rooms are encrypted when they are created, not when somebody remembers to. " <>
          "Device keys, one-time and fallback keys, cross-signing and device verification, " <>
          "and server-side key backup with restore — encrypted with a key this server never holds."
    },
    %{
      key: "clustering",
      eyebrow: "Built to grow",
      title: "Horizontal scale",
      body:
        "Run more than one node. A room is a single process across the whole cluster rather " <>
          "than one per machine, and so is every outbound sender — an event written on one " <>
          "node reaches a client waiting on another in well under a millisecond."
    },
    %{
      key: "rooms",
      eyebrow: "Current spec",
      title: "Room versions 10, 11 and 12",
      body:
        "The auth rules, state resolution and redaction algorithms each version requires, " <>
          "checked against real events from a production server rather than against ourselves."
    },
    %{
      key: "media",
      eyebrow: "No shared disk",
      title: "Media in object storage",
      body:
        "Uploads, downloads and thumbnails go to any S3-compatible bucket. Nothing lands on " <>
          "the pod filesystem, so a second node needs no shared volume and a restart loses nothing."
    },
    %{
      key: "admin_api",
      eyebrow: "Runnable",
      title: "Administration and moderation",
      body:
        "A console for the day-to-day and an API for everything else, mirrored at the Synapse " <>
          "admin paths so tooling you already run keeps working. Every look at a user's data is logged."
    },
    %{
      key: "sync",
      eyebrow: "Real-time",
      title: "Sync that stays awake",
      body:
        "A waiting client is a parked process, not a poll. Typing, receipts, read markers, " <>
          "account data and filters, on a sync token that tracks four streams independently."
    }
  ]

  @doc "The six capabilities the landing page sells on."
  @spec features() :: [
          %{key: String.t(), eyebrow: String.t(), title: String.t(), body: String.t()}
        ]
  def features, do: @features

  @doc "The capabilities the landing page claims."
  @spec works() :: [%{key: String.t(), title: String.t(), body: String.t()}]
  def works, do: Enum.map(@works, &Map.put(&1, :title, title(&1.key)))

  @doc "A human name for a key."
  @spec title(String.t()) :: String.t()
  def title(key), do: Map.get(@titles, key, key)
end
