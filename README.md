
[![Build
Status](https://travis-ci.org/eribul/coder.svg?branch=master)](https://travis-ci.org/eribul/coder)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/eribul/coder?branch=master&svg=true)](https://ci.appveyor.com/project/eribul/coder)
[![codecov](https://codecov.io/gh/eribul/coder/branch/master/graph/badge.svg)](https://codecov.io/gh/eribul/coder)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# coder

The goal of `coder` is to classify items from one dataset, using codes
from a secondary source. Please se vigtnettes with introductionary
examples\!

## Installation

You can (soon) install the released version of coder from
[CRAN](https://CRAN.R-project.org) with:

``` r
# install.packages("coder") # Not yet!
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("eribul/coder")
```

## Classification schemes

Classification schemes are used to classify items. These schemas are
constructed by regular expressions for computational speed, but their
content can be summarized and visualized for clarity.

The package includes several default classification schemes (so called
`classcodes` objects). Most of these are related to medical patient data
(for classification of comorbidity and adverse events).

Arbitrary `classcodes` objects can be specified by the
user.

### Default classcodes

| clascodes                        | description                                                            | coding      | indices                                                              | no\_categories | no\_codes |
| :------------------------------- | :--------------------------------------------------------------------- | :---------- | :------------------------------------------------------------------- | -------------: | --------: |
| charlson\_icd10                  | Comorbidity based on Charlson                                          | icd10       | charlson, deyo\_ramano, dhoore, ghali, quan\_original, quan\_updated |             19 |      1178 |
| cps\_icd10                       | comorbidity-polypharmacy score (CPS)                                   | icd10       | only\_ordinary                                                       |              2 |     12406 |
| elix\_icd10                      | Comorbidity based on Elixhauser                                        | icd10       | walraven                                                             |             31 |      1517 |
| ex\_carbrands                    | Example data of car brand names and their producers.                   | ex\_allcars |                                                                      |             10 |        27 |
| hip\_adverse\_events\_icd10      | Adverse events after hip arthroplasty                                  | icd10       | condition                                                            |              6 |       306 |
| hip\_adverse\_events\_icd10\_old | Adverse events after hip arthroplasty                                  | icd10       | condition, sos, shar                                                 |              3 |       523 |
| hip\_fracture\_ae\_icd10         | Adverse events after hip arthroplasty                                  | icd10       |                                                                      |              1 |       749 |
| hip\_fracture\_ae\_kva           | Adverse events after hip arthroplasty                                  | kva         |                                                                      |              1 |       143 |
| knee\_adverse\_events\_icd10     | Adverse events after knee arthroplasty                                 | icd10       | condition                                                            |              6 |       278 |
| rxriskv\_atc                     | Comorbidity index ‘RxRiskV’                                            | atc         |                                                                      |             39 |      1170 |
| rxriskv\_modified\_atc           | Comorbidity index ‘RxRiskV’ (unofficial modification by Anne Garland). | ATC         |                                                                      |             42 |      1391 |

# Contribution

Contributions to this package are welcome. The preferred method of
contribution is through a github pull request. Feel free to contact me
by creating an issue. Please note that this project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in
this project you agree to abide by its terms.
