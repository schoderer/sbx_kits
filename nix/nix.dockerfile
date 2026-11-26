# syntax=docker/dockerfile:1
# Nix as a self-contained overlay: a registered, agent-owned, single-user store.
# Adapted from the nix kit in https://github.com/alakae/sbx-kits (see LICENSE-MIT).
FROM nixos/nix:2.35.2 AS build

# `provides` in nix.yaml claims this version, so the build enforces it. Bump the
# image tag above, this value and `provides` together.
ARG EXPECTED_NIX_VERSION=2.35.2
RUN test "$(nix --version)" = "nix (Nix) ${EXPECTED_NIX_VERSION}" \
 || { echo "image has $(nix --version), expected ${EXPECTED_NIX_VERSION}" >&2; exit 1; }

RUN <<'SH'
set -eu
nix_bin=$(readlink -f "$(command -v nix)")
pkg=${nix_bin%/bin/nix}

# `nix copy` writes the store paths and registers them in the Nix database,
# which a plain cp of the closure would not.
nix --extra-experimental-features 'nix-command flakes' copy --no-check-sigs --to /out "$pkg"

mkdir -p /out/usr/local/bin /out/etc/nix /out/nix/var/nix/gcroots /out/nix/var/nix/profiles
for b in "$pkg"/bin/*; do ln -s "$b" /out/usr/local/bin/; done

# GC root, so nix-collect-garbage never deletes Nix itself.
ln -s "$pkg" /out/nix/var/nix/gcroots/sbx-nix

# Single-user: no nixbld group and no build sandbox (the sandbox VM is the boundary).
printf '%s\n' \
  'experimental-features = nix-command flakes' \
  'build-users-group =' \
  'sandbox = false' \
  > /out/etc/nix/nix.conf

# The agent (uid 1000) owns the store. -h re-owns links instead of their targets.
chown -R -h 1000:1000 /out/nix
SH

FROM scratch
COPY --from=build /out /
# Puts `nix profile` installs on PATH; composition appends this to the workload's.
ENV PATH=/home/agent/.nix-profile/bin:$PATH
ENTRYPOINT ["/usr/local/bin/nix"]
CMD ["--version"]
