---
title: "coder"
output: github_document
---

[![R build status](https://github.com/eribul/coder/workflows/R-CMD-check/badge.svg)](https://github.com/eribul/coder/actions)
[![codecov](https://codecov.io/gh/eribul/coder/branch/master/graph/badge.svg)](https://codecov.io/gh/eribul/coder)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)


<!-- README.md is generated from README.Rmd. Please edit that file --> 



## Aim of the package

The goal of `coder` is to classify items from one dataset, using codes from a secondary source with classification schemes based on regular expressions and weighted indices. 


## Typical use case

**Patient data:** The initial rationale for the package was to classify patient data based on medical coding. A typical use case would consider patients from a medical/administrative data base, as identified by some patient id and possibly with some associated date of interest (date of diagnoses/treatment/intervention/hospitalization/rehabilitation). This data source could be for example an administrative hospital register or a national quality register. 

**Codify:** This primary source could then be linked to a secondary (possibly larger) data base including the same patients with corresponding id:s and some coded patient data. This could be a national patient register with medical codes from the International Classification of Diseases _(ICD)_ with corresponding dates of hospital visits/admission/discharge, or a medical prescription register with codes from the Anatomic Therapeutic Chemical _(ATC)_ classification system with dates of medical prescription/dispatch/usage. A time window could be specified relating the date of the primary source (i. e. the date of a primary total hip arthroplasty; THA), to dates from the secondary source (i.e. the date of a medical prescription). ATC codes associated with medical prescriptions during one year prior to THA, could thus be identified and used as a measure of comorbidity. Another time window of 90 days after THA, might instead be used to identify adverse events after surgery. 

**Classify:** To work with medical/chemical codes directly might be cumbersome, since those classifications tend to be massive and therefore hard to interpret. It is thus common to use data aggregation as proposed by some classification or combined index from the literature. This could be the _Charlson_ or _Elixhauser_ comorbidity indices based on ICD-codes, or the _RxRisk V_ classification based on ATC-codes. Each of those tools appear with different code versions (ICD-8, ICD-9, ICD-9-CM, ICD-10, ICD-10-CA, ICD-10-SE, ICD-10-CM et cetera) and with different codes recognized as relevant comorbidities (the Charlson index proposed by Charlson et al, Deyo et al, Romano et al. Quan et al. et cetera). Using a third object (in addition to the primary and secondary patient data bases) helps to formalize and structure the use of such classifications. This is implemented in the `coder` package by `classcodes` objects based on regular expressions (often with several alternative versions). Those `classcodes` objects could be prepared by the user, although a number of default `classcodes` are also included in the package (table below).

**Index: ** Now, instead of working with tens of thousands of individual ICD-codes, each patient might be recognized to have none or some familiar comorbidity such as hypertension, cancer or dementia. This granularity might be too fine-grained still, wherefore an even simpler index score might be searched for. Such scores/indices/weighted sums have been proposed as well and exist in many versions for each of the standard classifications. Some are simple counts, some are weighted sums, and some accounts for some inherited hierarchy (such that ICD-codes for diabetes with and without complications might be recognized in the same patient, although the un-complicated version might be masked by the complicated version in the index).

**Conditions:** Some further complexity might appear if some codes are only supposed to be recognized based on certain conditions. Patients with THA for example might have an adverse event after surgery if a certain ICD-code is recorded as the main diagnose at a later hospital visit, although the same could could be ignored if recorded only as a secondary diagnosis.

**To summarize:** The coder package takes three objects: (1) a data frame/table/tibble with id and possible dates from a primary source; (2) coded data from a secondary source with the same id:s and possibly different dates and; (3) a `classcodes` object, either a default one from the package, or as specified by the user. The outcome is then: (i) codes associated with each element from (1) identified from (2), possibly limited to a relevant time window; (ii) a broader categorization of the relevant codes as prescribed by (3), and; (iii) a summarized index score based on the relevant categories frmo (3). 


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

Assume we have some patients with corresponding dates of interest (i.e. dates of  total hip arthroplasty; THA):

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
We also have some external medical data: ICD-10-codes (code) recorded at previous hospital visits (code date), some of them are main diagnosis and some secondary (hdia):


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

Using those two sources, as well as a classification scheme (`classcodes` object; see below), we can easily identify all Charlson co-morbidities during one year prior to the event of interest. 


```r
ch <- 
  categorize(
    
    # Relevant patients from a national quality register
    data        = head(ex_people), 
    
    # Corresponding medical data from the national patient register
    codedata    = ex_icd10, 
    
    # Estimate comorbidity based on the Charlson comorbidity index
    cc          = "charlson",
    
    # Patient names used as id
    id          = "name",
    
    # Calculate two versions of combined index values
    index       = c("quan_original", "quan_updated"),
    
    # We only consider ICD-10-codes recorded within one year prior to THA
    codify_args = list(date = "event", days = c(-365, -1))
  )
#> Classification based on: regex_icd10
```

The result is a dataset with columns for each recognized comorbidity and (optional) each weighted index as displayed here for the interest of space (`quan_original` as proposed by Charlson et al. in 1987 and the `quan_updated` from Quan et al. in 2011). Most of the patients are healthy with an index score of 0. Some patients had no recorded hospital visits during the year preceding THA. They receive `NA` scores, which could later be substituted with 0. 


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
