# coder 

[![Build Status](https://travis-ci.org/eribul/coder.svg?branch=master)](https://travis-ci.org/eribul/coder)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/eribul/coder?branch=master&svg=true)](https://ci.appveyor.com/project/eribul/coder)
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
head(ex_people) %>% knitr::kable()
```



|name                    |event      |
|:-----------------------|:----------|
|Miller, Von Buddenbrock |2019-05-03 |
|Enriquez, Anthony       |2019-10-15 |
|al-Dib, Farhaan         |2019-12-11 |
|Martinez, Alison        |2019-09-17 |
|el-Masri, Junaid        |2019-07-06 |
|Sam, Niki               |2019-12-23 |
We also have some external medical data (ICD-10-codes recorded at previous hospital):


```r
head(ex_icd10) %>% knitr::kable()
```



|id                 |code_date  |code |hdia  |
|:------------------|:----------|:----|:-----|
|Aguilera, Brandon  |2019-05-17 |T931 |FALSE |
|Aguilera, Brandon  |2019-08-11 |D301 |FALSE |
|Aguilera, Brandon  |2019-09-11 |I828 |FALSE |
|Alexander, Bethany |2019-01-25 |S925 |FALSE |
|Alexander, Bethany |2019-03-01 |E278 |FALSE |
|Alexander, Bethany |2019-07-06 |A507 |FALSE |

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

The result is a dataset with columns for each comorbidity and (optional) each weighted index. Those were specified as "quan_original" and "quan_updated":


```r
dplyr::select(ch, name, quan_original, quan_updated) %>% knitr::kable()
```



|name                    | quan_original| quan_updated|
|:-----------------------|-------------:|------------:|
|Enriquez, Anthony       |             0|            0|
|Martinez, Alison        |             0|            0|
|Miller, Von Buddenbrock |            NA|           NA|
|Sam, Niki               |             2|            2|
|al-Dib, Farhaan         |             0|            0|
|el-Masri, Junaid        |             2|            1|



## Classification schemes

Classification schemes (`classcodes` objects) are based on regular expressions for computational speed, but their content can be summarized and visualized for clarity.  Arbitrary `classcodes` objects can also be specified by the user. 

### Default classcodes

The package includes default `classcodes` for medical patient data based on the international classification of diseases version 8, 9 and 10 (ICD-8/9/10), as well as the Anatomical Therapeutic Chemical Classification System (ATC) for medical prescription data.

Default `classcades` are listed in the table. Each classification (classcodes column) can be based on several code systems (regex column) and have several alternative weighted indices (indices column). Those might be combined freely. 


|clascodes     |regex                                                                              |indices                                                                                                        |
|:-------------|:----------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------------------------------|
|charlson      |icd10, icd9cm_deyo, icd9cm_enhanced, icd10_rcs, icd8_brusselaers, icd9_brusselaers |index_charlson, index_deyo_ramano, index_dhoore, index_ghali, index_quan_original, index_quan_updated          |
|cps           |icd10                                                                              |index_only_ordinary                                                                                            |
|elixhauser    |icd10, icd10_short, icd9cm, icd9cm_ahrqweb, icd9cm_enhanced                        |index_sum_all, index_sum_all_ahrq, index_walraven, index_sid29, index_sid30, index_ahrq_mort, index_ahrq_readm |
|ex_carbrands  |                                                                                   |                                                                                                               |
|hip_ae        |icd10, kva, icd10_fracture                                                         |                                                                                                               |
|hip_ae_hailer |icd10, kva                                                                         |                                                                                                               |
|knee_ae       |icd10, kva                                                                         |                                                                                                               |
|rxriskv       |pratt, caughey, garland                                                            |index_pratt, index_sum_all                                                                                     |

# Relation to other packages

`coder` uses `data.table` as a backend to increase computational speed for large datasets. There are some CRAN packages with a specific scope of Charlson and Elixhauser comorbidity based on ICD-codes: `comorbidities.icd10`, `comorbidity` and `icd`. The first is rather slow for large datasets and is not actively developed. The other two are excellent alternatives for those specific use cases.

# Citation


```r
citation("coder")
#> 
#> To cite package 'coder' in publications use:
#> 
#>   Erik Bulow (2020). coder: Deterministic Categorization of Items Based on External Code
#>   Data. R package version 0.11.1. https://github.com/eribul/coder
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {coder: Deterministic Categorization of Items Based on External Code
#> Data},
#>     author = {Erik Bulow},
#>     year = {2020},
#>     note = {R package version 0.11.1},
#>     url = {https://github.com/eribul/coder},
#>   }
```


# Contribution

Contributions to this package are welcome. The preferred method of contribution is through a github pull request. Feel free to contact me by creating an issue. Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.
