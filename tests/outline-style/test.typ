// outline styling: regular chapter rows and no leader.
#import "/lib.typ": *
#show: jilid.with(
  outlines: (h1: (weight: "regular"), leader: none),
)

= Pendahuluan

== Latar Belakang

#figure(rect(width: 3cm, height: 1cm), caption: [Gambar])

= Penutup

#appendices[
  = Dokumentasi
]
