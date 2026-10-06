// Figure, table, code and equation numbers in each part:
// "1" in the front matter, "1.1" in chapters and "L1.1" in appendices.
// The numbers restart in each appendix.
// Figures in the front matter and in appendices stay out of the lists.
// Appendix titles are in capitals.
// With `align-titles: none`, each list title comes right after its number.
#import "/lib.typ": *
#show: jilid.with(
  include-cover: false,
  outlines: (toc: false, align-titles: none),
  headings: (appendix: (uppercase: true)),
)

#frontmatter(title: [Kata Pengantar])[
  #figure(rect(width: 2cm, height: 1cm), caption: [gambar depan]) <f-front>
  #figure(
    table(
      columns: 2,
      [a], [b],
    ),
    caption: [tabel depan],
  )
  $ a = b $ <e-front>
  lihat @f-front dan @e-front.
]

= Satu

#figure(rect(width: 2cm, height: 1cm), caption: [gambar satu]) <f-main>
#figure(
  table(
    columns: 2,
    [a], [b],
  ),
  caption: [tabel satu],
)
#figure(
  ```py
  x = 1
  ```,
  caption: [kode satu],
)
$ c = d $ <e-main>
lihat @f-main dan @e-main.

= Dua

#figure(rect(width: 2cm, height: 1cm), caption: [gambar dua])

#appendix(title: [Pertama])[
  #figure(rect(width: 2cm, height: 1cm), caption: [gambar lampiran satu]) <f-l1>
  #figure(
    table(
      columns: 2,
      [a], [b],
    ),
    caption: [tabel lampiran satu],
  )
  $ e = f $ <e-l1>
]

#appendix(title: [Kedua])[
  #figure(rect(width: 2cm, height: 1cm), caption: [gambar lampiran dua]) <f-l2>
  #figure(
    ```py
    y = 2
    ```,
    caption: [kode lampiran dua],
  )
  lihat @f-l1, @e-l1 dan @f-l2.
]
