// A cover with a logo and 20 students under "Disusun oleh :".
// Automatic columns and 10pt student text keep the cover on one page.
// The institution lines are on one row.
#import "/lib.typ": *
#show: jilid.with(
  title: [Sistem Informasi Manajemen Data Kegiatan Kemahasiswaan Berbasis Web],
  kind: [Laporan Akhir Proyek],
  course: "Rekayasa Perangkat Lunak",
  lecturers: (name: "Nama Dosen, S.T., M.Kom.", id: "100000000000000001"),
  students: range(1, 21).map(i => (
    name: "Nama Mahasiswa " + str(i),
    id: "10000000" + str(i),
  )),
  program: "Teknik Informatika",
  faculty: "Teknik",
  university: "Nama Universitas",
  year: "2026",
  logo: image("/tests/assets/logo.svg"),
  cover: (
    logo-width: 4cm,
    student-name: (size: 10pt),
    id: (size: 10pt),
    institution-render: it => text(weight: "bold", it.lines.join(" · ")),
  ),
  labels: (students: [Disusun oleh : \ Kelompok 3]),
  outlines: (toc: false),
)

= Satu

#lorem(20)
