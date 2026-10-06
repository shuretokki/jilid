// outline styling: regular chapter rows, no leader, one number column for all lists.
#import "/lib.typ": *
#show: jilid.with(
  outlines: (h1: (weight: "regular"), leader: none, align-numbers: "all"),
)

= Pendahuluan

== Latar Belakang

#figure(rect(width: 3cm, height: 1cm), caption: [Gambar])

= Penutup

#appendix(title: [Dokumentasi])[]
