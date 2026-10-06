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
# https://cli.github.com
gh := require("gh")

TYP_PATHS := (
    "lib.typ " +
    "src " +
    "tests " +
    "template " +
    "docs"
)

# The files that ship in the package.
# The docs/ files that the README links to also ship.
PACKAGE_FILES := "LICENSE README.md typst.toml thumbnail.png lib.typ src template"

# A sparse checkout of https://github.com/typst/packages.
PACKAGES := env("JILID_PACKAGES", "../typst-packages")

# Regenerate thumbnail.png from the template cover
@thumbnail:
    just _render template/main.typ thumbnail.png --pages 1 --ppi 144
    echo "thumbnail.png: $(du -h thumbnail.png | cut -f1)"

# Regenerate docs/example.pdf
@example:
    just _render docs/example.typ docs/example.pdf
    echo "docs/example.pdf: $(du -h docs/example.pdf | cut -f1)"

# Preview a file live, with its @preview/jilid import pointed at this checkout
@watch file="template/main.typ":
    just _typst watch {{ file }}

# Print a CHANGELOG.md draft for the commits since the last tag
[group("release")]
@changelog:
    git-cliff --unreleased --tag "v$(just _version)" 2>/dev/null

# Set a new version in typst.toml and in every import and link that names it
[group("release")]
[script("bash")]
bump version:
    set -euo pipefail
    new="{{ version }}"
    if ! [[ "$new" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "error: the version must look like 1.2.3, not $new" >&2
      exit 1
    fi
    old=$(just _version)
    if [ "$old" = "$new" ]; then
      echo "error: typst.toml is already at $new" >&2
      exit 1
    fi
    o=${old//./\\.}
    sed -i "s/^version = \"$o\"/version = \"$new\"/" typst.toml
    files=$(grep -rlE "@preview/jilid:$o|jilid/blob/v$o/" README.md template docs/*.typ | tr "\n" " " || true)
    if [ -n "$files" ]; then
      sed -i "s|@preview/jilid:$o|@preview/jilid:$new|g; s|jilid/blob/v$o/|jilid/blob/v$new/|g" $files
    fi
    echo "$old -> $new in typst.toml $files"
    echo "next: write the CHANGELOG.md section for $new (just changelog prints a draft)"

# Tag the version in typst.toml, push it and create the GitHub Release
[group("release")]
[script("bash")]
release *flags:
    set -euo pipefail
    dry=false
    [ "{{ flags }}" = "--dry-run" ] && dry=true
    version=$(just _version)
    tag="v$version"
    fail() { echo "error: $*" >&2; exit 1; }

    [ "$(git branch --show-current)" = main ] || fail "release from main, not $(git branch --show-current)"
    [ -z "$(git status --porcelain)" ] || fail "commit or stash these first: $(git status --short | tr '\n' ' ')"
    git rev-parse -q --verify "refs/tags/$tag" >/dev/null && fail "the tag $tag already exists"
    [ -z "$(git ls-remote --tags origin "$tag")" ] || fail "the tag $tag already exists on origin"

    # The release notes are the CHANGELOG.md section for this version.
    notes=$(mktemp)
    trap 'rm -f "$notes"' EXIT
    awk -v v="$version" '
      $0 ~ "^## \\[" v "\\]" { on = 1; next }
      /^## \[/ { on = 0 }
      /^\[[^]]+\]: / { on = 0 }
      on
    ' CHANGELOG.md > "$notes"
    grep -q '[^[:space:]]' "$notes" || fail "CHANGELOG.md has no section for $version, add \"## [$version] - $(date +%F)\""

    just _validate
    just full-check

    echo ""
    echo "release notes:"
    cat "$notes"
    echo ""
    echo "ready: tag $tag at $(git rev-parse --short HEAD), push main and $tag, create the GitHub Release"
    if [ "$dry" = true ]; then
      echo "dry run, nothing was changed"
      exit 0
    fi
    read -r -p "continue? [y/N] " answer
    [ "$answer" = y ] || fail "stopped, nothing was changed"

    git tag -a "$tag" -m "jilid $version"
    git push origin main
    git push origin "$tag"
    gh release create "$tag" --verify-tag --title "jilid $version" --notes-file "$notes"
    echo "next: just package"

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

    # Compare with the latest upstream main.
    # Without a network connection, compare with the local main.
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
    # A commit that is already on the pull request stays.
    # Its review comments stay attached to it.
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
      # Name the shipped changes since the last packaged commit.
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

# Run every check: format, lint, docs and tests
[group("checks")]
@full-check:
    just _run-with-status fmt-check
    just _run-with-status lint
    just _run-with-status docs-check
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

# Check that the README lists every option of each option group
[group("checks")]
[script("bash")]
docs-check:
    set -euo pipefail
    status=0
    # Each line of the list is a group and a key, such as "cover top".
    keys=$(typst eval --root . 'import "/src/config.typ": defaults; defaults.pairs().map(((g, d)) => d.keys().map(k => g + " " + k).join("\n")).join("\n")' \
      | sed -e 's/^"//' -e 's/"$//' -e 's/\\n/\n/g')
    for group in $(cut -d' ' -f1 <<<"$keys" | sort -u); do
      # The README section of the group, from its heading to the next heading.
      section=$(awk -v h="### \`$group\`" '$0 == h { on = 1; next } /^#/ { on = 0 } on' README.md)
      if [ -z "$section" ]; then
        echo "README.md has no \"### \`$group\`\" section"
        status=1
        continue
      fi
      # The option names at the start of each list item, such as "- `top`\".
      listed=$(grep -E '^- `' <<<"$section" | grep -oE '`[a-z0-9-]+`' | tr -d '`' | sort -u)
      for key in $(awk -v g="$group" '$1 == g { print $2 }' <<<"$keys"); do
        grep -qx "$key" <<<"$listed" || { echo "README.md: \`$group.$key\` is missing"; status=1; }
      done
      for key in $listed; do
        awk -v g="$group" -v k="$key" '$1 == g && $2 == k { found = 1 } END { exit !found }' <<<"$keys" \
          || { echo "README.md: \`$group.$key\` is not an option"; status=1; }
      done
    done
    [ "$status" -eq 0 ] && echo "docs list every option"
    exit "$status"

# Compare tests with their reference images, with only the bundled fonts
[group("test")]
@test *args:
    tt run --warnings ignore {{ args }}
alias t := test

# Accept current output as reference images
[group("test")]
@test-update *args:
    tt update --warnings ignore {{ args }}
alias update := test-update

# Create a test with a starting test.typ
[group("test")]
[script("bash")]
new-test name:
    set -euo pipefail
    tt new {{ name }} >/dev/null
    printf '%s\n' \
      '// Say what this test covers and which options it sets.' \
      '#import "/lib.typ": *' \
      '#show: jilid' \
      '' \
      '= Satu' \
      '' \
      '#lorem(20)' > tests/{{ name }}/test.typ
    echo "created tests/{{ name }}/test.typ"
    echo "next: edit it, then run just update {{ name }}"

# Run a recipe with a status line before and after
@_run-with-status recipe *args:
    echo ""
    echo "→ {{ recipe }}"
    just {{ recipe }} {{ args }}
    echo "✓ {{ recipe }}"

# tinymist skips tests/errors.
# That test uses `catch` from the tytanic test library, and `tt` compiles it.
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

# Compile a file with its @preview/jilid import pointed at this checkout.
@_render file output *args:
    just _typst compile {{ file }} {{ output }} {{ args }}

# Run a typst command with the @preview/jilid import pointed at this checkout.
[script("bash")]
_typst command *args:
    set -euo pipefail
    version=$(just _version)
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    mkdir -p "$tmp/pkgs/preview/jilid"
    ln -s "$PWD" "$tmp/pkgs/preview/jilid/$version"
    typst {{ command }} --package-path "$tmp/pkgs" --root . {{ args }}

# The version in typst.toml.
@_version:
    grep -m1 '^version' typst.toml | cut -d'"' -f2

# The docs/ files that the README links to.
# They ship with the package.
@_docs:
    grep -o '](docs/[^)#]*' README.md | cut -c3- | sort -u | tr '\n' ' '

# Check the rules that Typst Universe reviewers check in a pull request.
[script("bash")]
_validate:
    set -euo pipefail
    version=$(just _version)
    status=0
    fail() { echo "error: $*" >&2; status=1; }

    for f in {{ PACKAGE_FILES }} $(just _docs); do
      git ls-files --error-unmatch -- "$f" >/dev/null 2>&1 || fail "$f is not committed"
    done

    # Every example must import the version in typst.toml.
    while IFS= read -r hit; do
      fail "$hit does not match version $version in typst.toml"
    done < <(grep -rnoIE '@preview/jilid:[0-9]+\.[0-9]+\.[0-9]+' README.md template docs \
      | grep -v ":$version\$" || true)

    if grep -rnE '#import "\.\.?/' template; then
      fail "template/ must import @preview/jilid:$version, not a relative path"
    fi

    # The thumbnail must be a PNG of 3 MiB or less.
    # Its long side must be 1080 px or more.
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

    # Every typ code block in the README must parse.
    # The Universe bot checks this too.
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

    # A link to a default branch can change after the release.
    # Link to a tag such as v0.2.0 instead.
    if grep -nE 'github\.com/[^ )]+/(blob|tree)/(main|master)/' README.md; then
      fail "README.md links to a default branch, link a tag like v$version instead"
    fi

    [ "$status" -eq 0 ] && echo "package rules ok"
    exit "$status"

# Copy the package files of HEAD into `dest`.
[script("bash")]
_stage dest:
    set -euo pipefail
    mkdir -p "{{ dest }}"
    git archive HEAD {{ PACKAGE_FILES }} $(just _docs) | tar -x -C "{{ dest }}"

# Run `typst init` on the package in `root` and compile the new project.
# Fail on errors and on warnings, without system fonts, like the web app does.
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
