// A cover with many authors: 10 students, 3 lecturers and a long title.
// One lecturer has no ID, and the names are long.
// The cover must stay on one page.
#import "/lib.typ": *
#show: jilid.with(
  title: [Sistem Informasi Manajemen Data Kegiatan Kemahasiswaan Berbasis Web dengan Modul Pelaporan Otomatis],
  kind: [Laporan Akhir Proyek],
  course: "Rekayasa Perangkat Lunak",
  lecturers: (
    (
      name: "Prof. Dr. Nama Dosen Pertama Yang Cukup Panjang, S.T., M.Kom., Ph.D.",
      id: "100000000000000001",
    ),
    (name: "Nama Dosen Kedua, S.Kom., M.T.", id: "100000000000000002"),
    (name: "Nama Dosen Ketiga, S.Si., M.Sc."),
  ),
  students: range(1, 11).map(i => (
    name: "Nama Mahasiswa Nomor " + str(i) + " Dengan Nama Panjang",
    id: "10000000" + str(i),
  )),
  program: "Teknik Informatika",
  faculty: "Teknik",
  university: "Nama Universitas",
  year: "2026",
  outlines: (toc: false),
)

= Satu

#lorem(20)
