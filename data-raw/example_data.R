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


N <- 10000

ex_atc <-
  tibble::tibble(
    name     = sample(ex_people$name[1:90], N, replace = TRUE),
    atc      = sample(decoder::atc$key, N, replace = TRUE),

    # Assume that each ATC code corresponds to (random) prescription dates
    # during 10 years before or 1 year after the median date of surgery.
    prescription =
      median(ex_people$surgery) +
      sample(-3650:365, N, replace = TRUE)
  )

usethis::use_data(ex_people, ex_icd10, ex_atc, overwrite = TRUE)
