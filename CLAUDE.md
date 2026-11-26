# CLAUDE.md

Docker Sandboxes (`sbx`) kits, manifest **v3**. One directory per kit:
`<name>/<name>.yaml`, `<name>/<name>.dockerfile`, `<name>/README.md`.

## Preferences

- Use `jj`, not `git`, for version control.
- Keep kits minimal and mixins usable on any workload. Add no pins, volumes or
  extras that were not asked for.

## Docs

v3 is newer than model training data and still experimental, so check the source
before relying on memory. v2 (`spec.yaml`) docs and examples do not apply.

- Spec, capability pages, examples: https://github.com/docker/sandbox-kit-spec
- Usage: https://docs.docker.com/ai/sandboxes/customize/

## Gotchas

- Use `agent-context@1`, not `@2`: the two cannot be composed, and `@1` is
  confirmed working with the `shell` and `claude` workloads.
- Descriptor decoding is strict; unknown fields fail the build.
- A mixin's `ENTRYPOINT`, `CMD`, `USER` and `WORKDIR` are ignored when composed.
  `ENV` merges, with `PATH` entries appended.
- A new volume starts empty and hides whatever the image has at that path.
- The `agent` user is uid 1000. Do not ship `/home` content owned by anyone else.
- Publishing needs a `docker-container` Buildx builder; the `docker` driver with
  the classic image store can drop the descriptor annotation.

## Testing

`sbx` is not available inside the agent sandbox. Validate and test here, then ask
the user to run `sbx run <workload> --kit ./<name> <project>` on the host.

```console
$ docker buildx build <name> -f <name>/<name>.yaml -t <name>-kit:dev --load
```

To exercise a mixin, build a throwaway image (outside the repo):

- Base on Debian with `git`, `curl`, CA certificates and a uid 1000 `agent` user.
- Overlay with `COPY --from=<name>-kit:dev / /`. Copying single directories loses
  their ownership.
- Copy in this sandbox's `/etc/ssl/certs/ca-certificates.crt`, and pass
  `--network host` plus the proxy variables to both build and run.

This does not enforce the kit's network policy; only the host test does. A 403
here is this sandbox's firewall: ask the user to approve the request.
