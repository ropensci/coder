ex_people$wrong_id <- 1
x <-
  codify(
    ex_people, ex_icd10, id = "name",
    date = "surgery", code_date = "admission",
    code = "icd10", days = c(-365, 0)
  )

test_that("classify", {
  expect_equal(
    elixhauser$group[which(classify("C80", "elixhauser"))],
    "metastatic cancer"
  )
  expect_is(suppressWarnings(classify(x, "elixhauser")), "matrix")
  expect_error(
    suppressWarnings(classify(x, "hip_ae")),
    "Classification is conditioned on variables not found in the data set!"
  )
  expect_error(
    suppressWarnings(classify(x, "elixhauser", id = "wrong")),
  )
    # Result should be matrix even if only one item has multiple codes
  expect_equal(
    class(suppressWarnings(classify(x, "elixhauser"))),
    class(suppressWarnings(classify(x[1:2], "elixhauser")))
  )
})




cl <- suppressWarnings(classify(x, "elixhauser"))

test_that("df/dt", {
  expect_s3_class(cl, "matrix")
  expect_s3_class(as.data.frame(cl), "data.frame")
  expect_s3_class(as.data.table(cl), "data.table")
  expect_equal(nrow(cl), nrow(as.data.frame(cl)))
  expect_equal(nrow(cl), nrow(as.data.table(cl)))
  # ncol off by 1 since matrix row names is column in data.frame
  expect_equal(ncol(cl) + 1, ncol(as.data.frame(cl)))
  expect_equal(ncol(cl) + 1, ncol(as.data.table(cl)))
})
