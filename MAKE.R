# Make package

# Make sure it works with latest packages on CRAN
update.packages()

# Update package metadata
codemetar::write_codemeta(".")

# Rebuild website
pkgdown::build_site()

# Update README
knitr::knit("README.Rmd")

# Update precompiled vignette(s)
source("vignettes/precompile.R")

# Checks
goodpractice::goodpractice()
devtools::check()
rhub::check_for_cran()
devtools::build_win()


