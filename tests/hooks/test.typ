// Render hooks: a cover in a box, a footer with "Halaman n" and bold captions with a period.
#import "/lib.typ": *
#show: jilid.with(
  title: [Judul Laporan],
  kind: [Laporan Praktikum],
  students: (
    (name: "Mahasiswa A", id: "1000000001"),
    (name: "Mahasiswa B", id: "1000000002"),
  ),
  faculty: "Teknik",
  university: "Nama Universitas",
  year: "2026",
  cover: (
    render: it => align(center)[
      #v(3cm)
      #box(stroke: 1pt, inset: 1em, text(16pt, it.title))
      #v(1fr)
      #table(
        columns: 2,
        ..it.students.map(s => (s.name, s.id)).flatten(),
      )
      #v(1fr)
      #it.university \ #it.faculty \ #it.year
    ],
  ),
  footer: (
    left: [Laporan Praktikum],
    render: it => grid(
      columns: (1fr, auto),
      emph(it.left), if it.number != none [Halaman #it.number],
    ),
  ),
  typography: (
    caption: it => strong[#it.supplement #it.number. #it.body],
  ),
  outlines: (toc: false),
)

= Satu

#figure(rect(width: 4cm, height: 2cm), caption: [Gambar pertama])

#lorem(20)
