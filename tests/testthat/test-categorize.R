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
})


# No index ----------------------------------------------------------------

set.seed(123)

people <-
  data.frame(
    name = c(
      "Medina, Desmand", "al-Hashem,  Muzna",
      "el-Kaleel, Aadil", "Pettsson, Svenne"
    ),
    license = as.Date(c(
      "1949-05-23", "2016-03-04", "2019-12-18", "1985-05-04"
    )),
    cond1 = TRUE,
    cond2 = FALSE,
    cond3 = NA,
    stringsAsFactors = FALSE
  )
test_that("", {
  expect_message(
    categorize(people, ex_cars, ex_carbrands, id = "name"),
    "index calculated as number of relevant categories"
    )
})
