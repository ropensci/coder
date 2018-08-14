---
output: github_document
---

[![Build Status](https://travis-ci.org/eribul/coder.svg?branch=master)](https://travis-ci.org/eribul/coder)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/eribul/coder?branch=master&svg=true)](https://ci.appveyor.com/project/eribul/coder)
[![codecov](https://codecov.io/gh/eribul/coder/branch/master/graph/badge.svg)](https://codecov.io/gh/eribul/coder)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)


<!-- README.md is generated from README.Rmd. Please edit that file -->


# coder

The goal of coder is to classify items from one dataset, using code data from a secondary source. It was first developed for medical comorbidity data based on hospital visits recorded in a national patient register. Medical conditions were registered using standardized codes (ICD-10) and individual codes were summarized by weighting all individual comorbidities for each patient (the Charlson and Elixhauser comorbidity indices). Only hospital visits recorded within a specified time frame, compared to individual reference dates from the primary data source, were recognized as relevant.

The large data sets, as well as the complexity of the classification schemes make those calculations time consuming. A naïve approach using bare code comparisons and for-loops in R, took approximately 16 hours to run on a laptop computer with 16 GB of RAM. We were then able to reformulate the coding schemes using regular expressions and we optimized our package using the data.table package. The classification time were then reduced to a number of seconds. We also compared the coder package to two packages on CRAN with similar scoop, icd and comorbidities.icd10. Our package was considerably faster  than those.

The package does not only include classification schemes for comorbidity data. It incorporates a general framework for any case where items can be classified using standardized codes. It might therefore be relevant for many tasks involving data management in official statistics using big data. 

## Installation

You can install the released version of coder from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("coder")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("eribul/coder")
```

## Example

This is a basic example how to categorize patients by Elixhauser comorbidity:


```r
library(coder)

# A group of patients ...
head(ex_people)
#>                 name    surgery
#> 1    Beaver, Tristin 2016-09-11
#> 2  Maestas, Lilibeth 2016-10-23
#> 3        Jung, Derek 2017-02-20
#> 4     Hayes, Kylihah 2016-12-31
#> 5     el-Riaz, Aadam 2016-04-19
#> 6 Sanchez, Dominique 2017-02-25

# ... with a group of comorbidies ...
head(ex_icd10)
#>                id  code_date   code  hdia
#> 1: Abzari, Joseph 2016-04-15  C430C FALSE
#> 2: Abzari, Joseph 2016-05-02  L818A FALSE
#> 3: Abzari, Joseph 2016-06-06   O630 FALSE
#> 4: Abzari, Joseph 2016-09-01   P558 FALSE
#> 5: Abzari, Joseph 2016-10-02 UA3290 FALSE
#> 6: Abzari, Joseph 2016-12-18  S6260 FALSE

# ... can be categorized by the Elixhauser commorbidity index:
df <- 
  categorize(
    ex_people, 
    ex_icd10, 
    "elix_icd10", 
    id = "name", 
    date = "surgery"
  )
#> Warning in codify(x = to, from = from, id = id, date = date, days = days):
#> Date column ignored since days = NULL!
#> index calculated as number of relevant categories

# Tabulate the Elixhauser index
table(df$index)
#> 
#>  0  1  2  3 
#> 55 37  4  3

# Count how many patients have each comorbidity identified by Elixhauser
colSums(df[,3:32], na.rm = TRUE)
#>       congestive heart failure            cardiac arrhythmias 
#>                              2                              1 
#>               valvular disease pulmonary circulation disorder 
#>                              2                              0 
#>   peripheral vascular disorder     hypertension uncomplicated 
#>                              2                              0 
#>       hypertension complicated                      paralysis 
#>                              2                              3 
#>   other neurological disorders      chronic pulmonary disease 
#>                              3                              2 
#>         diabetes uncomplicated           diabetes complicated 
#>                              0                              3 
#>                 hypothyroidism                  renal failure 
#>                              1                              1 
#>                  liver disease           peptic ulcer disease 
#>                              0                              0 
#>                       AIDS/HIV                       lymphoma 
#>                              0                              4 
#>              metastatic cancer                    solid tumor 
#>                              2                             11 
#>           rheumatoid arthritis                   coagulopathy 
#>                              6                              0 
#>                        obesity                    weight loss 
#>                              0                              2 
#>    fluid electrolyte disorders              blood loss anemia 
#>                              2                              0 
#>              deficiency anemia                  alcohol abuse 
#>                              1                              1 
#>                     drug abuse                      psychoses 
#>                              1                              2
```

# Code of conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.

