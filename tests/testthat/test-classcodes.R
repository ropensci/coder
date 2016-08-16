context("classcodes")

test_that("classcodes", {
  expect_is(as.classcodes(elix_icd10), "classcodes")
  expect_error(as.classcodes(iris))
  expect_true(is.classcodes(elix_icd10))
  expect_false(is.classcodes(iris))
})
