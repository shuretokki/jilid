# Contributing

Bug reports and requests for campus rules jilid does not support yet are
welcome as issues. For pull requests, please use a separate branch and run
`just check` first.

The Nix flake provides Typst, typstyle, tinymist, just and tytanic
(`nix develop`, or direnv with the included `.envrc`).

```sh
just check      # typstyle --check, tinymist lint, tytanic tests
just fmt        # format all .typ files
just update     # accept new reference images
just thumbnail  # regenerate thumbnail.png from the template
just example    # regenerate docs/example.pdf
```

## Releasing (maintainer)

Typst Universe takes updates from the author of the first release, so only
the maintainer releases jilid. Releases go to Typst Universe as a pull
request to [typst/packages](https://github.com/typst/packages), from a sparse
checkout next to this repository:

```sh
git clone --depth 1 --no-checkout --filter="tree:0" https://github.com/<you>/packages ../typst-packages
git -C ../typst-packages sparse-checkout set packages/preview/jilid
git -C ../typst-packages remote add upstream https://github.com/typst/packages
git -C ../typst-packages checkout main
```

Then bump `version` in `typst.toml` and every `@preview/jilid:` import, commit,
tag it `v<version>`, and run:

```sh
just test-package  # build the package from HEAD and test typst init on it
just package       # copy it to ../typst-packages and commit jilid:<version>
```

`just package` prints the push and `gh pr create` commands. Once the pull
request is pushed, it adds follow-up commits, so push the fixes together and
reply on the review threads. Set `JILID_PACKAGES` to use another checkout.
