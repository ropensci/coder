set.seed(123)
N <- 1e3

ex_cars <-
  data.frame(
    id        = sample(randomNames::randomNames(N),   N, replace = TRUE),
    code      = rownames(mtcars)[sample(nrow(mtcars), N, replace = TRUE)],
    code_date = Sys.Date() - sample(N),
    stringsAsFactors = FALSE
  )

usethis::use_data(ex_cars, overwrite = TRUE)
