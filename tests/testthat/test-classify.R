context("classify")

x <- codify(ex_people, ex_icd10, id = "name",
       date = "surgery", days = c(-365, 0))

test_that("classify", {
  expect_equal(
    elix_icd10$group[which(classify("C80", "elix_icd10"))],
    "metastatic cancer"
  )
  expect_is(classify(x, "elix_icd10"), "matrix")
  expect_error(
    classify(x, "hip.ae_icd10", id = "name"),
    "Classification is conditioned on variables not found in the data set!"
  )
})
