> **Note:** this repository is AI-generated. Use it at your own risk.

# sbx_kits
Docker Sandboxes (`sbx`) v3 kits.

- [nix](nix/): mixin adding Nix with flakes enabled
- [jj](jj/): mixin adding Jujutsu
- [nix-jj](nix-jj/): both in one reference, published to GHCR, with pushing denied

## Usage

Allow this GHCR namespace as a kit source, once, on your host. The command
replaces the whole list, so include any other sources you already allow:

```console
$ sbx settings set kit.allowedSources '["docker.io/","ghcr.io/schoderer/"]'
```

Start a sandbox with Nix and jj from the published kit:

```console
$ sbx run claude --kit ghcr.io/schoderer/sbx-kit-nix-jj:latest ~/your-project
```

Use `shell` instead of `claude` for a plain shell. Kits are chosen when a sandbox
is created, so an existing sandbox cannot gain one.

A single mixin can be run from a checkout of this repository:

```console
$ sbx run claude --kit ./nix ~/your-project
$ sbx run claude --kit ./jj ~/your-project
$ sbx run claude --kit ./nix --kit ./jj ~/your-project
```

Only the published `nix-jj` set denies pushing; local mixins do not. See
[nix-jj](nix-jj/) for what the deny rules cover.
