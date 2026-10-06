#import "state.typ": page-label, section, sections
#import "rules/text.typ": para-rules
#import "pages/outlines.typ": figure-entry-rules, outlines

// fail on a level-1 heading written with `=` in `fn`.
#let no-h1(fn) = it => panic(
  "jilid: use `title:` instead of `=` in `"
    + fn
    + "`, e.g. `#"
    + fn
    + "(title: [Judul])[..]`.",
)

#let check-body(body, fn) = {
  let children = if body.has("children") { body.children } else { (body,) }
  for c in children {
    if (
      c.func() == heading
        and c.at("level", default: auto) in (auto, 1)
        and c.at("depth", default: 1) == 1
    ) { no-h1(fn)(c) }
  }
}

// front matter can be written anywhere.
// it renders before the table of contents, in writing order.
#let frontmatter(
  // styled like a chapter title, centered and unnumbered.
  title: none,
  body,
) = {
  check-body(body, "frontmatter")
  [#metadata((kind: sections.front, title: title, body: body)) <jilid-matter>]
}

// appendices render after the bibliography, wherever you write them.
// each call is one appendix: "Lampiran 1. Title", "Lampiran 2. Title", ...
#let appendix(
  title: none,
  // a label to refer to the appendix, e.g. `<kuesioner>`.
  label: none,
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

#let blocks-of(kind) = query(<jilid-matter>).filter(m => m.value.kind == kind)

#let render-frontmatter(cfg, m) = {
  let v = m.value
  let title = if v.title != none { heading(level: 1, numbering: none, v.title) }
  let body = {
    set figure(outlined: false)
    set heading(numbering: none)
    show heading.where(level: 1): no-h1("frontmatter")
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
    show heading.where(level: 1): no-h1("appendix")
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
