---
title: "coder"
output: github_document
---

[![R build status](https://github.com/eribul/coder/workflows/R-CMD-check/badge.svg)](https://github.com/eribul/coder/actions)
[![codecov](https://codecov.io/gh/eribul/coder/branch/master/graph/badge.svg)](https://codecov.io/gh/eribul/coder)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)


<!-- README.md is generated from README.Rmd. Please edit that file --> 



The goal of `coder` is to classify items from one dataset, using codes from a secondary source with classification schemes based on regular expressions and weighted indices. Default classification schemes (classcodes objects) are focused on patients classified by diagnoses, comorbidities, adverse events and medications.
 
## Installation 

You can (soon) install the released version of coder from [CRAN](https://CRAN.R-project.org) with:

``` r
# install.packages("coder") # Not yet!
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("eribul/coder")
```

## Usage

Assume we have some patients with corresponding dates of interest:

```r
library(coder)
knitr::kable(head(ex_people))
```



|name                    |event      |
|:-----------------------|:----------|
|Miller, Von Buddenbrock |2019-10-15 |
|Enriquez, Anthony       |2020-03-28 |
|al-Dib, Farhaan         |2020-05-24 |
|Martinez, Alison        |2020-02-29 |
|el-Masri, Junaid        |2019-12-18 |
|Sam, Niki               |2020-06-05 |
We also have some external medical data (ICD-10-codes recorded at previous hospital):


```r
knitr::kable(head(ex_icd10))
```



|id                 |code_date  |code    |hdia  |
|:------------------|:----------|:-------|:-----|
|Aguilera, Brandon  |2019-10-29 |O350XX9 |TRUE  |
|Aguilera, Brandon  |2020-01-23 |S55101A |TRUE  |
|Aguilera, Brandon  |2020-02-23 |A4181   |TRUE  |
|Alexander, Bethany |2019-07-09 |S62126K |FALSE |
|Alexander, Bethany |2019-08-13 |I70718  |FALSE |
|Alexander, Bethany |2019-12-18 |O368124 |FALSE |

Using those two sources, as well as a classification scheme (see below), we can easily identify all Charlson co-morbidities during one year prior to the event of interest. 


```r
ch <- 
  categorize(
    head(ex_people), ex_icd10, "charlson",
    id = "name",
    index = c("quan_original", "quan_updated"),
    codify_args = list(date = "event", days = c(-365, -1))
  )
#> Classification based on: regex_icd10
```

The result is a dataset with columns for each comorbidity and (optional) each weighted index (quan_original and quan_updated):


```r
knitr::kable(
  dplyr::select(ch, name, quan_original, quan_updated) 
)
```



|name                    | quan_original| quan_updated|
|:-----------------------|-------------:|------------:|
|Enriquez, Anthony       |             0|            0|
|Martinez, Alison        |             0|            0|
|Miller, Von Buddenbrock |            NA|           NA|
|Sam, Niki               |             1|            0|
|al-Dib, Farhaan         |             0|            0|
|el-Masri, Junaid        |             0|            0|



## Classification schemes

Classification schemes (`classcodes` objects) are based on regular expressions for computational speed, but their content can be summarized and visualized for clarity.  Arbitrary `classcodes` objects can also be specified by the user. 

### Default classcodes

The package includes default `classcodes` for medical patient data based on the international classification of diseases version 8, 9 and 10 (ICD-8/9/10), as well as the Anatomical Therapeutic Chemical Classification System (ATC) for medical prescription data.

Default `classcades` are listed in the table. Each classification (classcodes column) can be based on several code systems (regex column) and have several alternative weighted indices (indices column). Those might be combined freely. 


|classcodes    |regex                                                                              |indices                                                                                                        |
|:-------------|:----------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------------------------------|
|charlson      |icd10, icd9cm_deyo, icd9cm_enhanced, icd10_rcs, icd8_brusselaers, icd9_brusselaers |index_charlson, index_deyo_ramano, index_dhoore, index_ghali, index_quan_original, index_quan_updated          |
|cps           |icd10                                                                              |index_only_ordinary                                                                                            |
|elixhauser    |icd10, icd10_short, icd9cm, icd9cm_ahrqweb, icd9cm_enhanced                        |index_sum_all, index_sum_all_ahrq, index_walraven, index_sid29, index_sid30, index_ahrq_mort, index_ahrq_readm |
|hip_ae        |icd10, kva, icd10_fracture                                                         |                                                                                                               |
|hip_ae_hailer |icd10, kva                                                                         |                                                                                                               |
|knee_ae       |icd10, kva                                                                         |                                                                                                               |
|rxriskv       |pratt, caughey, garland                                                            |index_pratt, index_sum_all                                                                                     |

# Relation to other packages

`coder` uses `data.table` as a backend to increase computational speed for large datasets. There are some R packages with a narrow focus on Charlson and Elixhauser co-morbidity based on ICD-codes ([icd ](https://CRAN.R-project.org/package=icd), [comorbidity](https://CRAN.R-project.org/package=comorbidity), [medicalrisk ](https://CRAN.R-project.org/package=medicalrisk), [comorbidities.icd10 ](https://github.com/gforge/comorbidities.icd10), [icdcoder](https://github.com/wtcooper/icdcoder)). The `coder` package includes similar functionalities but has a wider scope. 


# Contribution

Contributions to this package are welcome. The preferred method of contribution is through a github pull request. Feel free to contact me by creating an issue. Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.
