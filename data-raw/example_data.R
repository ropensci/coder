set.seed(123)
# Generate some example data to include in the package

ex_icd10 <-
  icd.data::uranium_pathology %>%
  as_tibble() %>%
  transmute(
    name = randomNames::randomNames(n())[case],
    admission = Sys.Date() - sample(0:365, n(), TRUE),
    icd10     = sample(decoder::icd10se$key, n(), TRUE),
    hdia      = sample(c(TRUE, FALSE), n(), TRUE, c(.1, .9))
  )

ex_people <-
  tibble::tibble(
    name    = sample(unique(ex_icd10$name), 100),
    surgery = Sys.Date() - sample(0:365, 100, TRUE)
  )


usethis::use_data(ex_people, ex_icd10, overwrite = TRUE)
