context("codedata")

N <- 1e3
set.seed(1)

# Generate som e fake data to use for testing
pardata <- data.frame(lpnr = seq_len(N), indatuma = as.Date("2018-03-07"))
diadata <- matrix(sample(ex_icd10$code, 22 * N, replace = TRUE), N)
colnames(diadata) <- c("hdia", paste0("bdia", 1:21))
pardata <- cbind(pardata, diadata)

suppressMessages(
  test_that("handle data from PAR", {
    expect_true(is.codedata(as.codedata(pardata, npr = TRUE)))
    expect_message(as.codedata(pardata, npr = TRUE))
    expect_equal(ncol(as.codedata(pardata, npr = TRUE)), 4)
    expect_equal(nrow(as.codedata(pardata, npr = TRUE)), 21739)
    expect_error(as.codedata(iris))
  })
)
