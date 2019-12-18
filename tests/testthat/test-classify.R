context("classify")

x <- codify(ex_people, ex_icd10, id = "name",
       date = "surgery", days = c(-365, 0))

test_that("classify", {
  expect_equal(
    elixhauser$group[which(classify("C80", "elixhauser"))],
    "metastatic cancer"
  )
  expect_is(suppressWarnings(classify(x, "elixhauser")), "matrix")
  expect_error(
    suppressWarnings(classify(x, "hip_ae", id = "name")),
    "Classification is conditioned on variables not found in the data set!"
  )
})
