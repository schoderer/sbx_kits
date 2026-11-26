# nix-jj

A kit set merging [`nix`](../nix) and [`jj`](../jj), published to GHCR by
GitHub Actions for x86_64 and arm64.

## Usage

Allow the source once on your host. This replaces the whole list:

```console
$ sbx settings set kit.allowedSources '["docker.io/","ghcr.io/schoderer/"]'
$ sbx run claude --kit ghcr.io/schoderer/sbx-kit-nix-jj:latest ~/your-project
```

## What is denied

- `git push` / `jj git push` over HTTPS to `github.com`.
- `POST`, `PUT`, `PATCH` and `DELETE` on `api.github.com`. This also stops the
  agent opening issues or pull requests, and blocks GraphQL queries.

These rules do not cover SSH or other Git hosts. Do not forward your SSH agent
or give the sandbox a GitHub token if the agent must not push.

## Building

A set is built from published kits only, so it cannot be built from the local
directories. For local work use `--kit ./nix --kit ./jj`, which has none of the
deny rules above.
