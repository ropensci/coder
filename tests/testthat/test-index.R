context("index")
y <-
  codify(ex_people, ex_icd10, id = "name", code = "icd10",
    date = "surgery", code_date = "admission", days = c(-365, 0)) %>%
  {suppressWarnings(classify(., "charlson"))}

test_that("Charlson", {
  suppressWarnings(
    expect_gte(
      sum(index(y, "charlson"), na.rm = TRUE),
      sum(index(y, "ghali"),  na.rm = TRUE)
    )
  )
  expect_error(index(y, "hej"), "is not a column of the classcodes object!")
  expect_message(index(y), "index calculated as number of relevant categories")
  expect_equal(index(y), index(as.data.frame(y)))
  expect_message(index(as.data.frame(y)), "column 'name' used as id!")

  expect_error(
    index(y, "index_sid30", cc = elixhauser),
    "Data non consistent with specified classcodes!"
  )
})



# Subordinate hierarchical classes ----------------------------------------

y <-
  codify(
    data.frame(id = letters[1:6], stringsAsFactors = FALSE),
    data.frame(
      id   = c( "a",    "a",   "b",   "c",     "d",    "d",    "e",    "f"),
      code = c("C01", "C80", "C01", "C80",  "E100", "E102", "E100", "E102"),
      stringsAsFactors = FALSE
    ),
    id = "id", code = "code"
  ) %>%
  {suppressWarnings(classify(., "elixhauser"))}

test_that("Subordinate indices", {
  expect_equivalent(index(y, "sum_all"), c(1, 1, 1, 1, 1, 1))
  expect_equivalent(index(y, "walraven"), c(4, 12, 0, 0, 12, 0))

})
