// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let target = query(it.target, loc).first()
  if it.at("supplement", default: none) == none {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}



#let article(
  title: none,
  authors: none,
  date: none,
  abstract: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  if title != none {
    align(center)[#block(inset: 2em)[
      #text(weight: "bold", size: 1.5em)[#title]
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}
#show: doc => article(
  title: [The Analysis of Pluralistic Ignorance of Married Men in Saudi Arabia on Women Working Outside of Home \(WWOH) #footnote[Code and data are available at: https:\/\/github.com/YcartXin/Analysis-of-Men-in-Saudi-Arabia-on-WWOH];],
  authors: (
    ( name: [Tracy Yang],
      affiliation: [],
      email: [] ),
    ( name: [Alex Sun],
      affiliation: [],
      email: [] ),
    ),
  date: [February 13, 2024],
  abstract: [First sentence. Second sentence. Third sentence. Fourth sentence.],
  sectionnumbering: "1.1.a",
  toc: true,
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)


#pagebreak()
= Introduction
<introduction>
In the landscape marked by rapid socio-economic transformations, Saudi Arabia continues to grapple with the enduring issue of gender inequality, manifesting in various forms of discrimination and unbalanced treatments towards women. In spite of recent reforms targeted at enhancing women’s rights, such as allowing women to drive and easing guardianship laws, challenges continue to persist in employment opportunities, legal rights, and societal expectations. This system is deeply rooted in cultural norms and a conservative interpretation of Islamic law, which collectively hinder women’s participation in society and public life.

With the constantly changing political landscape of Saudi Arabia, it is essential to consider sentiment in regards to the increasing presence of women in society. While it is known that Saudi Arabia and many other middle-eastern countries fall behind progressive nations in terms of legal women rights, there is a void of information in regards to whether the social sentiment is changing. Bursztyn, Gonzalez, and Yanagizawa-Drott directly address this issue by investigating the opinions of married men in Saudi Arabia \(Bursztyn).

Pluralistic ignorance describes the misalignment between private and public beliefs \(). In the context of the paper by Bursztyn et.al. \(year), it illustrates the discrepancy between an individual’s private support for women working outside the home \(WWOH) and their belief of public opposition. The above authors’ findings suggest that the vast majority of married men aged 18-35 underestimate societal support for female employment, despite private beliefs that align more with progressive values. This gap between private attitudes and perceived social expectations highlights the need for interventions that accurately communicate societal beliefs to bridge the divide \(Bursztyn).

This paper will reproduce Bursztyn, Gonzalez, and Yanagizawa-Drott’s findings, while applying a demographic focused lens to establish if certain variables such as age or education have a bearing on support for WWOH. In particular, our paper will replicate the following three research claims:

- The vast majority of married men in Saudi Arabia privately support WWOH
- The married men massively underestimate the level of support from other men in their communities
- Correcting these beliefs about others’ feelings will affect the outcome of whether the married man’s wife work.

For this paper, our estimand is the difference between the married men’s guess on how many people in their survey group support WWOH and the actual percentage of people in their group that support WWOH. The remainder of this paper is structured as follows. We will first describe our data sources in @sec-data \(Data), followed by a description of the variables and methodologies utilized by the original paper in @sec-results \(Results). We will then conduct a reproduction of certain figures and results to verify the original paper’s findings in the same section. Afterwards, we will summarize our results when compared to the original paper. We will additionally conduct an in-depth examination of how various demographics affect the support for WWOH. Lastly, in @sec-discussion \(Discussion), we will discuss the findings from @sec-results \(Results) in context.

= Data
<sec-data>
== Data source and collection
<data-source-and-collection>
The data used in this analysis - Main Experiment of Saudi Arabia men on WWOH and their beliefs of others’ opinions - is sourced from the replication package provided by Bursztyn et.al \(year). The data was collected by the researchers in the original paper through an experiment and repeated surveys with a treatment group and a control group. This analysis will be carried out in #strong[R] #cite(<citeR>) using packages #strong[tidyverse] #cite(<tidyverse>);, #strong[knitr] #cite(<knitr>);, #strong[dplyr] #cite(<dplyr>);, #strong[ggplot2] #cite(<ggplot2>);, #strong[knitr] #cite(<knitr>);, #strong[here ] #cite(<here>);. Although the experiment claims to have only recruited men who are married, the data shows otherwise and thus some data points will be further removed from the analysis. The paper was published in the American Economic Review 2020, 110\(10) issue between pages 2997-3029 \(). The data was similarly uploaded at the same time and has not been updated since.

More specifically, the sampling for the experiment was conducted through a partnership between a local branch of an international survey company and Bursztyn et.al. They recruited 500 Saudi Arabia men between the ages of 18 and 35, living across Riyadh, Saudi Arabia \().

= Results
<sec-results>
In this section, we will replicate some of the graphs, tables, and findings in the original paper.

The data collected from the experiment can be introduced through summary statistics.

#block[
#block[
#figure(
align(center)[#table(
  columns: 7,
  align: (col, row) => (right,right,right,right,right,right,left,).at(col),
  inset: 6pt,
  [condition2], [Observations], [Age], [Children], [College\(%], [Employed\(%)], [group],
  [0],
  [229],
  [24.77729],
  [1.602620],
  [56.76856],
  [88.20961],
  [Control],
  [1],
  [239],
  [24.94142],
  [1.761506],
  [58.99582],
  [87.86611],
  [Treatment],
)]
)

Summary Statistics on Men Who Participated in the Main Experiment

]
#block[
#figure(
align(center)[#table(
  columns: 5,
  align: (col, row) => (right,right,right,right,right,).at(col),
  inset: 6pt,
  [Observations], [Age], [Children], [College], [Employed\(%)],
  [468],
  [24.86111],
  [1.683761],
  [57.90598],
  [88.03419],
)]
)

Summary Statistics on Men Who Participated in the Main Experiment

]
] <tbl-sum>
As seen in #strong[?\@tbl-sum] above, there are less than 500 data points present after removing single men as well as any empty data points used in the making of the summary statistics, contrary to the claims of Bursztyn et.al.

= Discussion
<sec-discussion>
== First discussion point
<sec-first-point>
If my paper were 10 pages, then should be be at least 2.5 pages. The discussion is a chance to show off what you know and what you learnt from all this.

== Second discussion point
<second-discussion-point>
== Third discussion point
<third-discussion-point>
== Weaknesses and next steps
<weaknesses-and-next-steps>
Weaknesses and next steps should also be included.

#pagebreak()
#block[
#heading(
level: 
1
, 
numbering: 
none
, 
[
Appendix
]
)
]
= Additional data details
<additional-data-details>
== Posterior predictive check
<posterior-predictive-check>
== Diagnostics
<diagnostics>
#pagebreak()



#bibliography("references.bib")

