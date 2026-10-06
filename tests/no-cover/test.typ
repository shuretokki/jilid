// No cover, no DAFTAR ISI and no figures.
// The footer text changes in the middle of the document.
// A frontmatter page without a title has its own outline.
// The web link uses the body font.
#import "/lib.typ": *
#show: jilid.with(
  title: "Tanpa Sampul",
  include-cover: false,
  outlines: (toc: false),
  headings: (h1: (uppercase: false)),
  typography: (url: (font: "Libertinus Serif", underline: false)),
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

#frontmatter[
  #lorem(20)
  #outline(title: [Daftar Simbol], target: figure.where(kind: "simbol"))
]

= Satu

== Dua

https://typst.app

#lorem(30)

#set-footer-text[Footer diganti]

= Tiga

#lorem(30)
