context("misc")

y <- x <-
  codify(ex_people, ex_icd10, id = "name", date = "surgery", days = c(-365, 0))

x <- classify(x, "elix_icd10")
y <- classify(y, elix_icd10)


test_that("get_classcodes", {
  expect_error(get_classcodes("hejsan"))
  expect_equal(get_classcodes("elix_icd10"), elix_icd10)
  expect_equal(get_classcodes(elix_icd10), elix_icd10)
  expect_equal(get_classcodes(NULL, x), elix_icd10)
  expect_equal(get_classcodes(NULL, y), elix_icd10)
})



test_that("suggest_install", {
  expect_true(suggest_install("base"))
  expect_silent(suggest_install("base"))
})


test_that("rbind.fill", {
  expect_equal(
    rbind.fill(
      data.frame(a = 1, b = 2, c = 3),
      data.frame(a = 5, c = 7)
    ),
    data.frame(a = c(1, 5), b = c(2, NA), c = c(3, 7))
  )
  expect_equal(
    rbind.fill(
      data.frame(a = 1, b = 2, c = 3),
      data.frame(a = 5, c = 7),
      data.frame(e = 45)
    ),
    data.frame(
      a = c(1, 5, NA),
      b = c(2, NA, NA),
      c = c(3, 7, NA),
      e = c(NA, NA, 45))
  )
})
