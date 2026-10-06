// MBKM proposal with every common feature.
#import "/lib.typ": *
#show: jilid.with(
  title: [Proposal Program Mahasiswa Berdampak],
  kind: [Kerja Praktik],
  subtitle: [Sistem Informasi],
  cover-details: (([Mitra Kolaborator:], [Mitra]),),
  students: ((name: "Nama Mahasiswa", id: "10000000000"),),
  program: "Teknik Informatika",
  faculty: "Teknik",
  university: "Universitas XYZ",
  year: "2026",
  logo: image("/tests/assets/logo.svg"),
  footer: (left: [Proposal Kerja Praktik 2026], text: (style: "italic")),
  cover: (
    logo-width: 5cm,
    title: (size: 12pt),
    kind: (size: 12pt),
    subtitle: (size: 12pt),
    details: (size: 12pt),
  ),
  typography: (font-size: 11pt, table-size: 11pt),
  labels: (students: [*Penyusun*], figure: "Gbr."),
  bibliography: bibliography(
    "/tests/assets/refs.bib",
    style: "harvard-cite-them-right",
  ),
)

#frontmatter(title: [Lembar Pengesahan])[
  #signatures(
    header: [Kota, 1 Januari 2026 \ Mengetahui,],
    signature(
      role: [Dosen Pembimbing],
      underline-name: true,
      name: "Nama Dosen",
      id-label: "NIP.",
      id: "1999",
    ),
    signature(
      role: [Mahasiswa],
      name: "Nama Mahasiswa",
      id-label: "NIM.",
      id: "1000000000",
    ),
  )
  #v(1cm)
  #signatures(
    header: [Menyetujui,],
    signature(
      role: [Koordinator Program Studi],
      name: "Nama Koordinator",
      id: "1988",
    ),
  )
]

#frontmatter(title: [Kata Pengantar], label: <kata-pengantar>)[
  #lorem(40)
]

= Pendahuluan <bab-1>

== Latar Belakang

#lorem(60) @knuth1984texbook.

#figure(rect(width: 4cm, height: 2cm), caption: [Gambar pertama]) <fig-a>

#figure(
  table(
    columns: 2,
    [a], [b],
    [c], [d],
  ),
  caption: [Tabel pertama],
) <tab-a>

$ E = m c^2 $ <eq-a>

Lihat @fig-a, @tab-a, dan @eq-a.

=== Sub Sub Bab

#lorem(20)

= Tinjauan Pustaka

Seperti dijelaskan pada @bab-1 dan @kata-pengantar.

#heading(level: 2, numbering: none)[Subbab Tanpa Nomor]

#figure(
  grid(
    columns: 2,
    gutter: 1cm,
    rect(width: 3cm, height: 2cm), image("/tests/assets/logo.svg", width: 2cm),
  ),
  caption: [Dua gambar dalam satu figure],
)

#figure(rect(width: 4cm, height: 2cm), caption: [Gambar bab dua])

#figure(
  ```python
  print("halo")
  ```,
  caption: [Kode pertama],
)

#lorem(30) @lamport1994latex.

#appendix(title: [Lampiran Satu], label: <lamp-1>)[
  #figure(rect(width: 3cm, height: 1cm), caption: [Gambar lampiran])
  #lorem(20)
]

#appendix(title: [Lampiran Dua])[
  Lihat @lamp-1.
]
