# Vignettes that are too slow to produce have been precompiled:
# We change wd to ease of use with caching

old_wd <- getwd()
setwd(paste0(old_wd, "/vignettes"))

knitr::knit("benchmark.Rmd.orig", "benchmark.Rmd")
rmarkdown::render("benchmark.Rmd")

setwd(old_wd)