#import "@preview/jilid:0.2.0": (
  appendix, frontmatter, jilid, set-footer-text, signature, signatures, zebraw,
)

#show: jilid.with(
  title: [Sistem Informasi Peminjaman Ruang Kelas Berbasis Web],
  kind: [Laporan Praktikum],
  course: "Rekayasa Perangkat Lunak",
  lecturers: (name: "Nama Dosen, S.T., M.Kom.", id: "100000000000000001"),
  students: (name: "Nama Mahasiswa", id: 1000000001),
  program: "Teknik Informatika",
  faculty: "Teknik",
  university: "Nama Universitas",
  year: "2026",
  // placeholder logo from logoipsum.com, see logoipsum.com/license.
  logo: image("logo.svg"),
  cover: (
    logo-width: 5cm,
    student-name: (style: "italic", weight: "bold", underline: true),
    student-id-pos: "below",
  ),
  cover-details: (([Detail], [Tambahan]),),
  bibliography: bibliography("refs.bib", style: "ieee"),
  labels: (students: [Disusun oleh : \ Kelompok 3]),
  numbering: (
    position: "top",
  ),
)

#frontmatter(title: [Contoh Lembar Pengesahan])[
  #v(1cm)
  #signatures(
    header: [Kota, 1 Januari 2026 \ Mengetahui,],
    signature(
      role: [Koordinator],
      name: "Nama Koordinator",
      id: "100000000000000001",
    ),
    signature(
      role: [Ketua Kelompok],
      name: "Nama Mahasiswa 1",
      id-label: "NIM",
      id: "1000000001",
    ),
  )
  #v(1cm)
  #signatures(
    header: [Menyetujui,],
    signature(
      role: [Koordinator],
      name: "Nama Koordinator",
      id: "100000000000000003",
    ),
  )
]

#frontmatter(title: [Abstrak])[
  #lorem(90)

  *Kata kunci:* sistem informasi, peminjaman ruang, aplikasi web.
]

#frontmatter(title: [Abstract])[
  #lorem(90)

  _*Keywords:*_ information system, room booking, web application.
]

#frontmatter(title: [Kata Pengantar])[
  #lorem(70)

  #lorem(50)
]

= Pendahuluan <bab-pendahuluan>

== Latar Belakang

#lorem(80)

#lorem(60)

== Rumusan Masalah

+ #lorem(12)
+ #lorem(10)
+ #lorem(14)

== Tujuan

- #lorem(10)
- #lorem(12)

= Tinjauan Pustaka <bab-tinjauan>

== Landasan Teori

#lorem(50) @knuth1986-bg. #lorem(4) @einstein1905.

=== Aplikasi Web

#lorem(60)

Waktu tunggu rata-rata dihitung dengan @persamaan-tunggu.

$ overline(t) = 1 / n sum_(i=1)^n t_i $ <persamaan-tunggu>

== Penelitian Terdahulu

#figure(
  table(
    columns: 3,
    [*Peneliti*], [*Metode*], [*Hasil*],
    [Peneliti A], [Waterfall], [Aplikasi desktop],
    [Peneliti B], [Scrum], [Aplikasi web],
    [Peneliti C], [Prototipe], [Aplikasi seluler],
  ),
  caption: [Ringkasan penelitian terdahulu],
) <tabel-terdahulu>

@tabel-terdahulu merangkum #lorem(20)

= Metode <bab-metode>

#set-footer-text[Bab III Metode]

== Alur Sistem

#figure(
  {
    import "@preview/fletcher:0.5.8": diagram, edge, node, shapes
    diagram(
      node-stroke: 0.6pt,
      spacing: (2.5em, 1.6em),
      node((0, 0), [Mulai], shape: shapes.pill),
      edge("-|>"),
      node((0, 1), [Pilih ruang dan jam]),
      edge("-|>"),
      node((0, 2), [Ruang tersedia?], shape: shapes.diamond),
      edge("-|>", [Ya]),
      node((0, 3), [Pesan ruang]),
      edge("-|>"),
      node((0, 4), [Selesai], shape: shapes.pill),
      edge(
        (0, 2),
        (1, 2),
        (1, 1),
        (0, 1),
        "-|>",
        [Tidak],
        label-pos: 0.1,
        label-side: right,
      ),
    )
  },
  caption: [Alur peminjaman ruang],
) <gambar-alur>

@gambar-alur menunjukkan #lorem(30)

== Implementasi

#figure(
  zebraw(
    highlight-lines: (2,),
    ```python
    def pinjam(ruang, jam):
        if ruang.tersedia(jam):
            return ruang.pesan(jam)
        return None
    ```,
  ),
  caption: [Fungsi peminjaman ruang],
) <kode-pinjam>

@kode-pinjam memeriksa #lorem(20)

= Penutup

#set-footer-text(none)

== Kesimpulan

Seperti dirumuskan pada @bab-pendahuluan, #lorem(40) Hasil uji ada pada
@lampiran-uji.

== Saran

#lorem(40)

#appendix(title: [Hasil Pengujian], label: <lampiran-uji>)[
  #figure(
    table(
      columns: 3,
      [*No*], [*Skenario*], [*Hasil*],
      [1], [Pinjam ruang kosong], [Berhasil],
      [2], [Pinjam ruang terpakai], [Ditolak],
    ),
    caption: [Hasil uji fungsional],
  )
]

#appendix(title: [Dokumentasi Kegiatan])[
  #figure(
    rect(width: 6cm, height: 3cm, fill: luma(230)),
    caption: [Rapat kelompok],
  )
]
