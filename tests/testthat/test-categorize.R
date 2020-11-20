x <- codify(ex_people, codedata = ex_icd10, id = "name", code = "icd10",
            date = "surgery", code_date = "admission", days = c(-365, 0))


test_that("categorize", {

  expect_equivalent(
    categorize(
      ex_people, codedata = ex_icd10, cc = "elixhauser",
      id = "name", code = "icd10"
    ),
    categorize(
      as.data.frame(ex_people), codedata = ex_icd10, cc = "elixhauser",
      id = "name", code = "icd10"
    )
  )
  expect_message(
    categorize(
      ex_people, codedata = ex_icd10, cc = "elixhauser",
      id = "name", code = "icd10"
    ),
    "Classification based on: icd10"
  )
  expect_error(
    categorize(ex_people, ex_icd10, "elixhauser", id = "wrong")
  )
  suppressMessages(
    expect_error(
      categorize(
        ex_people[c(1, 1), ],
        codedata = ex_icd10,
        cc = "elixhauser",
        id = "name",
        code = "icd10"
      ),
      "Non-unique ids!"
    )

  )
  expect_equal(
    ncol(categorize(ex_people, codedata = ex_icd10, cc = "elixhauser",
                    id = "name", code = "icd10", index = "sid30")),
    34
  )

  expect_equal(
    ncol(categorize(ex_people, codedata = ex_icd10, cc = "elixhauser",
                    id = "name", code = "icd10")),
    40
  )

  expect_equal(
    names(
      categorize(
        ex_people, codedata = ex_icd10, cc = "elixhauser",
        id = "name", code = "icd10",
        cc_args = list(regex = "icd10", tech_names = TRUE))
    )[3],
    "elixhauser_icd10_congestive_heart_failure"
  )

  expect_equal(
    nrow(categorize(ex_people, codedata = ex_icd10, cc = "elixhauser",
                    id = "name", code = "icd10")),
    nrow(ex_people)
  )

  expect_warning(
    categorize(x, cc = "charlson"),
    "Output might contain extra columns as left-overs"
  )

  expect_identical(
    suppressWarnings(
      categorize(x, cc = "charlson")[, -c("hdia", "admission", "icd10")] %>%
        tibble::as_tibble() %>%
        {.[order(.$name), ]}
    ),
    categorize(
      ex_people, codedata = ex_icd10, cc = "charlson", id = "name",
      code = "icd10",
      codify_args = list(
        date = "surgery", code_date = "admission", days = c(-365, 0))
    ) %>%
    {.[order(.$name), ]}
  )
})

# COmbination of cc without indices and index argument unspecified should
# yield unweighted index
ch <- as.classcodes(charlson, indices = NULL)
test_that("unspecified indices", {
  expect_message(
    suppressWarnings(categorize(x, cc = ch)),
    "index calculated as number of relevant categories"
  )
})
