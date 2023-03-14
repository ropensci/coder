---
output: github_document
---

# coder <img src="man/figures/logo.png" align="right"/>

[![R build status](https://github.com/ropensci/coder/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/coder/actions) 
[![codecov](https://codecov.io/gh/ropensci/coder/branch/master/graph/badge.svg)](https://app.codecov.io/gh/ropensci/coder) 
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![DOI](https://zenodo.org/badge/65975808.svg)](https://zenodo.org/badge/latestdoi/65975808) [![status](https://joss.theoj.org/papers/10.21105/joss.02916/status.svg)](https://joss.theoj.org/papers/10.21105/joss.02916)
[![CRAN status](https://www.r-pkg.org/badges/version/coder)](https://CRAN.R-project.org/package=coder)
![CRAN downloads](http://cranlogs.r-pkg.org/badges/grand-total/coder)

<!-- README.md is generated from README.Rmd. Please edit that file -->



## Aim of the package

The goal of `{coder}` is to classify items from one dataset, using codes from a secondary source with classification schemes based on regular expressions and weighted indices.

## Installation

You can install the released version of coder from [CRAN](https://CRAN.R-project.org) with:

``` r
# install.packages("coder")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("eribul/coder")
```

## Typical use case

-   Determining comorbidities before clinical trials
-   Discovering adverse events after surgery

**Patient data:** The initial rationale for the package was to classify patient data based on medical coding. A typical use case would consider patients from a medical/administrative data base, as identified by some patient id and possibly with some associated date of interest (date of diagnoses/treatment/intervention/hospitalization/rehabilitation). This data source could be for example an administrative hospital register or a national quality register.

**Codify:** The primary source could then be linked to a secondary (possibly larger) data base including the same patients with corresponding id:s and some coded patient data. This could be a national patient register with medical codes from the International Classification of Diseases *(ICD)* with corresponding dates of hospital visits/admission/discharge, or a medical prescription register with codes from the Anatomic Therapeutic Chemical *(ATC)* classification system with dates of medical prescription/dispatch/usage. A time window could be specified relating the date of the primary source (i. e. the date of a primary total hip arthroplasty; THA), to dates from the secondary source (i.e. the date of a medical prescription). ATC codes associated with medical prescriptions during one year prior to THA, could thus be identified and used as a measure of comorbidity. Another time window of 90 days after THA, might instead be used to identify adverse events after surgery.

**Classify:** To work with medical/chemical codes directly might be cumbersome, since those classifications tend to be massive and therefore hard to interpret. It is thus common to use data aggregation as proposed by some classification or combined index from the literature. This could be the *Charlson* or *Elixhauser* comorbidity indices based on ICD-codes, or the *RxRisk V* classification based on ATC-codes. Each of those tools appear with different code versions (ICD-8, ICD-9, ICD-9-CM, ICD-10, ICD-10-CA, ICD-10-SE, ICD-10-CM et cetera) and with different codes recognized as relevant comorbidities (the Charlson index proposed by Charlson et al, Deyo et al, Romano et al. Quan et al. et cetera). Using a third object (in addition to the primary and secondary patient data sets) helps to formalize and structure the use of such classifications. This is implemented in the `coder` package by `classcodes` objects based on regular expressions (often with several alternative versions). Those `classcodes` objects could be prepared by the user, although a number of default `classcodes` are also included in the package (table below).

**Index:** Now, instead of working with tens of thousands of individual ICD-codes, each patient might be recognized to have none or some familiar comorbidity such as hypertension, cancer or dementia. This granularity might be too fine-grained still, wherefore an even simpler index score might be searched for. Such scores/indices/weighted sums have been proposed as well and exist in many versions for each of the standard classifications. Some are simple counts, some are weighted sums, and some accounts for some inherited hierarchy (such that ICD-codes for diabetes with and without complications might be recognized in the same patient, although the un-complicated version might be masked by the complicated version in the index).

**Conditions:** Some further complexity might appear if some codes are only supposed to be recognized based on certain conditions. Patients with THA for example might have an adverse event after surgery if a certain ICD-code is recorded as the main diagnose at a later hospital visit, although the same code could be ignored if recorded only as a secondary diagnosis.

**To summarize:** The coder package takes three objects: (1) a data frame/table/tibble with id and possible dates from a primary source; (2) coded data from a secondary source with the same id and possibly different dates and; (3) a `classcodes` object, either a default one from the package, or as specified by the user. The outcome is then: (i) codes associated with each element from (1) identified from (2), possibly limited to a relevant time window; (ii) a broader categorization of the relevant codes as prescribed by (3), and; (iii) a summarized index score based on the relevant categories from (3).

(i-iii) corresponds to the output from functions `codify()`, `classify()` and `index()`, which could be chained explicitly as `codify() %>% classify() %>% index()`, or implicitly by the `categorize()` function.

## Usage

Assume we have some patients with surgery at specified dates:


```r
library(coder)
ex_people
#> # A tibble: 100 × 2
#>    name              surgery   
#>    <chr>             <date>    
#>  1 Chen, Trevor      2023-02-28
#>  2 Graves, Acineth   2022-11-20
#>  3 Trujillo, Yanelly 2022-11-07
#>  4 Simpson, Kenneth  2023-02-09
#>  5 Chin, Nelson      2023-01-23
#>  6 Le, Christina     2022-08-27
#>  7 Kang, Xuan        2022-11-29
#>  8 Shuemaker, Lauren 2022-08-28
#>  9 Boucher, Teresa   2023-02-03
#> 10 Le, Soraiya       2023-01-08
#> # … with 90 more rows
```

Those patients (among others) were also recorded in a national patient register with date of hospital admissions and diagnoses codes coded by the International Classification of Diseases (ICD) version 10:


```r
ex_icd10
#> # A tibble: 2,376 × 4
#>    name                 admission  icd10 hdia 
#>    <chr>                <date>     <chr> <lgl>
#>  1 Tran, Kenneth        2022-09-11 S134A FALSE
#>  2 Tran, Kenneth        2023-02-25 W3319 FALSE
#>  3 Tran, Kenneth        2023-02-04 Y0262 TRUE 
#>  4 Tran, Kenneth        2022-12-28 X0488 FALSE
#>  5 Sommerville, Dominic 2023-02-16 V8104 FALSE
#>  6 Sommerville, Dominic 2022-09-27 B853  FALSE
#>  7 Sommerville, Dominic 2023-02-11 Q174  FALSE
#>  8 Sommerville, Dominic 2022-10-02 A227  FALSE
#>  9 Sommerville, Dominic 2023-02-06 H702  FALSE
#> 10 Sommerville, Dominic 2022-05-31 X6051 TRUE 
#> # … with 2,366 more rows
```

Using those two data sets, as well as a classification scheme (`classcodes` object; see below), we can easily identify all Charlson comorbidities for each patient:


```r
ch <- 
  categorize(
    ex_people,                  # patients of interest 
    codedata = ex_icd10,        # Medical codes from national patient register
    cc = "charlson",            # Calculate Charlson comorbidity
    id = "name", code = "icd10" # Specify column names
  )
#> Error in UseMethod("categorize"): no applicable method for 'categorize' applied to an object of class "c('tbl_df', 'tbl', 'data.frame')"

ch
#> Error in eval(expr, envir, enclos): object 'ch' not found
```

How many patients were diagnosed with malignancy?


```r
sum(ch$malignancy)
#> Error in eval(expr, envir, enclos): object 'ch' not found
```

What is the distribution of the combined comorbidity index for each patient?


```r
barplot(table(ch$charlson))
#> Error in table(ch$charlson): object 'ch' not found
```

There are many versions of the Charlson comorbidity index, which might be controlled by the `index` argument. We might also be interested only in diagnoses from 90 days before surgery as specified with an argument list `codify_args`as passed to `codify()`:


```r
ch <- 
  categorize(
    ex_people, codedata = ex_icd10, cc = "charlson", id = "name", code = "icd10",
    
    # Additional arguments
    index       = c("quan_original", "quan_updated"), # Indices
    codify_args = list(
      date      = "surgery",   # Name of column with index dates
      code_date = "admission", # Name of column with code dates
      days      = c(-90, -1)   # Time window
    )
  )
#> Error in UseMethod("categorize"): no applicable method for 'categorize' applied to an object of class "c('tbl_df', 'tbl', 'data.frame')"
```

Number of malignancies during this period?


```r
sum(ch$malignancy, na.rm = TRUE)
#> Error in eval(expr, envir, enclos): object 'ch' not found
```

Distribution of the index as proposed by Quan et al 2011 during the 90 day period:


```r
barplot(table(ch$quan_updated))
#> Error in table(ch$quan_updated): object 'ch' not found
```

## Classification schemes

Classification schemes (`classcodes` objects, see `vignette("classcodes")`) are based on regular expressions for computational speed (see `vignette("Interpret_regular_expressions")`), but their content can be summarized and visualized for clarity. Arbitrary `classcodes` objects can also be specified by the user.

The package includes default `classcodes` for medical patient data based on the international classification of diseases version 8, 9 and 10 (ICD-8/9/10), as well as the Anatomical Therapeutic Chemical Classification System (ATC) for medical prescription data.

Default `classcades` are listed in the table. Each classification (classcodes column) can be based on several code systems (regex column) and have several alternative weighted indices (indices column). Those might be combined freely.


```r
coder::all_classcodes()
#> Error: 'all_classcodes' is not an exported object from 'namespace:coder'
```

# Relation to other packages

`coder` uses `data.table` as a backend to increase computational speed for large datasets. There are some R packages with a narrow focus on Charlson and Elixhauser co-morbidity based on ICD-codes ([icd](https://CRAN.R-project.org/package=icd), [comorbidity](https://CRAN.R-project.org/package=comorbidity), [medicalrisk](https://CRAN.R-project.org/package=medicalrisk), [comorbidities.icd10](https://github.com/gforge/comorbidities.icd10), [icdcoder](https://github.com/wtcooper/icdcoder)). The `coder` package includes similar functionalities but has a wider scope.

# Code of conduct

Please note that this package is released with a [Contributor Code of Conduct](https://ropensci.org/code-of-conduct/). By contributing to this project, you agree to abide by its terms.
