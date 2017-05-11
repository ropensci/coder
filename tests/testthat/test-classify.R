context("classify")

x <- codify(ex_people, ex_icd10, id = "name",
       date = "surgery", days = c(-365, 0))

test_that("classify", {
  expect_equal(
    elix_icd10$group[which(classify("C80", "elix_icd10"))],
    "metastatic cancer"
  )
  expect_is(classify(x, "elix_icd10"), "matrix")
  expect_is(classify(x, "hip_adverse_events_icd10_old"), "matrix")
  expect_error(
    classify(x, "hip_adverse_events_icd10", id = "name"),
    "Classification is conditioned on variables not found in the data set!"
  )
})


################################################################################
#                                                                              #
#                       Test without suggested packages                        #
#                                                                              #
################################################################################

elix <- classify(x, "elix_icd10")
adv  <- classify(x, "hip_adverse_events_icd10_old")

stop_suggests()

test_that("Without suggested packages", {
  expect_equal(classify(x, "elix_icd10"), elix)
  expect_equal(classify(x, "hip_adverse_events_icd10_old"), adv)
})

start_suggests()
