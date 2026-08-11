# Eltrix site image.
#
# linux/amd64 only — the fondue nodes are x86. Never build for arm64.
#
# Simpler than the homeserver's in two ways. There is no Tailwind, so esbuild
# alone is the asset pipeline; and there is no database, so no migration entry
# point and nothing to wait for at boot.

ARG ELIXIR_VERSION=1.19.5
ARG OTP_VERSION=28
ARG DEBIAN_VERSION=trixie-20260202-slim

ARG BUILDER_IMAGE="docker.io/library/elixir:${ELIXIR_VERSION}-otp-${OTP_VERSION}-slim"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

# ---------------------------------------------------------------------------
# builder — dependencies only, so this layer caches across source changes
# ---------------------------------------------------------------------------
FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends build-essential ca-certificates git && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

# Before deps.compile, so the @version block in mix.exs resolves it. There is
# no .git in the build context, so the `git describe` fallback cannot work.
ARG APP_VERSION=0.0.0-dev
ENV APP_VERSION=${APP_VERSION}

COPY mix.exs mix.lock ./
RUN mix deps.get --only ${MIX_ENV}

RUN mkdir config
COPY config/config.exs config/prod.exs config/
RUN mix deps.compile

# ---------------------------------------------------------------------------
# release
# ---------------------------------------------------------------------------
FROM builder AS release

COPY priv priv
COPY lib lib
COPY assets assets

# `mix compile` before assets, as in the homeserver: Phoenix 1.8 emits
# colocated hooks during Elixir compilation.
#
# It is also where this image earns its keep. EltrixSite.Capabilities checks
# every landing-page claim against priv/artefacts/status.json at compile time,
# so an image cannot be built for a site that overstates the server.
RUN mix compile
RUN mix assets.setup
RUN mix assets.deploy

COPY config/runtime.exs config/

# rel/, and it is load-bearing. The overlay in rel/overlays/bin/server is the
# image's entry point; without this COPY `mix release` succeeds, the image
# builds and pushes clean, and the container dies at exec with
# "/app/bin/server: no such file or directory" — a runtime failure for a file
# that was never in the build context, reported by containerd rather than by
# anything that looked at the release.
COPY rel rel

RUN mix release

# ---------------------------------------------------------------------------
# runtime — minimal Debian, non-root
# ---------------------------------------------------------------------------
FROM ${RUNNER_IMAGE} AS runtime

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
    ca-certificates libncurses6 libstdc++6 locales openssl && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV MIX_ENV=prod

WORKDIR /app

RUN groupadd --gid 1000 eltrix && \
  useradd --uid 1000 --gid 1000 --home-dir /app --no-create-home \
    --shell /usr/sbin/nologin eltrix && \
  chown eltrix:eltrix /app

COPY --from=release --chown=1000:1000 /app/_build/prod/rel/eltrix_site ./

USER 1000:1000

EXPOSE 4000

CMD ["/app/bin/server"]
