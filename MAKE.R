# Make package

# New version number
fledge::bump_version() # create development version
fledge::finalize_version()


# Make sure it works with latest packages on CRAN
update.packages()

# Update package metadata
codemetar::write_codemeta(".")

# Update README
knitr::knit("README.Rmd")


# Rebuild website
pkgdown::build_site()


# Update precompiled vignette(s)
source("vignettes/precompile.R")

# Checks
goodpractice::goodpractice()
devtools::check()
rhub::check_for_cran()
devtools::build_win()


