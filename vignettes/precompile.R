# Vignettes that are too slow to produce have been precompiled:
# We change wd to ease of use with caching

knitr::knit("vignettes/benchmark.Rmd.orig", "vignettes/benchmark.Rmd")
rmarkdown::render("vignettes/benchmark.Rmd", output_file = "benchmark.html")
devtools::build_vignettes()
