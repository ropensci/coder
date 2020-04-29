context("classcodes")


test_that("classcodes", {
  expect_is(as.classcodes(elixhauser), "classcodes")
  expect_error(as.classcodes(iris))
  expect_true(is.classcodes(elixhauser))
  expect_false(is.classcodes(iris))
  expect_length(elixhauser[1,1:2], 2)
  expect_error(elixhauser[1,1])
  expect_silent({elixhauser[1,1] <- "hej"; elixhauser})
})
