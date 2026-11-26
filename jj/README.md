# jj

A v3 mixin that adds [Jujutsu](https://github.com/jj-vcs/jj) from its official
static binary. At startup it copies your Git `user.name` and `user.email` into
the jj config.

```console
$ sbx run claude --kit ./jj ~/your-project
```

This kit adds the tool only. It does not block pushing; the
[`nix-jj`](../nix-jj) set does.

To bump jj, change `JJ_VERSION` and both checksums in `jj.dockerfile` and
`provides` in `jj.yaml`.
