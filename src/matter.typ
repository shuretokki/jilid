#import "state.typ": page-label, section, sections
#import "rules/text.typ": para-rules
#import "pages/outlines.typ": figure-entry-rules, outlines

// fail on a level-1 heading written with `=` in `fn`.
#let check-body(body, fn) = {
  let children = if body.has("children") { body.children } else { (body,) }
  for c in children {
    if (
      c.func() == heading
        and c.at("level", default: auto) in (auto, 1)
        and c.at("depth", default: 1) == 1
    ) {
      panic(
        "jilid: use `title:` instead of `=` in `"
          + fn
          + "`, e.g. `#"
          + fn
          + "(title: [Judul])[..]`.",
      )
    }
  }
}

// fail on an argument removed in 0.2.
#let check-removed(args, fn) = {
  let named = args.named().keys()
  if named.len() > 0 {
    panic(
      "jilid: `"
        + fn
        + "` takes only `title:` since 0.2, remove "
        + named.map(k => "`" + k + "`").join(", ")
        + ". See \"Migrating from 0.1\" in the README.",
    )
  }
}

/// A front matter page, such as Kata Pengantar or Abstrak.
///
/// Front matter is the pages before the table of contents.
/// jilid puts each `frontmatter` page there, in the order you write them.
/// You can write them anywhere in the file.
/// For a heading inside the page, use `==` or deeper.
/// If you write a `=` heading inside, jilid stops with an error.
///
/// = Example
///
/// ```
/// #frontmatter(title: [Kata Pengantar])[
///   Puji syukur ...
/// ]
/// ```
///
/// ```
/// #frontmatter(title: [Abstrak], label: <abstrak>)[
///   Abstrak ...
/// ]
/// ```
///
/// - title (content, str, none): The page title. jilid shows it like a chapter title, centered and without a number.
/// - label (label, none): A label that you can refer to with `@`, such as `<abstrak>`. jilid shows the reference as the title and its page, such as "Abstrak (halaman ii)". It needs a `title`.
/// - removed (arguments): Arguments that jilid 0.2 removed: `numbering`, `start-page` and `outlined`. If you give one of them, jilid stops with an error that tells you what changed.
/// - body (content): The text of the page.
/// -> content
#let frontmatter(
  /// The page title. jilid shows it like a chapter title, centered and without a number.
  title: none,
  /// A label that you can refer to with `@`, such as `<abstrak>`. It needs a `title`.
  label: none,
  /// Arguments that jilid 0.2 removed. If you give one, jilid stops with an error.
  ..removed,
  /// The text of the page.
  body,
) = {
  check-removed(removed, "frontmatter")
  check-body(body, "frontmatter")
  assert(
    label == none or type(label) == std.label,
    message: "jilid: `frontmatter(label: ..)` must be a label, e.g. `label: <abstrak>`.",
  )
  assert(
    label == none or title != none,
    message: "jilid: `frontmatter(label: ..)` needs a `title`.",
  )
  [#metadata((
    kind: sections.front,
    title: title,
    label: label,
    body: body,
  )) <jilid-matter>]
}

/// One appendix, such as Lampiran 1.
///
/// jilid puts every appendix after the bibliography, in the order you write them.
/// You can write them anywhere in the file.
/// jilid numbers each appendix by its place in that order.
/// Figures, tables and equations inside get the appendix number, such as Gambar L1.2.
/// For a heading inside the appendix, use `==` or deeper.
/// If you write a `=` heading inside, jilid stops with an error.
///
/// = Example
///
/// ```
/// #appendix(title: [Kuesioner], label: <kuesioner>)[
///   Daftar pertanyaan ...
/// ]
///
/// Lihat @kuesioner.
/// ```
///
/// - title (content, str, none): The appendix title. jilid shows it after the number, such as "Lampiran 1. Kuesioner".
/// - label (label, none): A label that you can refer to with `@`, such as `<kuesioner>`.
/// - body (content): The text of the appendix.
/// -> content
#let appendix(
  /// The appendix title. jilid shows it after the number.
  title: none,
  /// A label that you can refer to with `@`, such as `<kuesioner>`.
  label: none,
  /// The text of the appendix.
  body,
) = {
  assert(
    label == none or type(label) == std.label,
    message: "jilid: `appendix(label: ..)` must be a label, e.g. `label: <kuesioner>`.",
  )
  check-body(body, "appendix")
  [#metadata((
    kind: sections.back,
    title: title,
    label: label,
    body: body,
  )) <jilid-matter>]
}

// renamed to `appendix` in 0.2.
#let appendices(..args) = panic(
  "jilid: `appendices` is `appendix(title: [..])[..]` since 0.2, one call per appendix. See \"Migrating from 0.1\" in the README.",
)

#let blocks-of(kind) = query(<jilid-matter>).filter(m => m.value.kind == kind)

#let render-frontmatter(cfg, m) = {
  let v = m.value
  let title = if v.title != none { heading(level: 1, numbering: none, v.title) }
  if v.label != none { title = [#title#v.label] }
  let body = {
    set figure(outlined: false)
    set heading(numbering: none)
    v.body
  }
  para-rules(cfg, title + body)
}

// number figures, tables and equations as "L1.2".
#let render-appendix(cfg, m, n) = {
  let v = m.value
  let title = heading(level: 1, if v.title == none [] else { v.title })
  let prefix = [#cfg.t.appendix-short#numbering(cfg.numbering.appendix, n).]
  let body = {
    set figure(outlined: false, numbering: x => [#prefix#x])
    set math.equation(numbering: x => [(#prefix#x)])
    set heading(numbering: none)
    v.body
  }
  para-rules(cfg, if v.label != none [#title#v.label#body] else [#title#body])
}

// everything after the cover
// front matter > outlines > `body` > appendices.
#let flow(cfg, body) = {
  section.update(sections.front)
  counter(page).update(1)

  show: figure-entry-rules.with(cfg)

  [#metadata(none) <jilid-section-front>]
  context {
    for m in blocks-of(sections.front) {
      render-frontmatter(cfg, m)
      pagebreak(weak: true)
    }
  }

  outlines(cfg)

  [#metadata(none) <jilid-marker-front-end>]
  pagebreak(weak: true)
  section.update(sections.main)
  counter(page).update(1)
  counter(heading).update(0)
  [#metadata(none) <jilid-section-body>]
  body

  context {
    let back = blocks-of(sections.back)
    if back.len() > 0 {
      pagebreak(weak: true)

      if cfg.numbering.back == "front" {
        let end-marker = query(<jilid-marker-front-end>).first()
        let val = counter(page).at(end-marker.location()).first()
        counter(page).update(val + 1)
      }

      section.update(sections.back)
      [#metadata(none) <jilid-section-back>]
      heading(level: 1, numbering: none, outlined: true)[#cfg.t.appendices]
      [#metadata(none) <jilid-appendices-start>]
      counter(heading).update(0)

      for (i, m) in back.enumerate() { render-appendix(cfg, m, i + 1) }
    }
  }

  // save the start page of each part.
  // read it with `typst eval 'query(<jilid-pages>)' --in doc.typ`.
  context {
    let start(lbl) = {
      let q = query(lbl)
      if q.len() > 0 {
        let loc = q.first().location()
        (idx: counter(page).at(loc).first(), display: page-label(cfg, loc))
      }
    }
    [#metadata((
      front: start(<jilid-section-front>),
      body: start(<jilid-section-body>),
      back: start(<jilid-section-back>),
    )) <jilid-pages>]
  }
}
