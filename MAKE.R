# Make package

# Make sure it works with latest packages on CRAN
update.packages(ask = FALSE)

# Rebuild data sets
unlink("data", TRUE)
dir.create("data")
file.remove("R/sysdata.rda")
library(tidyverse)
library(data.table)
devtools::load_all()
for (file in dir("data-raw", pattern = ".R")) source(file.path("data-raw", file))

# Rebuild documentation
unlink("man", TRUE)
file.remove("NAMESPACE")
devtools::document()
devtools::install()
knitr::knit("README.Rmd")
devtools::build_manual()
pkgdown::build_site()

# Checks
devtools::check()
goodpractice::goodpractice()
rhub::check_for_cran()
devtools::build_win()


