context("codedata")

suppressMessages(
  test_that("Codedata", {
    expect_true(is.codedata(ex_icd10))
    expect_error(as.codedata(iris))
  })
)
