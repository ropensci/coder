---
output: github_document
---

[![Build Status](https://travis-ci.org/eribul/coder.svg?branch=master)](https://travis-ci.org/eribul/coder)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/eribul/coder?branch=master&svg=true)](https://ci.appveyor.com/project/eribul/coder)
[![codecov](https://codecov.io/gh/eribul/coder/branch/master/graph/badge.svg)](https://codecov.io/gh/eribul/coder)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)


<!-- README.md is generated from README.Rmd. Please edit that file --> 


# coder 

The goal of `coder` is to classify items from one dataset, using codes from a secondary source. 
Please se vigtnettes with introductionary examples! 

## Installation

You can (soon) install the released version of coder from [CRAN](https://CRAN.R-project.org) with:

``` r
# install.packages("coder") # Not yet!
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("eribul/coder")
```

## Classification schemes

Classification schemes are used to classify items. 
These schemas are constructed by regular expressions for computational speed, 
but their content can be summarized and visualized for clarity.

The package includes several default classification schemes (so called `classcodes` objects).
Most of these are related to medical patient data (for classification of comorbidity and adverse events).

Arbitrary `classcodes` objects can be specified by the user. 

### Default classcodes


|clascodes             |coding |alt_regex |indices                                                              |  N|     n|
|:---------------------|:------|:---------|:--------------------------------------------------------------------|--:|-----:|
|charlson_icd10        |icd10  |          |charlson, deyo_ramano, dhoore, ghali, quan_original, quan_updated    | 17|  1178|
|cps_icd10             |icd10  |          |only_ordinary                                                        |  2| 12406|
|elix_icd10            |icd10  |          |sum_all, sum_all_ahrq, walraven, sid29, sid30, ahrq_mort, ahrq_readm | 31|  1516|
|ex.carbrands_excars   |excars |          |                                                                     |  7|    NA|
|hip.ae_icd10          |icd10  |          |                                                                     |  6|   289|
|hip.ae_kva            |kva    |          |                                                                     |  1|    21|
|hip.fracture.ae_icd10 |icd10  |          |                                                                     |  6|   292|
|knee.ae_icd10         |icd10  |          |                                                                     |  6|   288|
|knee.ae_kva           |kva    |          |                                                                     |  1|   141|
|rxriskv_atc           |atc    |          |index_pratt                                                          | 46|   406|

# Contribution

Contributions to this package are welcome. The preferred method of contribution is through a github pull request. Feel free to contact me by creating an issue. Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.
