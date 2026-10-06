// Chapter rows in regular weight, without a leader.
// `toc-indent: 0cm` lines up the chapter titles and puts the rows below at the left.
// `align-titles: "shared"` gives Daftar Gambar and Daftar Lampiran one place for titles.
#import "/lib.typ": *
#show: jilid.with(
  outlines: (
    h1: (weight: "regular"),
    leader: none,
    align-titles: "shared",
    toc-indent: 0cm,
  ),
)

= Pendahuluan

== Latar Belakang

#figure(rect(width: 3cm, height: 1cm), caption: [Gambar])

= Penutup

#appendix(title: [Dokumentasi])[]
