#import "/lib.typ": *
#show: jilid.with(
  title: [Sentiment Analysis of App Reviews],
  kind: "thesis",
  cover: (
    kind: (style: "italic"),
    student-name: (style: "normal", underline: false, upper: true),
    id: (weight: "bold"),
  ),
  labels: (students: [By], appendix-short: ""),
  lang: "en",
  students: (
    (name: "Student Name", id: "10000000001"),
    (name: [Second *Author*], id: "10000000002"),
  ),
  program: "Informatics",
  faculty: "Engineering",
  department: "Electrical Engineering",
  university: "Example University",
  year: "2026",
  footer: (
    left: [Thesis],
    render: it => [
      #line(length: 100%, stroke: 0.5pt + luma(150))
      #v(0.2em)
      #grid(
        columns: (1fr, auto, 1fr),
        align: (left + bottom, center + bottom, right + bottom),
        text(size: 9pt, weight: "bold")[#it.left],
        [#it.number],
        text(size: 9pt)[Draft],
      )
    ],
  ),
  numbering: (
    back: "front",
    appendix: "A",
    appendix-prefix: false,
    position: "top",
  ),
  outlines: (depth: 4, toc-appendices: true),
  code: (zebraw: (lang: false), font: "DejaVu Sans Mono"),
  paper: "a5",
  margin: "digital",
)

#frontmatter(title: [Abstract], numbering: "I")[
  #lorem(40)
  $ e^(i pi) + 1 = 0 $
]

= Introduction

== Background

=== Detail

==== Deepest level

#lorem(300)

#figure(rect(width: 3cm, height: 1cm), caption: [Only figure])

= Method

```rust
fn main() {
    println!("hi");
}
```

#lorem(30)

#appendices[
  = First Appendix
  #figure(rect(width: 2cm, height: 1cm), caption: [Appendix figure]) <app-fig>
  $ a^2 + b^2 = c^2 $
  See @app-fig.
  #lorem(250)
]
