context("classcodes")

test_that("classcodes", {
  expect_is(as.classcodes(elixhauser), "classcodes")
  expect_error(as.classcodes(iris))
  expect_true(is.classcodes(elixhauser))
  expect_false(is.classcodes(iris))
})
