
x <- codify(ex_people, ex_icd10, id = "name",
            date = "event", days = c(-365, 0))


test_that("categorize", {
  expect_message(
    categorize(ex_people, ex_icd10, "elixhauser", id = "name"),
    "Classification based on: regex_icd10"
  )
  expect_error(
    categorize(ex_people, ex_icd10, "elixhauser", id = "wrong")
  )
  suppressMessages(
    expect_error(
      categorize(ex_people[c(1, 1), ], ex_icd10, "elixhauser", id = "name"),
      "Non-unique ids!"
    )

  )
  expect_equal(
    ncol(categorize(ex_people, ex_icd10, "elixhauser",
                    id = "name", index = "index_sid30")),
    34
  )

  expect_equal(
    ncol(categorize(ex_people, ex_icd10, "elixhauser", id = "name")),
    40
  )

  expect_equal(
    names(
      categorize(ex_people, ex_icd10, "elixhauser", id = "name",
                    cc_args = list(regex = "regex_icd10", tech_names = TRUE))
    )[3],
    "elixhauser_regex_icd10_congestive_heart_failure"
  )

  expect_equal(
    nrow(categorize(ex_people, ex_icd10, "elixhauser", id = "name")),
    nrow(ex_people)
  )

  expect_warning(
    categorize(x, "charlson", id = "name"),
    "Output might contain extra columns as left-overs"
  )

  expect_identical(
    suppressWarnings(categorize(x, "charlson", id = "name")[,-"hdia"]),
    categorize(ex_people, ex_icd10, "charlson", id = "name", codify_args = list(date = "event", days = c(-365, 0)))
  )
})
