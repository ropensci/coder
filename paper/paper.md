---
title: 'coder: An R package for code-based item classification and categorization'
tags:
  - R
  - epidemiology
  - statistics
  - Administrative data
authors:
  - name: Erik Bülow
    orcid: 0000-0002-9973-456X
    affiliation: "1, 2"
affiliations:
 - name: The Swedish Hip Arthroplasty Register, Registercentrum Västra Götaland, Gothenburg, Sweden
   index: 1
 - name: Department of orthopaedics, institute of clinical sciences, Sahlgrenska Academy, University of Gothenburg, Gothenburg, Sweden
   index: 2
date: 9 August 2018
bibliography: paper.bib
---

# Summary

The `coder` package lets researchers classify and categorize coded item data using prespecified classification schemes based on regular expressions. Default classification schemes are included for commonly used medical and clinical classifications. The package implemantation aim for high performance and the package can be used with large data sets.


# Medical coding and classifications

Registry based research and the use of real world evidence (RWE) and data (RWD) have gained popularity over the last years [@Sherman2016], both as an epidemiological research tool, and for monitoring post market safety and adverse events due to regulatory decisions. Data from administrative, clinical and medical registries are often coded based on standardized classifications for diagnostics, procedures/interventions, medications/medical devices and health status/functioning.

Codes and classifications are maintained and developed by several international bodies, such as The World Health Organization [(WHO)](https://www.who.int/classifications/), [SNOMED International](snomed.org), and the Nordic Medico-Statistical Committee [(NOMESCO)](http://nowbase.org/). 


# Challanges in applied research

Common classifications such as the International Classification of Diseases (ICD) or the Anatomical Therapeutic Chemical Classification System (ATC) entails thousands of codes which are hard to use and interpret in applied research. This is often solved by an abstraction layer combining individual codes into broader categories, sometimes further simplified by a single index value based on a weighted sum of individual categories [@Charlson1987; @Elixhauser1998; @Quan2005; @Sloan2003; @Pratt2018]. 
 
Large and long-standing national databases often contain millions of entries and span several Gigabytes (GB) in size. This leads to high computational burden and a time-consuming data managing process, a cumbersome but necessary prerequisite before any relevant analysis can be performed. There are several R-packages with a delibarate focus on comorbidity data coded by ICD and summarized by the Charlson or Elixhauser comorbidity indices ([icd](https://jackwasey.github.io/icd), [comorbidity](https://ellessenne.github.io/comorbidity/) [@Gasparini2018] and [medicalrisk](https://github.com/patrickmdnet/medicalrisk)). The `coder` package includes such capabilities as well, but takes a more general approach to deterministic item classification and categorization.


# The coder package

[coder](https://eribul.github.io/coder/) is an R package with a scope to combine items (i.e. patients) with generic code sets, and to classify and categorize such data based on generic classification schemes defined by regular expressions. It is easy to combine different classifications (such as multiple versions of ICD, ATC or NOMESCO codes), with different classification schemes (such as Charlson, Elixhauser, RxRisk V or for example local definitions of adverse events after total hip arthroplasty) and different weighted indices based on those classifications. The package includes default classification schemes for all those settings, as well as an infrastructure to implement and visualize custom classification schemes. Additional functions simplify identification of codes and events within limited time frames, such as comorbidity during one year before surgery or adverse events within 30 days after. `coder` can also be used in tandem with [decoder](https://cancercentrum.bitbucket.io/decoder/), a package facilitating interpretation of individual codes.

`coder` has been optimized for speed and large data sets using reference semantics from [data.table](https://rdatatable.gitlab.io/data.table/), matrix-based computations and code profiling. The prevalence of large datasets makes it difficult to use parallel computing however, since the limit of available random-access memory (RAM) often implies a more serious bottleneck, which limits the possibility to manifold data sets for multiple cores.

`coder` has been used in ongoing, as well as in previously published research [@Bulow2017; @Bulow2019; @Bulow2020; @Cnudde2017; @Cnudde2018a; @Berg2018; @Jawad2019; @Wojtowicz2019; @Hansson2020; @Nemes2018a].


# References
