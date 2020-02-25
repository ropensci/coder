context("index")
y <-
  codify(ex_people, ex_icd10, id = "name",
    date = "event", days = c(-365, 0)) %>%
  {suppressWarnings(classify(., "charlson"))}

test_that("index", {
  suppressWarnings(
    expect_gte(
      sum(index(y, "charlson"), na.rm = TRUE),
      sum(index(y, "ghali"),  na.rm = TRUE)
    )
  )
  expect_error(index(y, "hej"), "is not a column of the classcodes object!")
})
