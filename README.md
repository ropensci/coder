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
Please se vignettes with introductory examples! 

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
These schema are constructed by regular expressions for computational speed, 
but their content can be summarized and visualized for clarity.

The package includes several default classification schemes (so called `classcodes` objects).
Most of these are related to medical patient data (for classification of comorbidity and adverse events).

Arbitrary `classcodes` objects can be specified by the user. 

### Default classcodes


|clascodes       |alt_regex                                                                   |indices                                                              |
|:---------------|:---------------------------------------------------------------------------|:--------------------------------------------------------------------|
|charlson        |icd9cm_deyo, icd9cm_enhanced, icd10_rcs, icd8_brusselaers, icd9_brusselaers |charlson, deyo_ramano, dhoore, ghali, quan_original, quan_updated    |
|cps             |                                                                            |only_ordinary                                                        |
|elixhauser      |short                                                                       |sum_all, sum_all_ahrq, walraven, sid29, sid30, ahrq_mort, ahrq_readm |
|ex_carbrands    |                                                                            |                                                                     |
|hip_ae          |kva                                                                         |                                                                     |
|hip_ae_hailer   |kva                                                                         |                                                                     |
|hip_fracture_ae |kva                                                                         |                                                                     |
|knee_ae         |kva                                                                         |                                                                     |
|rxriskv         |caughey, garland                                                            |pratt, sum_all                                                       |

# Contribution

Contributions to this package are welcome. The preferred method of contribution is through a github pull request. Feel free to contact me by creating an issue. Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.
