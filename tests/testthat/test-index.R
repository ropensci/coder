context("index")

x <-
  codify(ex_people, ex_icd10, id = "name",
    date = "surgery", days = c(-365, 0)) %>%
  classify("hip_adverse_events_icd10_old")

y <-
  codify(ex_people, ex_icd10, id = "name",
    date = "surgery", days = c(-365, 0)) %>%
  classify("charlson_icd10")

test_that("index", {
  expect_message(index(x),
    "index calculated as number of relevant categories")
  expect_is(index(x), "numeric")
  suppressWarnings(
    expect_gte(
      sum(index(y, "charlson"), na.rm = TRUE),
      sum(index(y, "ghali"),  na.rm = TRUE)
    )
  )
  expect_error(index(x, "hej"), "is not a column of the classcodes object!")
  expect_error(index(x, "charlson", "charlson_icd10"),
    "Data non consistent with specified classcodes!")

})

