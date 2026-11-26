# nix

A v3 mixin that adds [Nix](https://nixos.org/) to a sandbox: single-user, with
`nix-command` and `flakes` enabled. nixpkgs is not pinned.

## Usage

```console
$ sbx run shell --kit ./nix ~/my-flake-project
```

Run from the root of this repository. Mixins are chosen when a sandbox is
created, so an existing sandbox cannot gain this one.

## Limits

- Installed packages live in the sandbox's own `/nix`. A new sandbox starts
  without them. There is no volume, because a fresh volume on `/nix` would hide
  the Nix this kit ships.
- Network access covers `cache.nixos.org`, nixos.org channels and GitHub. Other
  flake inputs or binary caches need to be allowed separately.
- No GitHub credential is declared, so `github:` inputs are subject to GitHub's
  unauthenticated API rate limit.

## Build

```console
$ docker buildx build nix -f nix/nix.yaml --output type=cacheonly   # validate
$ docker buildx build nix -f nix/nix.yaml -t nix-kit:dev --load     # build
$ docker run --rm nix-kit:dev                                       # prints the version
```

To bump Nix, change the image tag and `EXPECTED_NIX_VERSION` in `nix.dockerfile`
and `provides` in `nix.yaml`.

## Credit

Adapted from the `nix` kit in [alakae/sbx-kits](https://github.com/alakae/sbx-kits),
MIT licensed; see [LICENSE-MIT](LICENSE-MIT).
