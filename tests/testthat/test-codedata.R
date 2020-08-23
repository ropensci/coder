context("codedata")

ex_icd102 <- ex_icd10


suppressMessages(
  test_that("Codedata", {
    expect_true(is.codedata(ex_icd10))
    expect_error(as.codedata(iris))
    expect_silent(as.codedata(ex_icd10))
    expect_silent(as.codedata(as.data.frame(ex_icd10)))
    expect_is(as.codedata(as.data.frame(ex_icd10)), "data.table")

    expect_true(
      nrow(as.codedata(ex_icd10, period = c(as.Date("2020-01-01"), Sys.Date()))) <
      nrow(as.codedata(ex_icd10))
    )

    expect_equal(
      as.codedata(ex_icd10),
      as.codedata(ex_icd10, alnum = TRUE)
    )

    ex_icd102$code <- paste(".+? ", ex_icd10$code, "---")
    expect_true(
      all(
        as.codedata(ex_icd102)$code !=
        as.codedata(ex_icd102, alnum = TRUE)$code
      )
    )

    ex_icd102$code_date <- as.character(ex_icd10$code_date)
    expect_error(
      as.codedata(ex_icd102),
      "Column 'code_date' is not of format 'Date'!", fixed = TRUE
    )

    ex_icd102$code_date <- as.Date(ex_icd102$code_date)
    ex_icd102$id <- as.numeric(as.factor(ex_icd102$id))
    expect_error(as.codedata(ex_icd102), "Column 'id' must be character!")
  })
)

