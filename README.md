---
title: "coder"
output: 
  github_document:
    df_print: tibble
---

[![R build status](https://github.com/eribul/coder/workflows/R-CMD-check/badge.svg)](https://github.com/eribul/coder/actions)
[![codecov](https://codecov.io/gh/eribul/coder/branch/master/graph/badge.svg)](https://codecov.io/gh/eribul/coder)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)


<!-- README.md is generated from README.Rmd. Please edit that file --> 



## Aim of the package

The goal of `coder` is to classify items from one dataset, using codes from a secondary source with classification schemes based on regular expressions and weighted indices. 


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


## Typical use case

**Patient data:** The initial rationale for the package was to classify patient data based on medical coding. A typical use case would consider patients from a medical/administrative data base, as identified by some patient id and possibly with some associated date of interest (date of diagnoses/treatment/intervention/hospitalization/rehabilitation). This data source could be for example an administrative hospital register or a national quality register. 

**Codify:** The primary source could then be linked to a secondary (possibly larger) data base including the same patients with corresponding id:s and some coded patient data. This could be a national patient register with medical codes from the International Classification of Diseases _(ICD)_ with corresponding dates of hospital visits/admission/discharge, or a medical prescription register with codes from the Anatomic Therapeutic Chemical _(ATC)_ classification system with dates of medical prescription/dispatch/usage. A time window could be specified relating the date of the primary source (i. e. the date of a primary total hip arthroplasty; THA), to dates from the secondary source (i.e. the date of a medical prescription). ATC codes associated with medical prescriptions during one year prior to THA, could thus be identified and used as a measure of comorbidity. Another time window of 90 days after THA, might instead be used to identify adverse events after surgery. 

**Classify:** To work with medical/chemical codes directly might be cumbersome, since those classifications tend to be massive and therefore hard to interpret. It is thus common to use data aggregation as proposed by some classification or combined index from the literature. This could be the _Charlson_ or _Elixhauser_ comorbidity indices based on ICD-codes, or the _RxRisk V_ classification based on ATC-codes. Each of those tools appear with different code versions (ICD-8, ICD-9, ICD-9-CM, ICD-10, ICD-10-CA, ICD-10-SE, ICD-10-CM et cetera) and with different codes recognized as relevant comorbidities (the Charlson index proposed by Charlson et al, Deyo et al, Romano et al. Quan et al. et cetera). Using a third object (in addition to the primary and secondary patient data sets) helps to formalize and structure the use of such classifications. This is implemented in the `coder` package by `classcodes` objects based on regular expressions (often with several alternative versions). Those `classcodes` objects could be prepared by the user, although a number of default `classcodes` are also included in the package (table below).

**Index:** Now, instead of working with tens of thousands of individual ICD-codes, each patient might be recognized to have none or some familiar comorbidity such as hypertension, cancer or dementia. This granularity might be too fine-grained still, wherefore an even simpler index score might be searched for. Such scores/indices/weighted sums have been proposed as well and exist in many versions for each of the standard classifications. Some are simple counts, some are weighted sums, and some accounts for some inherited hierarchy (such that ICD-codes for diabetes with and without complications might be recognized in the same patient, although the un-complicated version might be masked by the complicated version in the index).

**Conditions:** Some further complexity might appear if some codes are only supposed to be recognized based on certain conditions. Patients with THA for example might have an adverse event after surgery if a certain ICD-code is recorded as the main diagnose at a later hospital visit, although the same code could be ignored if recorded only as a secondary diagnosis.

**To summarize:** The coder package takes three objects: (1) a data frame/table/tibble with id and possible dates from a primary source; (2) coded data from a secondary source with the same id and possibly different dates and; (3) a `classcodes` object, either a default one from the package, or as specified by the user. The outcome is then: (i) codes associated with each element from (1) identified from (2), possibly limited to a relevant time window; (ii) a broader categorization of the relevant codes as prescribed by (3), and; (iii) a summarized index score based on the relevant categories from (3). 

(i-iii) corresponds to the output from functions `codify()`, `classify()` and `index()`, which could be chained explicitly as `codify() %>% classify() %>% index()`, or implicitly by the `categorize()` function. 


## Usage

Assume we have some patients with corresponding dates of interest (i.e. dates of  total hip arthroplasty; THA):

```r
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
We also have some external medical data: ICD-10-codes (code) recorded at previous hospital visits (code date), some of them are main diagnosis and some secondary (hdia):


```r
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

Using those two sources, as well as a classification scheme (`classcodes` object; see below), we can easily identify all Charlson co-morbidities during one year prior to the event of interest. 


```r
ch <- 
  categorize(
    
    # Relevant patients from a national quality register
    ex_people, 
    
    # Corresponding medical data from the national patient register
    codedata    = ex_icd10, 
    
    # Estimate comorbidity based on the Charlson comorbidity index
    cc          = "charlson",
    
    # Patient names used as id
    id          = "name",
    code        = "icd10",
    
    # Calculate two versions of combined index values
    index       = c("quan_original", "quan_updated"),
    
    # We only consider ICD-10-codes recorded within one year prior to THA
    codify_args = list(date = "surgery", 
                       code_date = "admission", 
                       days = c(-365, -1))
  )
#> Classification based on: regex_icd10
#> Warning in `[.data.table`(unique(codified, by = id), , ...data_cols): Both '.data_cols' and
#> '...data_cols' exist in calling scope. Please remove the '...data_cols' variable in calling scope
#> for clarity.
```

The result is a dataset with columns for each recognized comorbidity and (optional) each weighted index as displayed here for the interest of space (`quan_original` as proposed by Charlson et al. in 1987 and the `quan_updated` from Quan et al. in 2011). Most of the patients are healthy with an index score of 0. Some patients had no recorded hospital visits during the year preceding THA. They receive `NA` scores, which could later be substituted with 0. 


```r
ch
#> # A tibble: 100 x 21
#>    name  surgery    `myocardial inf~ `congestive hea~ `peripheral vas~ `cerebrovascula~ dementia
#>    <chr> <date>     <lgl>            <lgl>            <lgl>            <lgl>            <lgl>   
#>  1 Alex~ 2019-10-08 FALSE            FALSE            FALSE            FALSE            FALSE   
#>  2 Argu~ 2020-07-05 FALSE            FALSE            FALSE            FALSE            FALSE   
#>  3 Aust~ 2020-06-28 FALSE            FALSE            FALSE            FALSE            FALSE   
#>  4 Ball~ 2019-11-15 FALSE            FALSE            FALSE            FALSE            FALSE   
#>  5 Bean~ 2019-12-14 FALSE            FALSE            FALSE            FALSE            FALSE   
#>  6 Beeh~ 2019-11-03 NA               NA               NA               NA               NA      
#>  7 Bess~ 2020-07-25 FALSE            FALSE            FALSE            FALSE            FALSE   
#>  8 Bish~ 2019-11-07 FALSE            FALSE            FALSE            FALSE            FALSE   
#>  9 Bivi~ 2020-01-04 FALSE            FALSE            FALSE            FALSE            FALSE   
#> 10 Brow~ 2020-03-17 FALSE            FALSE            FALSE            FALSE            FALSE   
#> # ... with 90 more rows, and 14 more variables: `chronic pulmonary disease` <lgl>, `rheumatic
#> #   disease` <lgl>, `peptic ulcer disease` <lgl>, `mild liver disease` <lgl>, `diabetes without
#> #   complication` <lgl>, `hemiplegia or paraplegia` <lgl>, `renal disease` <lgl>, `diabetes
#> #   complication` <lgl>, malignancy <lgl>, `moderate or severe liver disease` <lgl>, `metastatic
#> #   solid tumor` <lgl>, `AIDS/HIV` <lgl>, quan_original <dbl>, quan_updated <dbl>
```



## Classification schemes

Classification schemes (`classcodes` objects) are based on regular expressions for computational speed, but their content can be summarized and visualized for clarity.  Arbitrary `classcodes` objects can also be specified by the user. 

The package includes default `classcodes` for medical patient data based on the international classification of diseases version 8, 9 and 10 (ICD-8/9/10), as well as the Anatomical Therapeutic Chemical Classification System (ATC) for medical prescription data.

Default `classcades` are listed in the table. Each classification (classcodes column) can be based on several code systems (regex column) and have several alternative weighted indices (indices column). Those might be combined freely. 


```
#> # A tibble: 7 x 3
#>   classcodes   regex                                 indices                                     
#>   <chr>        <chr>                                 <chr>                                       
#> 1 charlson     icd10, icd9cm_deyo, icd9cm_enhanced,~ "index_charlson, index_deyo_ramano, index_d~
#> 2 cps          icd10                                 "index_only_ordinary"                       
#> 3 elixhauser   icd10, icd10_short, icd9cm, icd9cm_a~ "index_sum_all, index_sum_all_ahrq, index_w~
#> 4 hip_ae       icd10, kva, icd10_fracture            ""                                          
#> 5 hip_ae_hail~ icd10, kva                            ""                                          
#> 6 knee_ae      icd10, kva                            ""                                          
#> 7 rxriskv      pratt, caughey, garland               "index_pratt, index_sum_all"
```

# Relation to other packages

`coder` uses `data.table` as a backend to increase computational speed for large datasets. There are some R packages with a narrow focus on Charlson and Elixhauser co-morbidity based on ICD-codes ([icd ](https://CRAN.R-project.org/package=icd), [comorbidity](https://CRAN.R-project.org/package=comorbidity), [medicalrisk ](https://CRAN.R-project.org/package=medicalrisk), [comorbidities.icd10 ](https://github.com/gforge/comorbidities.icd10), [icdcoder](https://github.com/wtcooper/icdcoder)). The `coder` package includes similar functionalities but has a wider scope. 


# Contribution

Contributions to this package are welcome. The preferred method of contribution is through a github pull request. Feel free to contact me by creating an issue. Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.
