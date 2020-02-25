context("misc")

y <- x <-
  codify(ex_people, ex_icd10, id = "name", date = "event", days = c(-365, 0))

x <- suppressWarnings(classify(x, "elixhauser"))

y <- suppressWarnings(classify(y, elixhauser))

test_that("get_classcodes", {
  expect_error(set_classcodes("hejsan"))
  expect_equal(set_classcodes("elixhauser"), set_classcodes(elixhauser))
  expect_equal(set_classcodes(NULL, x),      set_classcodes(elixhauser))
  expect_equal(set_classcodes(NULL, y),      set_classcodes(elixhauser))
})

