
################################################################################
#                                                                              #
#                               Testing NPR data                               #
#                                                                              #
################################################################################

context("codedata")

N <- 1e3
set.seed(1)

# Generate som e fake data to use for testing
pardata <- data.frame(lpnr = seq_len(N), indatum = Sys.Date())
diadata <- matrix(sample(ex_icd10$code, 16 * N, replace = TRUE), N)
colnames(diadata) <- c("hdia", paste0("bdia", 1:15))
pardata <- cbind(pardata, diadata)

suppressMessages(
  test_that("handle data from PAR", {
    expect_true(is.codedata(as.codedata(pardata)))
    expect_message(as.codedata(pardata))
    expect_equal(ncol(as.codedata(pardata)), 5)
    expect_equal(nrow(as.codedata(pardata)), 15863)
    expect_error(as.codedata(iris))
  })
)

################################################################################
#                                                                              #
#                       Test without suggested packages                        #
#                                                                              #
################################################################################

cd <- as.codedata(pardata)

stop_suggests()
cd2 <- as.codedata(pardata)

test_that("Without suggested packages", {
  expect_equal(dim(cd), dim(cd2))
})

start_suggests()

