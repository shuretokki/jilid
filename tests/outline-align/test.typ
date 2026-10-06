// titles in each list start at one place: BAB I to BAB X,
// Gambar 1.1 to 1.11, Lampiran 1 to 11 and a wrapped title.
#import "/lib.typ": *
#show: jilid.with(headings: (h1: (pagebreak: false)))

= Bab dengan judul yang sangat panjang sehingga baris judulnya terlipat ke baris berikutnya

#for i in range(1, 12) {
  figure(rect(width: 1cm, height: 0.5cm), caption: [Gambar ke-#i])
}

#for i in range(2, 11) [
  = Bab #i
]

#for i in range(1, 12) {
  appendix(title: [Lampiran ke-#i])[]
}
