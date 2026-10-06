// A small page, where a block that can break would split.
#import "/lib.typ": signature, signatures
#set page(width: 12cm, height: 9cm, margin: 1cm)
#set par(justify: true, first-line-indent: (amount: 0.63cm, all: true))

// The roles have different heights, and one signature has no ID.
// The names must line up with `align: bottom`.
#grid(
  columns: (1fr, 1fr, 1fr),
  align: bottom,
  stroke: 0.3pt + luma(200),
  signature(role: none, name: "No Role", id: "1"),
  signature(role: [Mahasiswa], name: "No Id"),
  signature(
    role: [Kota, 1 Jan 2026 \ Mengetahui, \ Koordinator Prodi],
    name: "Long Role",
    id: "3",
    underline-name: true,
  ),
)

#v(1fr)
// This block starts near the bottom of the page.
// It must move to page 2 as a whole.
#signature(role: [Dosen Pembimbing], name: "Kept Together", id: "4")

#grid(
  columns: (1fr, 1fr),
  signature(role: [Bare id], name: "Id Label None", id: "5", id-label: none),
  signature(
    role: [Left aligned],
    name: "Left",
    id: "6",
    id-label: "NIDN",
    alignment: left,
    space: 1cm,
  ),
)

#pagebreak()
// A header across the full width and two signatures in each row.
// The last row has one signature, in the center.
#signatures(
  header: [Kota, 1 Januari 2026 \ Mengetahui,],
  gutter: 0.5cm,
  signature(role: [Dosen Pembimbing], name: "Dosen A", id: "1", space: 1cm),
  signature(
    role: [Mahasiswa \ Ketua Kelompok],
    name: "Mahasiswa B",
    id-label: "NIM",
    id: "2",
    space: 1cm,
  ),
  signature(role: [Koordinator Prodi], name: "Dosen C", id: "3", space: 1cm),
)
