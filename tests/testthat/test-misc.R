context("misc")

y <- x <-
  codify(ex_people, ex_icd10, id = "name", date = "surgery", days = c(-365, 0))

x <- classify(x, "elixhauser")
y <- classify(y, elixhauser)


test_that("get_classcodes", {
  expect_error(get_classcodes("hejsan"))
  expect_equal(get_classcodes("elixhauser"), get_classcodes(elixhauser))
  expect_equal(get_classcodes(NULL, x), get_classcodes(elixhauser))
  expect_equal(get_classcodes(NULL, y), get_classcodes(elixhauser))
})

