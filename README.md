coder
================

[![R build
status](https://github.com/eribul/coder/workflows/R-CMD-check/badge.svg)](https://github.com/eribul/coder/actions)
[![codecov](https://codecov.io/gh/eribul/coder/branch/master/graph/badge.svg)](https://codecov.io/gh/eribul/coder)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

<!-- README.md is generated from README.Rmd. Please edit that file -->

## Aim of the package

The goal of `coder` is to classify items from one dataset, using codes
from a secondary source with classification schemes based on regular
expressions and weighted indices.

## Installation

You can (soon) install the released version of coder from
[CRAN](https://CRAN.R-project.org) with:

``` r
# install.packages("coder") # Not yet!
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("eribul/coder")
```

## Typical use case

  - Determining comorbidities before clinical trials
  - Discovering adverse events after surgery

**Patient data:** The initial rationale for the package was to classify
patient data based on medical coding. A typical use case would consider
patients from a medical/administrative data base, as identified by some
patient id and possibly with some associated date of interest (date of
diagnoses/treatment/intervention/hospitalization/rehabilitation). This
data source could be for example an administrative hospital register or
a national quality register.

**Codify:** The primary source could then be linked to a secondary
(possibly larger) data base including the same patients with
corresponding id:s and some coded patient data. This could be a national
patient register with medical codes from the International
Classification of Diseases *(ICD)* with corresponding dates of hospital
visits/admission/discharge, or a medical prescription register with
codes from the Anatomic Therapeutic Chemical *(ATC)* classification
system with dates of medical prescription/dispatch/usage. A time window
could be specified relating the date of the primary source (i. e. the
date of a primary total hip arthroplasty; THA), to dates from the
secondary source (i.e. the date of a medical prescription). ATC codes
associated with medical prescriptions during one year prior to THA,
could thus be identified and used as a measure of comorbidity. Another
time window of 90 days after THA, might instead be used to identify
adverse events after surgery.

**Classify:** To work with medical/chemical codes directly might be
cumbersome, since those classifications tend to be massive and therefore
hard to interpret. It is thus common to use data aggregation as proposed
by some classification or combined index from the literature. This could
be the *Charlson* or *Elixhauser* comorbidity indices based on
ICD-codes, or the *RxRisk V* classification based on ATC-codes. Each of
those tools appear with different code versions (ICD-8, ICD-9, ICD-9-CM,
ICD-10, ICD-10-CA, ICD-10-SE, ICD-10-CM et cetera) and with different
codes recognized as relevant comorbidities (the Charlson index proposed
by Charlson et al, Deyo et al, Romano et al. Quan et al. et cetera).
Using a third object (in addition to the primary and secondary patient
data sets) helps to formalize and structure the use of such
classifications. This is implemented in the `coder` package by
`classcodes` objects based on regular expressions (often with several
alternative versions). Those `classcodes` objects could be prepared by
the user, although a number of default `classcodes` are also included in
the package (table below).

**Index:** Now, instead of working with tens of thousands of individual
ICD-codes, each patient might be recognized to have none or some
familiar comorbidity such as hypertension, cancer or dementia. This
granularity might be too fine-grained still, wherefore an even simpler
index score might be searched for. Such scores/indices/weighted sums
have been proposed as well and exist in many versions for each of the
standard classifications. Some are simple counts, some are weighted
sums, and some accounts for some inherited hierarchy (such that
ICD-codes for diabetes with and without complications might be
recognized in the same patient, although the un-complicated version
might be masked by the complicated version in the index).

**Conditions:** Some further complexity might appear if some codes are
only supposed to be recognized based on certain conditions. Patients
with THA for example might have an adverse event after surgery if a
certain ICD-code is recorded as the main diagnose at a later hospital
visit, although the same code could be ignored if recorded only as a
secondary diagnosis.

**To summarize:** The coder package takes three objects: (1) a data
frame/table/tibble with id and possible dates from a primary source; (2)
coded data from a secondary source with the same id and possibly
different dates and; (3) a `classcodes` object, either a default one
from the package, or as specified by the user. The outcome is then: (i)
codes associated with each element from (1) identified from (2),
possibly limited to a relevant time window; (ii) a broader
categorization of the relevant codes as prescribed by (3), and; (iii) a
summarized index score based on the relevant categories from (3).

(i-iii) corresponds to the output from functions `codify()`,
`classify()` and `index()`, which could be chained explicitly as
`codify() %>% classify() %>% index()`, or implicitly by the
`categorize()` function.

## Usage

Assume we have some patients with surgery at specified dates:

``` r
library(coder)
ex_people
#> # A tibble: 100 x 2
#>    name                    surgery   
#>    <chr>                   <date>    
#>  1 Miller, Von Buddenbrock 2019-12-04
#>  2 Enriquez, Anthony       2020-05-17
#>  3 al-Dib, Farhaan         2020-07-13
#>  4 Martinez, Alison        2020-04-19
#>  5 el-Masri, Junaid        2020-02-06
#>  6 Sam, Niki               2020-07-25
#>  7 Connors, Jaylyn         2019-12-10
#>  8 al-Ramadan, Hanoona     2020-02-25
#>  9 Orozco, Daniel          2019-12-21
#> 10 Mills, Henry            2020-03-05
#> # ... with 90 more rows
```

Those patietns (among others) were also recorded in a national patient
register with date of hospital admissions and diagnoses codes coded by
the International Classification of Diseases (ICD) version 10:

``` r
ex_icd10
#> # A tibble: 1,000 x 4
#>    name               admission  icd10 hdia 
#>    <chr>              <date>     <chr> <lgl>
#>  1 Tapparo, Keishawn  2020-06-20 F602  FALSE
#>  2 Brunson, Brannon   2019-11-15 B968  FALSE
#>  3 Perez, Vidal       2019-07-20 W2718 FALSE
#>  4 al-Ismail, Waleeda 2020-05-12 V4451 FALSE
#>  5 Morris, Marvin     2020-06-21 V6064 FALSE
#>  6 Murray, Eric       2019-09-29 R221  FALSE
#>  7 Apodaca, Lakota    2020-06-08 Y0829 FALSE
#>  8 Wuertz, Jenny      2020-06-14 Y762  TRUE 
#>  9 Alexander, Bethany 2019-10-02 B670  FALSE
#> 10 Quick, Miriah      2019-12-06 N052  FALSE
#> # ... with 990 more rows
```

Using those two data sets, as well as a classification scheme
(`classcodes` object; see below), we can easily identify all Charlson
comorbidities for each patient:

``` r
ch <- 
  categorize(
  ex_people,                  # patients of interest 
  codedata = ex_icd10,        # Medical codes from national patient register
  cc = "charlson",            # Calculate Charlson comorbidity
  id = "name", code = "icd10" # Specify column names
  )
#> Classification based on: regex_icd10

ch
#> # A tibble: 100 x 25
#>    name  surgery    `myocardial inf~ `congestive hea~ `peripheral vas~
#>    <chr> <date>     <lgl>            <lgl>            <lgl>           
#>  1 Alex~ 2019-10-08 FALSE            FALSE            FALSE           
#>  2 Argu~ 2020-07-05 FALSE            FALSE            FALSE           
#>  3 Aust~ 2020-06-28 FALSE            FALSE            FALSE           
#>  4 Ball~ 2019-11-15 FALSE            FALSE            FALSE           
#>  5 Bean~ 2019-12-14 FALSE            FALSE            FALSE           
#>  6 Beeh~ 2019-11-03 FALSE            FALSE            FALSE           
#>  7 Bess~ 2020-07-25 FALSE            FALSE            FALSE           
#>  8 Bish~ 2019-11-07 FALSE            FALSE            FALSE           
#>  9 Bivi~ 2020-01-04 FALSE            FALSE            FALSE           
#> 10 Brow~ 2020-03-17 FALSE            FALSE            FALSE           
#> # ... with 90 more rows, and 20 more variables: `cerebrovascular
#> #   disease` <lgl>, dementia <lgl>, `chronic pulmonary disease` <lgl>,
#> #   `rheumatic disease` <lgl>, `peptic ulcer disease` <lgl>, `mild liver
#> #   disease` <lgl>, `diabetes without complication` <lgl>, `hemiplegia or
#> #   paraplegia` <lgl>, `renal disease` <lgl>, `diabetes complication` <lgl>,
#> #   malignancy <lgl>, `moderate or severe liver disease` <lgl>, `metastatic
#> #   solid tumor` <lgl>, `AIDS/HIV` <lgl>, index_charlson <dbl>,
#> #   index_deyo_ramano <dbl>, index_dhoore <dbl>, index_ghali <dbl>,
#> #   index_quan_original <dbl>, index_quan_updated <dbl>
```

How many patietns were diagnosed with malignancy?

``` r
sum(ch$malignancy)
#> [1] 10
```

What is the distribution of the combined comorbidity index for each
patient?

``` r
hist(ch$index_charlson, main = "Charlson comorbidity index")
```

<img src="man/figures/READMEunnamed-chunk-5-1.png" width="100%" />

There are in many versions of the Charlson comorbidity index, which
might be controlled by the `index` argument. We might also be interested
only in diagnoses from 90 days before surgery:

``` r
ch <- 
  categorize(
    ex_people, codedata = ex_icd10, cc = "charlson", id = "name", code = "icd10",
    
    # Additional arguments
    index       = c("quan_original", "quan_updated"),
    codify_args = list(
      date = "surgery", code_date = "admission", # Specify date columns 
      days = c(-90, -1) # Time window
    )
  )
#> Classification based on: regex_icd10
```

Number of malignancies during this period?

``` r
sum(ch$malignancy, na.rm = TRUE)
#> [1] 2
```

Distribution of the index as proposed by QUan et al 2011:

``` r
hist(ch$quan_updated)
```

<img src="man/figures/READMEunnamed-chunk-8-1.png" width="100%" />

## Classification schemes

Classification schemes (`classcodes` objects) are based on regular
expressions for computational speed, but their content can be summarized
and visualized for clarity. Arbitrary `classcodes` objects can also be
specified by the user.

The package includes default `classcodes` for medical patient data based
on the international classification of diseases version 8, 9 and 10
(ICD-8/9/10), as well as the Anatomical Therapeutic Chemical
Classification System (ATC) for medical prescription data.

Default `classcades` are listed in the table. Each classification
(classcodes column) can be based on several code systems (regex column)
and have several alternative weighted indices (indices column). Those
might be combined freely.

    #> # A tibble: 7 x 3
    #>   classcodes   regex                           indices                          
    #>   <chr>        <chr>                           <chr>                            
    #> 1 charlson     icd10, icd9cm_deyo, icd9cm_enh~ "index_charlson, index_deyo_rama~
    #> 2 cps          icd10                           "index_only_ordinary"            
    #> 3 elixhauser   icd10, icd10_short, icd9cm, ic~ "index_sum_all, index_sum_all_ah~
    #> 4 hip_ae       icd10, kva, icd10_fracture      ""                               
    #> 5 hip_ae_hail~ icd10, kva                      ""                               
    #> 6 knee_ae      icd10, kva                      ""                               
    #> 7 rxriskv      pratt, caughey, garland         "index_pratt, index_sum_all"

# Relation to other packages

`coder` uses `data.table` as a backend to increase computational speed
for large datasets. There are some R packages with a narrow focus on
Charlson and Elixhauser co-morbidity based on ICD-codes
([icd](https://CRAN.R-project.org/package=icd),
[comorbidity](https://CRAN.R-project.org/package=comorbidity),
[medicalrisk](https://CRAN.R-project.org/package=medicalrisk),
[comorbidities.icd10](https://github.com/gforge/comorbidities.icd10),
[icdcoder](https://github.com/wtcooper/icdcoder)). The `coder` package
includes similar functionalities but has a wider scope.

# Contribution

Contributions to this package are welcome. The preferred method of
contribution is through a github pull request. Feel free to contact me
by creating an issue. Please note that this project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in
this project you agree to abide by its terms.
