context("codedata")

ex_icd102 <- ex_icd10
ex_icd102$code <- paste(".+? ", ex_icd10$code, "---")

suppressMessages(
  test_that("Codedata", {
    expect_true(is.codedata(ex_icd10))
    expect_error(as.codedata(iris))
    expect_silent(as.codedata(ex_icd10))
    expect_silent(as.codedata(as.data.frame(ex_icd10)))
    expect_is(as.codedata(as.data.frame(ex_icd10)), "data.table")

    expect_true(
      nrow(as.codedata(ex_icd10, from = "2020-01-01")) <
      nrow(as.codedata(ex_icd10))
    )

    expect_equal(
      as.codedata(ex_icd10),
      as.codedata(ex_icd10, alnum = TRUE)
    )
    expect_true(
      all(
        as.codedata(ex_icd102)$code !=
        as.codedata(ex_icd102, alnum = TRUE)$code
      )
    )


  })
)

