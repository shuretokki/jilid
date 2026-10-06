// The user sets 2 student columns for 5 students.
// The IDs go under the names, and the last cell stays empty.
#import "/lib.typ": *
#show: jilid.with(
  title: [Laporan Praktikum],
  students: range(1, 6).map(i => (
    name: "Mahasiswa " + str(i),
    id: "1000000" + str(i),
  )),
  university: "Nama Universitas",
  year: "2026",
  cover: (student-columns: 2, student-id-pos: "below"),
  outlines: (toc: false),
)

= Satu

#lorem(20)
