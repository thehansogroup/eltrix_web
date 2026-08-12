defmodule EltrixSite.Capabilities do
  @moduledoc """
  What the landing page says, and the keys that entitle it to say so.

  Every entry in `works/0` passes its key through `EltrixSite.Status.claim!/1`
  inside a module attribute, so the assertion runs while this module compiles.
  Downgrade a capability in `GOAL.md`, regenerate the artefacts, and this file
  stops compiling until somebody changes what the page says.

  `absent/0` is the other half and matters more. A site that lists only what
  works is not lying by sentence but is lying by shape, and §3.1 asks for the
  whole picture — so the same page renders what is partial and what is missing,
  from the same file, with no way to render one list and quietly drop the other.
  """

  alias EltrixSite.Status

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
      key: Status.claim!("accounts"),
      body:
        "Registration, login, refreshable access tokens and a real user-interactive " <>
          "authentication handshake. Registration can be closed behind invitations."
    },
    %{
      key: Status.claim!("rooms"),
      body:
        "Rooms, membership, power levels and state resolution, on room versions 10, 11 and 12."
    },
    %{
      key: Status.claim!("sync"),
      body:
        "A four-stream sync token, typing indicators, read receipts, read markers, " <>
          "account data and filters."
    },
    %{
      key: Status.claim!("messages"),
      body: "Sending, editing, reactions, redaction, permalinks, aliases and a room directory."
    },
    %{
      key: Status.claim!("e2ee"),
      body:
        "Device keys, one-time and fallback keys, to-device messages, cross-signing and " <>
          "device-list change tracking."
    },
    %{
      key: Status.claim!("key_backup"),
      body:
        "Server-side key backup with restore. The backup is encrypted with a key this " <>
          "server never holds."
    },
    %{
      key: Status.claim!("media"),
      body: "Upload, download and thumbnails, stored in object storage rather than on a disk."
    },
    %{
      key: Status.claim!("history_visibility"),
      body: "Enforced on every read path, by the same code the sync path uses."
    },
    %{
      key: Status.claim!("rate_limiting"),
      body: "Per-node limits on the endpoints worth limiting."
    },
    %{
      key: Status.claim!("admin_api"),
      body: "A console and an API, mirrored at the Synapse admin paths so existing tooling works."
    },
    %{
      key: Status.claim!("clustering"),
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
      key: Status.claim!("e2ee"),
      eyebrow: "Private by default",
      title: "End-to-end encryption",
      body:
        "Private rooms are encrypted when they are created, not when somebody remembers to. " <>
          "Device keys, one-time and fallback keys, cross-signing and device verification, " <>
          "and server-side key backup with restore — encrypted with a key this server never holds."
    },
    %{
      key: Status.claim!("clustering"),
      eyebrow: "Built to grow",
      title: "Horizontal scale",
      body:
        "Run more than one node. A room is a single process across the whole cluster rather " <>
          "than one per machine, and so is every outbound sender — an event written on one " <>
          "node reaches a client waiting on another in well under a millisecond."
    },
    %{
      key: Status.claim!("rooms"),
      eyebrow: "Current spec",
      title: "Room versions 10, 11 and 12",
      body:
        "The auth rules, state resolution and redaction algorithms each version requires, " <>
          "checked against real events from a production server rather than against ourselves."
    },
    %{
      key: Status.claim!("media"),
      eyebrow: "No shared disk",
      title: "Media in object storage",
      body:
        "Uploads, downloads and thumbnails go to any S3-compatible bucket. Nothing lands on " <>
          "the pod filesystem, so a second node needs no shared volume and a restart loses nothing."
    },
    %{
      key: Status.claim!("admin_api"),
      eyebrow: "Runnable",
      title: "Administration and moderation",
      body:
        "A console for the day-to-day and an API for everything else, mirrored at the Synapse " <>
          "admin paths so tooling you already run keeps working. Every look at a user's data is logged."
    },
    %{
      key: Status.claim!("sync"),
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

  @doc "The capabilities the landing page claims. Each is `done` or this did not compile."
  @spec works() :: [%{key: String.t(), title: String.t(), body: String.t()}]
  def works, do: Enum.map(@works, &Map.put(&1, :title, title(&1.key)))

  @doc "Everything not finished, by status, so the page cannot show only good news."
  @spec absent() :: [%{key: String.t(), title: String.t(), status: Status.status()}]
  def absent do
    claimed = MapSet.new(@works, & &1.key)

    Status.all()
    |> Enum.reject(fn {key, status} -> status == :done or MapSet.member?(claimed, key) end)
    |> Enum.map(fn {key, status} -> %{key: key, title: title(key), status: status} end)
    |> Enum.sort_by(&{&1.status == :none, &1.title})
  end

  @doc "A human name for a key. Naming, not claiming — the status still comes from the file."
  @spec title(String.t()) :: String.t()
  def title(key), do: Map.get(@titles, key, key)
end
