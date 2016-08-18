context("codedata")

N <- 100
set.seed(1)

# Generate som e fake data to use for testing
pardata <- data.frame(lpnr = seq_len(N), indatum = Sys.Date(),
             stringsAsFactors = FALSE)
diadata <- matrix(sample(ex_icd10$code, 16 * N, replace = TRUE), N)
colnames(diadata) <- c("hdia", paste0("bdia", 1:15))
pardata <- as.pardata(cbind(pardata, diadata, stringsAsFactors = FALSE))

test_that("codedata", {
  expect_is(as.codedata(pardata), "data.frame") %>%
  expect_silent()
  expect_equal(nrow(as.codedata(pardata)), 1600)
})



################################################################################
#                                                                              #
#                       Test without suggested packages                        #
#                                                                              #
################################################################################

cd <- as.codedata(pardata)

stop_suggests()
cd2 <- as.codedata(pardata)

test_that("Without suggested packages", {
  expect_equal(cd, cd2)
})

start_suggests()
