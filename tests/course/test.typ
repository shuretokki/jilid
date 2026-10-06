// several lecturers and students, kind above title,
// report cover even with kind SKRIPSI, headings without page break,
// program above university and no faculty line.
#import "/lib.typ": *
#show: jilid.with(
  title: [Laporan Praktikum Basis Data],
  kind: [SKRIPSI],
  course: "Basis Data",
  lecturers: (
    (name: "Dosen Satu, S.Kom., M.Kom.", id: "100000000000000001"),
    (name: "Dosen Dua, S.T., M.T."),
  ),
  students: (
    (name: "Mahasiswa A", id: "1000000001"),
    (name: "Mahasiswa B", id: "1000000002"),
    (name: "Mahasiswa C"),
  ),
  cover-details: (([Kelompok], [3]), ([Kelas], [2024 A])),
  cover: (
    kind-pos: "top",
    kind: (fill: luma(90), tracking: 1pt),
    institution: (upper: false),
    institution-order: ("program", "university", "year"),
  ),
  university: "Universitas Contoh",
  faculty: "Fakultas Teknik",
  program: "Program Studi Teknik Informatika",
  year: "2026",
  headings: (h1: (size: 14pt, above: 0pt, below: 12pt, pagebreak: false)),
  code: (zebraw: false),
)

= Pertama

#lorem(20)

#figure(
  table(
    columns: 1,
    [x],
  ),
  caption: [Tabel],
)


```sql
SELECT * FROM mahasiswa;
```
= Kedua

#lorem(20)
