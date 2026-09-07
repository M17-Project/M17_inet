$-- Pandoc/Typst template styled to match the main M17 spec (LaTeX book class,
$-- PT Serif 11pt, A4, 2.5cm margins, right-aligned title page with logo).
#set terms(hanging-indent: 1.5em)

#show figure.where(
  kind: table
): set figure.caption(position: top)

#show figure.where(
  kind: image
): set figure.caption(position: bottom)

$if(highlighting-definitions)$
// syntax highlighting functions from skylighting:
$highlighting-definitions$

$endif$
#let conf(
  title: none,
  subtitle: none,
  authors: (),
  version: none,
  date: none,
  lang: "en",
  region: "US",
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  font: ("PT Serif",),
  fontsize: 11pt,
  codefont: ("PT Mono",),
  sectionnumbering: "1.1.1",
  pagenumbering: "1",
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: none,
  )
  set text(lang: lang, region: region, font: font, size: fontsize)
  set par(justify: true)
  set heading(numbering: sectionnumbering)
  show raw: set text(font: codefont, size: 0.9 * fontsize)
  show raw.where(block: true): it => block(
    fill: rgb("#f2f2eb"),
    inset: 8pt,
    radius: 2pt,
    width: 100%,
    it,
  )

  // Body text starts on a fresh page after the table of contents.
  show outline: it => {
    it
    pagebreak(weak: true)
  }

  // Tables: full grid with generous row height, like the main spec's
  // \arraystretch{1.5} + nicematrix styling.
  set table(
    inset: (x: 8pt, y: 7pt),
    stroke: 0.5pt + black,
  )
  show table.cell.where(y: 0): strong

  // Level-1 headings behave like book-class chapters: new page, large type.
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1em)
    set text(size: 20.7pt)
    it
    v(0.7em)
  }
  show heading.where(level: 2): it => {
    set text(size: 14.4pt)
    block(above: 1.4em, below: 0.9em, it)
  }
  show heading.where(level: 3): it => {
    set text(size: 12pt)
    block(above: 1.3em, below: 0.8em, it)
  }

  // Title page, following the main spec's raggedleft layout.
  {
    set align(right)
    image("img/m17_logo_shadow.png", width: 70%)
    v(1.5em)
    text(size: 17.3pt)[#authors.map(a => a.name).join(", ")]
    v(16%)
    text(size: 20.7pt, weight: "bold")[#title]
    if subtitle != none {
      linebreak()
      text(size: 20.7pt, weight: "bold")[#subtitle]
    }
    v(1fr)
    if version != none {
      text(size: 14.4pt)[Version #version]
    }
    v(1fr)
    text[#date]
  }
  pagebreak()

  set page(numbering: pagenumbering)
  counter(page).update(1)

  doc
}

$if(smart)$
$else$
#set smartquote(enabled: false)

$endif$
$for(header-includes)$
$header-includes$

$endfor$
#show: doc => conf(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(author)$
  authors: (
$for(author)$
$if(author.name)$
    ( name: [$author.name$] ),
$else$
    ( name: [$author$] ),
$endif$
$endfor$
    ),
$endif$
$if(version)$
  version: [$version$],
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
$if(codefont)$
  codefont: ($for(codefont)$"$codefont$",$endfor$),
$endif$
$if(section-numbering)$
  sectionnumbering: "$section-numbering$",
$endif$
$if(page-numbering)$
  pagenumbering: "$page-numbering$",
$endif$
  doc,
)

$for(include-before)$
$include-before$

$endfor$
$if(toc)$
#outline(
  title: auto,
  depth: $toc-depth$
);
$endif$

$body$

$for(include-after)$

$include-after$
$endfor$
