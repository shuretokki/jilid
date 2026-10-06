// > Compile-only.
// bad options fail with a `jilid:` message naming the problem
// valid partial options compile.
#import "/lib.typ": appendices, appendix, frontmatter, jilid, signatures

#let fails-with(needle, ..args) = {
  let msg = catch(() => jilid(..args, []))
  assert(msg != none, message: "expected a panic mentioning " + repr(needle))
  assert(
    msg.contains(needle),
    message: "expected " + repr(needle) + " in: " + msg,
  )
}

#fails-with("unknown option `cover.titel-size`", cover: (titel-size: 20pt))
#fails-with("unknown option `headings.h1.sise`", headings: (h1: (sise: 14pt)))
#fails-with("`headings.h1` expects a dictionary", headings: (h1: auto))
#fails-with("language `de` is not built in", lang: "de")
#fails-with("unknown `labels` key `tittle`", labels: (tittle: [X]))
#fails-with("`logo` must be content", logo: "x.png")
#fails-with("`bibliography` must be content", bibliography: "refs.bib")
#fails-with("(label, value) pair", cover-details: ([A], [B]))
#fails-with("`code.zebraw` must be", code: (zebraw: "yes"))
#fails-with("`margin` must be", margin: "wide")
#fails-with("`cover.student-columns` must be", cover: (student-columns: 0))
#fails-with("`footer.render` must be auto or a function", footer: (render: "x"))
#fails-with("`cover.student-id-pos` must be one of", cover: (
  student-id-pos: "left",
))
#fails-with("each entry of `students`", students: ("Budi",))
#fails-with("`students` must be a list", students: "Budi")
#fails-with("unknown option `footer.mode`", footer: (mode: "grid"))
#fails-with("`numbering.back` must be one of", numbering: (back: "Body"))
#fails-with("`outlines.align-numbers` must be one of", outlines: (
  align-numbers: "page",
))
#fails-with("`cover.kind-pos` must be one of", cover: (kind-pos: "above"))
#fails-with("unknown option `cover.formal`", cover: (formal: true))
#fails-with("`cover.title` expects a dictionary", cover: (title: 20pt))
#fails-with("`cover.institution-order` must be a list", cover: (
  institution-order: ("univ",),
))
#fails-with("`cover.institution-render` must be auto or a function", cover: (
  institution-render: [x],
))
#let msg = catch(() => signatures(headr: [x]))
#assert(
  msg != none and msg.contains("unknown argument(s) for `signatures`: `headr`"),
)
#fails-with("`labels.toc` takes the text itself", labels: (toc: (id: [ISI])))
#let msg = catch(() => frontmatter[= Kata Pengantar])
#assert(
  msg != none and msg.contains("use `title:` instead of `=` in `frontmatter`"),
)
#let msg = catch(() => appendix[= Data])
#assert(
  msg != none and msg.contains("use `title:` instead of `=` in `appendix`"),
)
#let msg = catch(() => appendix(label: "data")[])
#assert(msg != none and msg.contains("`appendix(label: ..)` must be a label"))
#let msg = catch(() => frontmatter(label: <x>)[x])
#assert(
  msg != none and msg.contains("`frontmatter(label: ..)` needs a `title`"),
)
#let msg = catch(() => frontmatter(title: [X], label: "x")[x])
#assert(
  msg != none and msg.contains("`frontmatter(label: ..)` must be a label"),
)
#let msg = catch(() => appendices[x])
#assert(
  msg != none and msg.contains("`appendices` is `appendix(title: [..])[..]`"),
)
#let msg = catch(() => frontmatter(numbering: "I", start-page: 3)[x])
#assert(
  msg != none and msg.contains("remove `numbering`, `start-page`"),
)


// Valid partial options must not panic.
#assert.eq(catch(() => jilid(headings: (h1: (size: 14pt)), [])), none)
#assert.eq(catch(() => jilid(labels: (toc: [ISI]), [])), none)
#assert.eq(catch(() => jilid(students: (name: [Budi *S*], id: "1"), [])), none)
#assert.eq(catch(() => jilid(lecturers: (name: "Dosen"), [])), none)
#assert.eq(
  catch(() => jilid(
    lang: "de",
    labels: (
      course: "Kurs",
      lecturer: "Dozent",
      students: "Autoren",
      student-id: "Matr.",
      lecturer-id: "ID",
      program: "STUDIENGANG",
      faculty: "FAKULTÄT",
      department: "INSTITUT",
      toc: [INHALT],
      lof: [ABBILDUNGEN],
      lot: [TABELLEN],
      loc: [CODE],
      appendix-list: [ANHÄNGE],
      bibliography: [LITERATUR],
      appendices: [ANHANG],
      appendix: "Anhang",
      appendix-short: "A",
      chapter: "KAPITEL",
      figure: "Abbildung",
      table: "Tabelle",
      code: "Code",
      equation: "Gleichung",
      section: "Abschnitt",
      page: "Seite",
    ),
    [],
  )),
  none,
)
