// no cover, no TOC, no figures, footer text changed mid-document,
// frontmatter with custom start page.
#import "/lib.typ": *
#show: jilid.with(
  title: "Tanpa Sampul",
  include-cover: false,
  outlines: (toc: false),
  headings: (h1: (uppercase: false)),
  numbering: (front: "a", heading: "1.a.", chapter: "1"),
  footer: (
    render: it => [
      #line(length: 100%, stroke: 0.5pt + luma(150))
      #v(0.2em)
      #if it.left != none [
        #align(left, text(size: 9pt, weight: "bold", it.left))
        #v(0.2em)
      ]
      #if it.number != none [
        #align(center, it.number)
      ]
    ],
  ),
)

#frontmatter(
  title: "Ringkasan",
  start-page: 3,
  outlined: false,
)[
  #lorem(20)
]

= Satu

== Dua

#lorem(30)

#set-footer-text[Footer diganti]

= Tiga

#lorem(30)
