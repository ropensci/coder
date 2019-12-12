context("misc")

y <- x <-
  codify(ex_people, ex_icd10, id = "name", date = "surgery", days = c(-365, 0))

x <- classify(x, "elix_icd10")
y <- classify(y, elix_icd10)


test_that("get_classcodes", {
  expect_error(get_classcodes("hejsan"))
  expect_equal(get_classcodes("elix_icd10"), get_classcodes(elix_icd10))
  expect_equal(get_classcodes(NULL, x), get_classcodes(elix_icd10))
  expect_equal(get_classcodes(NULL, y), get_classcodes(elix_icd10))
})

