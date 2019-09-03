set.seed(123)
# Generate some example data to include in the package

n <- 1e2     # How many people to look for
N <- n * 10  # How many cases in the codedata set


# Individuals we are interested in
ex_people <-
  tibble::tibble(
    name    = randomNames::randomNames(n),
    surgery = Sys.Date() - sample(0:365, n, TRUE)
)


# Codedata for these (and other) individuals
ex_icd10 <-
  tibble::tibble(
    id   = sample(c(ex_people$name, randomNames::randomNames(n)), N, TRUE),
    code_date = Sys.Date() - sample(0:365, N, TRUE) - 100,
    code = sample(decoder:::icd10$key, N, TRUE),
    hdia = sample(c(TRUE, FALSE), N, TRUE, c(.1, .9))
  ) %>%
  coder::as.codedata()

usethis::use_data(ex_people, ex_icd10, overwrite = TRUE)
