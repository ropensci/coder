context("classify")


ex_people$wrong_id <- 1
x <- codify(ex_people, ex_icd10, id = "name",
       date = "event", days = c(-365, 0))

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
  expect_error(
    suppressWarnings(classify(x, "elixhauser", id = "wrong")),
      "wrong should specify case id but is not a column of x!"
  )
  expect_error(
    suppressWarnings(classify(x, "elixhauser", id = "wrong_id")),
    "Id column 'wrong_id' must be of type character!"
  )
  expect_error(
    suppressWarnings(classify(x, "elixhauser", code = "wrong")),
    "wrong should specify codes but is not a column of x!"
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


# condition ---------------------------------------------------------------

set.seed(123)

people <-
  data.frame(
    name = c(
      "Medina, Desmand", "al-Hashem,  Muzna",
      "el-Kaleel, Aadil", "Pettsson, Svenne"
    ),
    license = as.Date(c(
      "1949-05-23", "2016-03-04", "2019-12-18", "1985-05-04"
    )),
    cond1 = TRUE,
    cond2 = FALSE,
    cond3 = NA,
    stringsAsFactors = FALSE
  )

cd <- codify(people, ex_cars, id = "name")

# Use diff
test_that("condition", {

  ex_carbrands$condition <- "cond1"
  expect_equal(
    sum(suppressWarnings(classify(cd, ex_carbrands)), na.rm = TRUE),
    5
  )

  ex_carbrands$condition <- "cond2"
  expect_equal(
    sum(suppressWarnings(classify(cd, ex_carbrands)), na.rm = TRUE),
    0
  )

  ex_carbrands$condition <- "cond3"
  expect_true(
    all(suppressWarnings(classify(cd, ex_carbrands)) %in% c(NA, FALSE))
  )
})


