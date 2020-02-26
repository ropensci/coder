context("index")
y <-
  codify(ex_people, ex_icd10, id = "name",
    date = "event", days = c(-365, 0)) %>%
  {suppressWarnings(classify(., "charlson"))}

test_that("Charlson", {
  suppressWarnings(
    expect_gte(
      sum(index(y, "charlson"), na.rm = TRUE),
      sum(index(y, "ghali"),  na.rm = TRUE)
    )
  )
  expect_error(index(y, "hej"), "is not a column of the classcodes object!")
})



# Subordinate hierarchical classes ----------------------------------------

y <-
  codify(
    data.frame(id = letters[1:6], stringsAsFactors = FALSE),
    data.frame(
      id   = c( "a",    "a",   "b",   "c",     "d",    "d",    "e",    "f"),
      code = c("C01", "C80", "C01", "C80",  "E100", "E102", "E100", "E102"),
      stringsAsFactors = FALSE
    )
  ) %>%
  {suppressWarnings(classify(., "elixhauser"))}

test_that("Subordinate indices", {
  expect_equivalent(index(y, "sum_all"), c(1, 1, 1, 1, 1, 1))
  expect_equivalent(index(y, "walraven"), c(4, 12, 0, 0, 12, 0))

})