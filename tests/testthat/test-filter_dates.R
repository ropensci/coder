x <- as.Date(c("2017-02-02", "2050-02-02", "1969-02-02"))


test_that("filter_dates", {
  expect_equal(filter_dates(x), as.Date(c("2017-02-02", NA, NA)))
  expect_equal(filter_dates(x, na.rm = TRUE), as.Date("2017-02-02"))
  expect_equal(nrow(suppressWarnings(
    filter_dates(data.frame(date = x, foo  = 1:3)))), 1)
  expect_warning(
    filter_dates(data.frame(date = x, foo  = 1:3)),
    "Dates outside specified limits dropped"
  )
  expect_silent(filter_dates(data.frame(date = as.Date("1985-05-04"), foo = 1)))
  expect_equal(
    nrow(filter_dates(data.frame(date = as.Date("1985-05-04"), foo = 1))), 1)
  expect_error(
    filter_dates(iris), 'date" %in% names(x) is not TRUE', fixed = TRUE
  )
})
