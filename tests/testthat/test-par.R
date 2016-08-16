context("par")

N <- 1e3
set.seed(1)

# Generate som e fake data to use for testing
pardata <- data.frame(lpnr = seq_len(N), indatum = Sys.Date())
diadata <- matrix(sample(ex_icd10$code, 16 * N, replace = TRUE), N)
colnames(diadata) <- c("hdia", paste0("bdia", 1:15))
pardata <- cbind(pardata, diadata)

test_that("handle data from PAR", {
  expect_is(as.pardata(pardata), "pardata")
  expect_silent(as.pardata(pardata))
  expect_equal(ncol(as.pardata(pardata)), 18)
  expect_error(as.pardata(iris))
  expect_true(is.pardata(as.pardata(pardata)))
  expect_false(is.pardata(pardata))
})
