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

## Medical coding and classifications

Registry based research and the use of real world evidence (RWE) and data (RWD) have gained popularity over the last years [@Sherman2016], both as an epidemiological research tool, but also for monitoring post market safety and adverse events due to regulatory decisions. Data from routinely used registries are often coded based on standardized classifications. This includes, but is not limited to, codes of diagnostics, procedures/interventions, medications/medical devices and health status/functioning. The World Health Organization (WHO) develops and coordinates some well-used classifications within their [family of international classifications](https://www.who.int/classifications/), so does The International Health Terminology Standards Development Organisation (IHTSDO), trading as [SNOMED International](snomed.org). National and regional classifications exist as well, for example medical and surgical procedure codes from the Nordic Medico-Statistical Committee [(NOMESCO)](http://nowbase.org/). 


## Challanges in applied research

Common classifications such as the International Classification of Diseases (ICD) or the Anatomical Therapeutic Chemical Classification System (ATC) entails thousands of codes which are hard to use and interpret in applied research. This is often solved by an abstraction layer combining individual codes into broader categories, sometimes further simplified by a single index value based on a weighted sum of individual categories [@Charlson1987; @Elixhauser1998; @Quan2005; @Sloan2003; @Pratt2018]. 
 
Nevertheless, large long-standing national databases can contain millions of entries. This leads to high computational burden and a potentially slow data managing process as a cumbersome but necessary prerequisite before any relevant analysis can be performed. There are several R-packages with a delibarate focus on comorbidity data coded by ICD and summarized by the Charlson or Elixhauser comorbidity indices: [icd](https://jackwasey.github.io/icd), [comorbidity](https://ellessenne.github.io/comorbidity/) [@Gasparini2018] and [medicalrisk](https://github.com/patrickmdnet/medicalrisk). The `coder` package includes such capabilities as well, but takes a more general approach to deterministic item classification and categorization.


## The ´coder´ package

[coder](https://eribul.github.io/coder/) is an R package with the scope to combine items (i.e. patients) with generic code sets, and to classify and categorize such data based on generic classification schemes defined by regular expressions. It is easy to combine different classifications (such as multiple versions of ICD, ATC or NOMESCO codes), with different classification schemes (such as Charlson, Elixhauser, RxRisk V or for example local definitions of adverse events after total hip arthroplasty) and different weighted indices based on those classifications. The package includes default "classcodes" objects for all those settings, as well as an infrastructure to implement and visualize custom classification schemes. It is recommended to use `coder` in tandem with [decoder](https://cancercentrum.bitbucket.io/decoder/), a package for interpretation of individual codes.

`coder` has been optimized for speed and large data sets using reference semantics from [data.table](https://rdatatable.gitlab.io/data.table/), matrix-based computations and code profiling. The prevalence of large datasets makes it difficult to use parallel computing however, since the limit of available random-access memory (RAM) often implies a more serious bottleneck, which limits the possibility to multiply data sets for multiple cores. 

`coder` has been used in ongoing, as well as previously published research [@Bulow2017; @Bulow2019; @Bulow2020; @Cnudde2017; @Cnudde2018a; @Berg2018; @Jawad2019; @Wojtowicz2019; @Hansson2020; @Nemes2018a].


# References
