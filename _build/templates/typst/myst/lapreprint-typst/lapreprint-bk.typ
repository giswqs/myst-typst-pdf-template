#import "frontmatter.typ": orcidLogo, loadFrontmatter

#let template(
  // The paper's title.
  title: "Paper Title",
  subtitle: none,

  // An array of authors. For each author you can specify a name, orcid, and affiliations.
  // affiliations should be content, e.g. "1", which is shown in superscript and should match the affiliations list.
  // Everything but but the name is optional.
  authors: (),
  // This is the affiliations list. Include an id and `name` in each affiliation. These are shown below the authors.
  affiliations: (),
  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,
  // The short-title is shown in the running header
  short-title: none,
  // The short-citation is shown in the running header, if set to auto it will show the author(s) and the year in APA format.
  short-citation: auto,
  // The venue is show in the footer
  venue: none,
  // An image path that is shown in the top right of the page. Can also be content.
  logo: none,
  // A DOI link, shown in the header on the first page. Should be just the DOI, e.g. `10.10123/123456` ,not a URL
  doi: none,
  heading-numbering: "1.1.1",
  // Show an Open Access badge on the first page, and support open science, default is true, because that is what the default should be.
  open-access: false,
  // A list of keywords to display after the abstract
  keywords: (),
  // The "kind" of the content, e.g. "Original Research", this is shown as the title of the margin content on the first page.
  kind: none,
  // Content to put on the margin of the first page
  // Should be a list of dicts with `title` and `content`
  margin: (),
  paper-size: "us-letter",
  // A color for the theme of the document
  theme: blue.darken(30%),
  // Date published, for example, when you publish your preprint to an archive server.
  // To hide the date, set this to `none`. You can also supply a list of dicts with `title` and `date`.
  date: datetime.today(),
  // Feel free to change this, the font applies to the whole document
  font-face: none,
  // The path to a bibliography file if you want to cite some external works.
  bibliography-file: none,
  bibliography-style: "apa",
  // The paper's content.
  body
) = {

  let spacer = text(fill: gray)[#h(8pt) | #h(8pt)]

  let dates;
  if (type(date) == datetime) {
    dates = ((title: "Submitted", date: date),)
  } else if (type(date) == dictionary) {
    dates = (date,)
  } else {
    dates = date
  }
  date = dates.at(0).date

  // Create a short-citation, e.g. Cockett et al., 2023
  let year = if (date != none) { ", " + date.display("[year]") }
  if (short-citation == auto and authors.len() == 1) {
    short-citation = authors.at(0).name.split(" ").last() + year
  } else if (short-citation == auto and authors.len() == 2) {
    short-citation = authors.at(0).name.split(" ").last() + " & " + authors.at(1).name.split(" ").last() + year
  } else if (short-citation == auto and authors.len() > 2) {
    short-citation = authors.at(0).name.split(" ").last() + " " + emph("et al.") + year
  } else if (short-citation == auto) {
    short-citation = none
  }

  // Set document metadata.
  set document(title: title, author: authors.map(author => author.name))

  show link: it => [#text(fill: theme)[#it]]
  show ref: it => [#text(fill: theme)[#it]]

  set page(
    paper-size,
    margin: (left: 25%),
    header: context {
      let loc = here()
      if(loc.page() == 1) {
        let headers = (
          if (open-access) {smallcaps[Open Access]},
          if (doi != none) { link("https://doi.org/" + doi, "https://doi.org/" + doi)}
        )
        return align(left, text(size: 8pt, fill: gray, headers.filter(header => header != none).join(spacer)))
      } else {
        return align(right, text(size: 8pt, fill: gray.darken(50%),
          (short-title, short-citation).join(spacer)
        ))
      }
    },
    footer: block(
      width: 100%,
      stroke: (top: 1pt + gray),
      inset: (top: 8pt, right: 2pt),
      context [
        #grid(columns: (75%, 25%),
          align(left, text(size: 9pt, fill: gray.darken(50%),
              (
                if(venue != none) {emph(venue)},
                if(date != none) {date.display("[month repr:long] [day], [year]")}
              ).filter(t => t != none).join(spacer)
          )),
          align(right)[
            #text(
              size: 9pt, fill: gray.darken(50%)
            )[
              #counter(page).display() of #counter(page).final().first()
            ]
          ]
        )
      ]
    )
  )

  // Set the body font.
  if (font-face != none) {
    set text(font: font-face, size: 10pt)
  } else {
    set text(size: 10pt)
  }
  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 1em)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: heading-numbering)
  show heading: it => context {
    let loc = here()
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    set text(10pt, weight: 400)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      // We don't want to number of the acknowledgment section.
      #let is-ack = it.body in ([Acknowledgment], [Acknowledgement])
      // #set align(center)
      #set text(if is-ack { 10pt } else { 12pt })
      #show: smallcaps
      #v(20pt, weak: true)
      #if it.numbering != none and not is-ack {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
      #v(13.75pt, weak: true)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #set par(first-line-indent: 0pt)
      #set text(style: "italic")
      #v(10pt, weak: true)
      #if it.numbering != none {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
      #v(10pt, weak: true)
    ] else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering(heading-numbering, ..levels)
        [. ]
      }
      _#(it.body):_
    ]
  }


  if (logo != none) {
    place(
      top,
      dx: -33%,
      float: false,
      box(
        width: 27%,
        {
          if (type(logo) == content) {
            logo
          } else {
            image(logo, width: 100%)
          }
        },
      ),
    )
  }


  // Title and subtitle
  box(inset: (bottom: 2pt), width: 100%, text(17pt, weight: "bold", fill: theme, title))
  if subtitle != none {
    parbreak()
    box(width: 100%, text(14pt, fill: gray.darken(30%), subtitle))
  }
  // Authors and affiliations
  if authors.len() > 0 {
    box(inset: (y: 10pt), {
      authors.map(author => {
        text(11pt, weight: "semibold", author.name)
        h(1pt)
        if "affiliations" in author {
          super(author.affiliations)
        }
        if "orcid" in author {
          orcidLogo(orcid: author.orcid)
        }
      }).join(", ", last: ", and ")
    })
  }
  if affiliations.len() > 0 {
    box(inset: (bottom: 10pt), {
      affiliations.map(affiliation => {
        super(affiliation.id)
        h(1pt)
        affiliation.name
      }).join(", ")
    })
  }


  place(
    left + bottom,
    dx: -33%,
    dy: -10pt,
    box(width: 27%, {
      if (kind != none) {
        show par: set par(spacing: 0em)
        text(11pt, fill: theme, weight: "semibold", smallcaps(kind))
        parbreak()
      }
      if (dates != none) {
        let formatted-dates

        grid(columns: (40%, 60%), gutter: 7pt,
          ..dates.zip(range(dates.len())).map((formatted-dates) => {
            let d = formatted-dates.at(0);
            let i = formatted-dates.at(1);
            let weight = "light"
            if (i == 0) {
              weight = "bold"
            }
            return (
              text(size: 7pt, fill: theme, weight: weight, d.title),
              text(size: 7pt, d.date.display("[month repr:short] [day], [year]"))
            )
          }).flatten()
        )
      }
      v(2em)
      grid(columns: 1, gutter: 2em, ..margin.map(side => {
        text(size: 7pt, {
          if ("title" in side) {
            text(fill: theme, weight: "bold", side.title)
            [\ ]
          }
          set enum(indent: 0.1em, body-indent: 0.25em)
          set list(indent: 0.1em, body-indent: 0.25em)
          side.content
        })
      }))
    }),
  )


  let abstracts
  if (type(abstract) == content or type(abstract) == str) {
    abstracts = ((title: "Abstract", content: abstract),)
  } else {
    abstracts = abstract
  }

if (abstracts != none and abstracts.len() > 0) {
    box(inset: (top: 16pt, bottom: 16pt), width: 100%, stroke: (top: 1pt + gray, bottom: 1pt + gray), {
      abstracts.map(abs => {
        set par(justify: true)
        text(fill: theme, weight: "semibold", size: 9pt, abs.title)
        parbreak()
        abs.content
      }).join(parbreak())
    })
  }
  if (keywords.len() > 0) {
    text(size: 9pt, {
      text(fill: theme, weight: "semibold", "Keywords")
      h(8pt)
      keywords.join(", ")
    })
  }
  v(10pt)

  show par: set par(spacing: 1.5em)

  // Display the paper's contents.
  body

  if (bibliography-file != none) {
    show bibliography: set text(8pt)
    bibliography(bibliography-file, title: text(10pt, "References"), style: bibliography-style)
  }
}
