// user-set student columns: 5 students in 2 columns, ids below the names, the last cell empty.
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
