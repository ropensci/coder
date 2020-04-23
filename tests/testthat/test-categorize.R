

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
    nrow(categorize(ex_people, ex_icd10, "elixhauser", id = "name")),
    nrow(ex_people)
  )
})
