# Contributing

You can report a bug or ask for a campus rule that jilid does not support yet
in an issue. For a pull request, use a separate branch and run `just check`
first.

The Nix flake gives you Typst, typstyle, tinymist, tytanic, just, git-cliff and
the GitHub CLI. Run `nix develop`, or use direnv with the included `.envrc`.

```sh
just watch          # preview template/main.typ live with this checkout
just check          # format, lint, README options and tests
just fmt            # format all .typ files
just new-test name  # create tests/name/test.typ
just update         # accept new reference images
just thumbnail      # regenerate thumbnail.png from the template
just example        # regenerate docs/example.pdf
```

A plain `typst compile template/main.typ` uses the published version of jilid.
Use `just watch` to see your changes.

## Releasing (maintainer)

Typst Universe takes updates only from the author of the first release, so only
the maintainer releases jilid. A release goes to Typst Universe as a pull
request to [typst/packages](https://github.com/typst/packages), from a sparse
checkout next to this repository:

```sh
git clone --depth 1 --no-checkout --filter="tree:0" https://github.com/<you>/packages ../typst-packages
git -C ../typst-packages sparse-checkout set packages/preview/jilid
git -C ../typst-packages remote add upstream https://github.com/typst/packages
git -C ../typst-packages checkout main
```

Release from `main`:

```sh
just bump 0.3.0        # set the version in typst.toml and every import and link
just changelog         # print a draft of the changes since the last tag
# Write the "## [0.3.0] - date" section in CHANGELOG.md from the draft.
git commit -am "chore(release): 0.3.0"
just release --dry-run # run the checks and show the release notes
just release           # tag v0.3.0, push main and the tag, create the GitHub Release
just package           # copy the package to ../typst-packages and commit jilid:0.3.0
```

`just release` stops if CHANGELOG.md has no section for the version, so the tag
always includes the changelog. `just package` prints the push and
`gh pr create` commands. After the pull request is open, `just package` adds
follow-up commits. Push the fixes together and reply on the review threads. Set
`JILID_PACKAGES` to use another checkout.
