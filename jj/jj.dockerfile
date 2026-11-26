# syntax=docker/dockerfile:1
# jj from its official static release binary, as a single-file overlay. It does
# not use /nix, so it cannot clash with the nix kit's store.
FROM --platform=$BUILDPLATFORM debian:trixie-slim AS build
ARG TARGETARCH
# `provides` in jj.yaml claims this version. Bump it, both checksums and
# `provides` together.
ARG JJ_VERSION=0.47.1
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl
RUN <<'SH'
set -eu
case "$TARGETARCH" in
  amd64) arch=x86_64; sum=d4b657f622ee50929c8916466dfa3d6a6c17a0a32b50e7b2c793707ec9ebcad7 ;;
  arm64) arch=aarch64; sum=0f300e1576de8dabe0a9dedf0b87ae44f8accea5cf54d9a342a51061c1fb1bcd ;;
  *) echo "unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;;
esac
curl -fsSL -o /tmp/jj.tar.gz \
  "https://github.com/jj-vcs/jj/releases/download/v${JJ_VERSION}/jj-v${JJ_VERSION}-${arch}-unknown-linux-musl.tar.gz"
echo "$sum  /tmp/jj.tar.gz" | sha256sum -c -
mkdir -p /tmp/jj /out/usr/local/bin
tar -xzf /tmp/jj.tar.gz -C /tmp/jj
install -m 0755 /tmp/jj/jj /out/usr/local/bin/jj
SH

FROM scratch
COPY --from=build /out /
ENTRYPOINT ["/usr/local/bin/jj"]
CMD ["--version"]
