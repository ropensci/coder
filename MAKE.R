# Make package

# New version number
# fledge::bump_version() # create development version
# fledge::finalize_version()

# Make sure it works with latest packages on CRAN
update.packages(ask = FALSE)

# Rebuild data sets
unlink("data", TRUE)
dir.create("data")
file.remove("R/sysdata.rda")
library(tidyverse)
for (file in dir("data-raw", pattern = ".R")) source(file.path("data-raw", file))

# Rebuild documentation
unlink("man", TRUE)
file.remove("NAMESPACE")
devtools::document()
devtools::install()
knitr::knit("README.Rmd")
# codemetar::write_codemeta(".")
pkgdown::build_site()

# Checks
goodpractice::goodpractice()
devtools::check()
rhub::check_for_cran()
devtools::build_win()


