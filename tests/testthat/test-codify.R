context("codify")

x <- codify(ex_people, ex_icd10, id = "name",
            date = "surgery", days = c(-365, 0))

test_that("codify", {
  expect_silent(codify(ex_people, ex_icd10, id = "name",
    date = "surgery", days = c(-365, 0)))
  expect_is(x, "data.frame")

  # Codes within one year before (i e comorbidities)
  expect_equal(
    nrow(codify(ex_people[1, ], ex_icd10, id = "name",
           date = "surgery", days = c(-365, 0))),
    2
  )

  # Codes within 30 days after (i e adverse events)
  expect_equal(
    nrow(codify(ex_people[1, ], ex_icd10, id = "name",
                date = "surgery", days = c(0, 30))),
    1
  )

  # all codes
  expect_equal(
    nrow(codify(ex_people[1, ], ex_icd10, id = "name",
                date = "surgery", days = c(-Inf, Inf))),
    3
  )

})

# missing dates
set.seed(1)
ex_people$surgery[sample(nrow(ex_people), 50)] <- NA
ex_icd10$date[sample(nrow(ex_icd10), 500)] <- NA


test_that("missing dates", {
  expect_equal(
    nrow(codify(ex_people, ex_icd10, id = "name",
                date = "surgery", days = c(-Inf, Inf))),
    137
  )
  expect_equal(
    nrow(codify(ex_people, ex_icd10, id = "name",
                date = "surgery", days = NULL)),
    512
  )
})

################################################################################
#                                                                              #
#                       Test without suggested packages                        #
#                                                                              #
################################################################################

ex_people <- classifyr::ex_people
ex_icd10 <- classifyr::ex_icd10

x <- codify(ex_people[1, ], ex_icd10, id = "name",
       date = "surgery", days = c(-Inf, Inf))

stop_suggests()

x2 <- codify(ex_people[1, ], ex_icd10, id = "name",
            date = "surgery", days = c(-Inf, Inf))

test_that("Without suggested packages", {
  expect_equal(x, x2)


  # still works with no cases outside period
  expect_equal(
    nrow(
      codify(
        data.frame(id = 1, date = as.Date("2016-08-23")),
        as.codedata(
          data.frame(id = 1, date = as.Date("2016-01-01"), code = "hej")
        ),
        date = "date",
        days = c(-1, 0)
      )
    ),
    1
  )
})

start_suggests()
