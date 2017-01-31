# We here try to spell check the entire documentation for the package
# We ignore words that should not be checked:

context("spell check")

ignored_words <-
  c(
    "al",                  # et al.
    "ATC",
    "al",
    "arthroplasty",
    "Arthroplasty",
    "Avina",              # author name
    "Charlson",
    "classcode",
    "Classcode",
    "classcodes",
    "Classcodes",
    "comorbidities",
    "comorbidity",
    "Comorbidity",
    "Deyo",               # author name
    "DM",                 # internal abbreviation
    "Elixhauser",
    "Ghali",              # author name
    "Gorenchtein",
    "hdia",               # internal abbreviation
    "Hoore",              # author name
    "Hude",               # author name,
    "icd",
    "ICD",
    "indices",           # don't know why this comes up
    "Lacaille",          # author
    "magrittr",
    "pardata",           # internal
    "polypharmacy",
    "Quan",              # author
    "RxRisk",            # internal
    "RxRiskV",           # internal
    "Socialstyrelsen",   # Swedish authoroty name
    "Stawicki",          # author
    "THA",               # Total Hip Arthroplasty
    "tidyverse",
    "TKA",               # Total knee arthroplasty
    "UA", "UB",          # internal abbreviations
    "Yurkovich",         # author
    "Zubieta"            # author
  )

test_that("Correct spelling", {
  skip_on_travis()
  expect_equal(length(devtools::spell_check(ignore = ignored_words)), 0)
})