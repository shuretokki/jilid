# Changelog

All notable changes to jilid are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-10-06

This release changes how you write front matter and appendices, and it changes some default
looks. See [Migrating from 0.1](https://github.com/shuretokki/jilid/blob/v0.2.0/README.md#migrating-from-01)
to update a document.

### Added

- `frontmatter(label:)` lets you refer to a front matter page with `@`. The reference shows the
  title and the page, such as "Abstrak (halaman ii)".
- `appendix(label:)` lets you refer to an appendix with `@`, such as "Lampiran 1".
- `cover.institution-order` sets the order of the university, faculty, department, program and
  year lines on the cover. A key that you leave out hides its line.
- `cover.institution-render` lets you draw the institution block yourself.
- `outlines.toc-indent` sets where titles start in DAFTAR ISI. By default, the chapter titles line
  up, and each sub-chapter starts under the title of its chapter. A length such as `1cm` moves each
  lower level by that length instead.
- `outlines.align-titles` lines up the titles in Daftar Gambar, Tabel, Kode and Lampiran, so
  "Gambar 4.9" and "Gambar 4.10" start their titles at the same place.
- `typography.url` sets the style of web links. Links use the code font by default.
- The editor hover shows a summary, every parameter and an example for each jilid function.
- The template is a short guided report. Each section says what to write there, and the template
  shows a citation, an equation, a flowchart, a table, code and two appendices.

### Changed

- `appendices[..]` is now `appendix(title: [..])[..]`, with one call for each appendix.
- `frontmatter` takes the page title as `title:`. It no longer takes `numbering`, `start-page` or
  `outlined`.
- A `=` heading inside `frontmatter` or `appendix` stops with an error. Use `title:` for the page
  title and `==` for the headings inside.
- Headings inside an appendix have no number.
- If you call `appendices` or give `frontmatter` a removed argument, jilid stops with an error that
  tells you what changed.
- `margin` is `"digital"` by default, with 1 inch on all sides. Use `margin: "print"` for the
  wider left margin.
- Lecturer names on the cover are plain by default.

### Fixed

- A `=` heading inside `frontmatter` no longer makes the first chapter BAB II.

## [0.1.0] - 2026-10-01

### Added

- First release: a cover, front matter, the lists of contents, figures, tables and code, chapters,
  a bibliography and appendices for reports, proposals and theses at Indonesian universities.

[Unreleased]: https://github.com/shuretokki/jilid/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/shuretokki/jilid/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/shuretokki/jilid/releases/tag/v0.1.0
