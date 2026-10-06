set default-list := true
set shell := ["bash", "-euo", "pipefail", "-c"]

# https://typst.app
typst := require("typst")
# https://github.com/typstyle-rs/typstyle
typstyle := require("typstyle")
# https://github.com/Myriad-Dreamin/tinymist
tinymist := require("tinymist")
# https://github.com/typst-community/tytanic
tt := require("tt")
# https://git-cliff.org
git-cliff := require("git-cliff")

TYP_PATHS := (
    "lib.typ " +
    "src " +
    "tests " +
    "template " +
    "docs"
)

# files that ship; README-linked docs/ files are added to these.
PACKAGE_FILES := "LICENSE README.md typst.toml thumbnail.png lib.typ src template"

# sparse checkout of https://github.com/typst/packages
PACKAGES := env("JILID_PACKAGES", "../typst-packages")

# Regenerate thumbnail.png from the template cover
@thumbnail:
    just _render template/main.typ thumbnail.png --pages 1 --ppi 144
    echo "thumbnail.png: $(du -h thumbnail.png | cut -f1)"

# Regenerate docs/example.pdf
@example:
    just _render docs/example.typ docs/example.pdf
    echo "docs/example.pdf: $(du -h docs/example.pdf | cut -f1)"

# Write CHANGELOG.md, with new commits under the typst.toml version
[group("release")]
@changelog:
    git-cliff --tag "v$(just _version)" -o CHANGELOG.md

# Test the package built from the last commit, without touching the packages repo
[group("release")]
[script("bash")]
test-package:
    set -euo pipefail
    just _validate
    if [ -n "$(git status --porcelain -- {{ PACKAGE_FILES }} $(just _docs))" ]; then
      echo "note: uncommitted changes are left out, the package is built from HEAD" >&2
    fi
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    just _stage "$tmp/package"
    just _try-init "$tmp/package"

# Copy the package into the packages repo and commit it for a pull request
[group("release")]
[script("bash")]
package:
    set -euo pipefail
    version=$(just _version)
    branch="jilid-$version"
    files="{{ PACKAGE_FILES }} $(just _docs)"
    if [ -n "$(git status --porcelain -- $files)" ]; then
      echo "error: commit these first, the package is built from HEAD:" >&2
      git status --short -- $files >&2
      exit 1
    fi
    just _validate

    p=$(realpath -m "{{ PACKAGES }}")
    if ! git -C "$p" rev-parse --git-dir >/dev/null 2>&1; then
      echo "error: no packages checkout at $p, see CONTRIBUTING.md or set JILID_PACKAGES" >&2
      exit 1
    fi
    if [ "$(git -C "$p" config --bool core.sparseCheckout || true)" = true ] \
      && ! git -C "$p" sparse-checkout list | grep -qxE 'packages(/preview(/jilid)?)?'; then
      echo "error: $p does not check out packages/preview/jilid" >&2
      echo "fix: git -C $p sparse-checkout add packages/preview/jilid" >&2
      exit 1
    fi
    if [ -n "$(git -C "$p" status --porcelain)" ]; then
      echo "error: $p has uncommitted changes:" >&2
      git -C "$p" status --short >&2
      exit 1
    fi

    # check against the latest upstream, or local main when offline.
    if git -C "$p" fetch -q --depth 1 upstream main 2>/dev/null; then
      base=upstream/main
    else
      echo "warning: could not fetch upstream, using local main" >&2
      base=main
    fi
    if git -C "$p" cat-file -e "$base:packages/preview/jilid/$version" 2>/dev/null; then
      echo "error: jilid $version is already published, bump the version in typst.toml" >&2
      exit 1
    fi
    just full-check

    if git -C "$p" rev-parse --verify -q "refs/heads/$branch" >/dev/null; then
      git -C "$p" checkout -q "$branch"
    else
      git -C "$p" checkout -q -b "$branch" "$base"
    fi
    dir="$p/packages/preview/jilid/$version"
    rm -rf "$dir"
    just _stage "$dir"
    just _try-init "$dir"

    git -C "$p" add -A "packages/preview/jilid/$version"
    remote=$(git -C "$p" ls-remote origin "$branch" 2>/dev/null | cut -f1)
    # a commit already on the pull request is kept, so review threads stay intact.
    pushed=false
    if [ -n "$remote" ] && git -C "$p" merge-base --is-ancestor HEAD "$remote" 2>/dev/null; then
      pushed=true
    fi
    repo=$(git remote get-url origin | sed -E 's#.*github\.com[:/]##; s#\.git$##')
    source="From $repo@$(git rev-parse HEAD)"
    if git -C "$p" diff --cached --quiet; then
      echo "up to date: $branch already has this package"
    elif git -C "$p" merge-base --is-ancestor HEAD "$base"; then
      git -C "$p" commit -q -m "jilid:$version" -m "$source"
      echo "committed jilid:$version on $branch"
    elif [ "$pushed" = false ]; then
      git -C "$p" commit -q --amend -m "$(git -C "$p" log -1 --format=%s)" -m "$source"
      echo "amended $(git -C "$p" log -1 --format=%s) on $branch"
    else
      # name the shipped changes since the last packaged commit.
      prev=$(git -C "$p" log -1 --format=%b | sed -nE 's/.*@([0-9a-f]{40}).*/\1/p')
      changes=""
      if [ -n "$prev" ] && git merge-base --is-ancestor "$prev" HEAD 2>/dev/null; then
        changes=$(git log --reverse --format='- %s' "$prev..HEAD" -- $files)
      fi
      if [ "$(printf '%s\n' "$changes" | grep -c '^- ')" -eq 1 ]; then
        msg="jilid:$version: ${changes#- }"
      else
        msg="jilid:$version: update"
      fi
      git -C "$p" commit -q -m "$msg" -m "${changes:+$changes$'\n\n'}$source"
      echo "committed $msg on $branch"
    fi

    owner=$(git -C "$p" remote get-url origin | sed -E 's#.*github\.com[:/]([^/]+)/.*#\1#')
    echo ""
    echo "next, from $p:"
    if [ -z "$remote" ]; then
      echo "  git push -u origin $branch"
      echo "  gh pr create -R typst/packages --base main --head $owner:$branch --title jilid:$version"
    elif git -C "$p" merge-base --is-ancestor "$remote" HEAD 2>/dev/null; then
      echo "  git push origin $branch"
      echo "then reply on the pull request with what changed."
    else
      echo "  git push --force-with-lease=$branch:$remote origin $branch"
    fi

# Run every check: format, lint, tests
[group("checks")]
@full-check:
    just _run-with-status fmt-check
    just _run-with-status lint
    just _run-with-status test
    echo ""
    echo "All checks passed."
alias check := full-check
alias fc := full-check

# Check that every .typ file is typstyle-formatted
[group("checks")]
@fmt-check:
    typstyle --check {{ TYP_PATHS }}

# Format every .typ file in place
[group("checks")]
@fmt-write:
    typstyle -i {{ TYP_PATHS }}
alias fmt := fmt-write

# Lint test entrypoints with tinymist
[group("checks")]
@lint:
    just _lint

# Compare tests with their reference images, note that it uses bundled fonts
[group("test")]
@test *args:
    tt run --warnings ignore {{ args }}
alias t := test

# Accept current output as reference images
[group("test")]
@test-update *args:
    tt update --warnings ignore {{ args }}
alias update := test-update

# Run a recipe with a status line before and after
@_run-with-status recipe *args:
    echo ""
    echo "→ {{ recipe }}"
    just {{ recipe }} {{ args }}
    echo "✓ {{ recipe }}"

# tests/errors uses tytanic's test library (`catch`), unknown to tinymist,
# so it is compiled by `tt` instead.
[script("bash")]
_lint:
    set -euo pipefail
    status=0
    for f in tests/*/test.typ; do
      [ "$f" = tests/errors/test.typ ] && continue
      out=$(tinymist lint --root . "$f" 2>&1 | grep -E '^(warning|error)' -A4 || true)
      if [ -n "$out" ]; then echo "$f:"; echo "$out"; status=1; fi
    done
    [ "$status" -eq 0 ] && echo "lint clean"
    exit "$status"

# Compiles a file with its @preview/jilid import pointed at this checkout.
[script("bash")]
_render file output *args:
    set -euo pipefail
    version=$(just _version)
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    mkdir -p "$tmp/pkgs/preview/jilid"
    ln -s "$PWD" "$tmp/pkgs/preview/jilid/$version"
    typst compile --package-path "$tmp/pkgs" --root . {{ file }} {{ output }} {{ args }}

# The version in typst.toml.
@_version:
    grep -m1 '^version' typst.toml | cut -d'"' -f2

# The docs/ files the README links to, which ship with the package.
@_docs:
    grep -o '](docs/[^)#]*' README.md | cut -c3- | sort -u | tr '\n' ' '

# Checks the Typst Universe rules a pull request is reviewed against.
[script("bash")]
_validate:
    set -euo pipefail
    version=$(just _version)
    status=0
    fail() { echo "error: $*" >&2; status=1; }

    for f in {{ PACKAGE_FILES }} $(just _docs); do
      git ls-files --error-unmatch -- "$f" >/dev/null 2>&1 || fail "$f is not committed"
    done

    # every example imports the version being released.
    while IFS= read -r hit; do
      fail "$hit does not match version $version in typst.toml"
    done < <(grep -rnoIE '@preview/jilid:[0-9]+\.[0-9]+\.[0-9]+' README.md template docs \
      | grep -v ":$version\$" || true)

    if grep -rnE '#import "\.\.?/' template; then
      fail "template/ must import @preview/jilid:$version, not a relative path"
    fi

    # thumbnail: a PNG, 1080 px or more on the long side, 3 MiB at most.
    read -r w h < <(file -b thumbnail.png | sed -nE 's/^PNG image data, ([0-9]+) x ([0-9]+).*/\1 \2/p') || true
    if [ -z "${w:-}" ]; then
      fail "thumbnail.png is not a PNG"
    elif [ "$(( w > h ? w : h ))" -lt 1080 ]; then
      fail "thumbnail.png is ${w}x${h}, the long side needs 1080 px or more"
    fi
    [ "$(stat -c %s thumbnail.png)" -le 3145728 ] || fail "thumbnail.png is larger than 3 MiB"
    if grep -n 'thumbnail\.png' README.md; then
      fail "README.md must not reference thumbnail.png"
    fi

    # typ code blocks in the README must parse, as the Universe bot checks.
    blocks=$(mktemp -d)
    trap 'rm -rf "$blocks"' EXIT
    awk -v d="$blocks" '/^```typ$/ { n++; on = 1; next } /^```/ { on = 0 } on { print > (d "/block" n ".typ") }' README.md
    for f in "$blocks"/*.typ; do
      [ -e "$f" ] || continue
      out=$(typst compile "$f" "$blocks/out.pdf" 2>&1 || true)
      if grep -qE 'error: (expected|unclosed|unexpected)' <<<"$out"; then
        fail "README.md: typ code $(basename "$f" .typ) has a syntax error"
      fi
    done

    # links to a default branch drift away from the released version.
    if grep -nE 'github\.com/[^ )]+/(blob|tree)/(main|master)/' README.md; then
      fail "README.md links to a default branch, link a tag like v$version instead"
    fi

    [ "$status" -eq 0 ] && echo "package rules ok"
    exit "$status"

# Copies the package files of HEAD into `dest`.
[script("bash")]
_stage dest:
    set -euo pipefail
    mkdir -p "{{ dest }}"
    git archive HEAD {{ PACKAGE_FILES }} $(just _docs) | tar -x -C "{{ dest }}"

# Runs `typst init` on the package in `root` and compiles the new project.
# Fails on errors and on warnings, without system fonts, like the web app.
[script("bash")]
_try-init root:
    set -euo pipefail
    version=$(just _version)
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    mkdir -p "$tmp/pkgs/preview/jilid"
    cp -r "{{ root }}" "$tmp/pkgs/preview/jilid/$version"
    if ! out=$(typst init --package-path "$tmp/pkgs" "@preview/jilid:$version" "$tmp/project" 2>&1); then
      echo "$out" >&2
      echo "error: typst init failed" >&2
      exit 1
    fi
    if ! out=$(cd "$tmp/project" && typst compile --package-path "$tmp/pkgs" --ignore-system-fonts main.typ 2>&1); then
      echo "$out" >&2
      echo "error: the template does not compile" >&2
      exit 1
    fi
    if [ -n "$out" ]; then
      echo "$out" >&2
      echo "error: the template compiles with warnings" >&2
      exit 1
    fi
    echo "template compiles cleanly after typst init @preview/jilid:$version"
