context("codify")

x <- codify(ex_people, ex_icd10, id = "name",
            date = "event", days = c(-365, 0))

test_that("codify", {
  expect_silent(codify(ex_people, ex_icd10, id = "name",
    date = "event", days = c(-365, 0)))
  expect_is(x, "data.frame")

  # Codes within one year before (i e comorbidities)
  expect_equal(
    nrow(codify(ex_people[1, ], ex_icd10, id = "name",
           date = "event", days = c(-365, 0))),
    1
  )

  # Codes within 30 days after (i e adverse events)
  expect_equal(
    nrow(codify(ex_people[1, ], ex_icd10, id = "name",
                date = "event", days = c(0, 30))),
    1
  )

  # all codes
  expect_equal(
    nrow(codify(ex_people[1, ], ex_icd10, id = "name",
                date = "event", days = c(-Inf, Inf))),
    1
  )

})

# missing dates
# Take minimal data set of people and mask one date
pe <- coder::ex_people[1:2,]
pe$surgery[1] <- NA

# Mask half of the dates from ICD10
icd <- coder::ex_icd10
icd$code_date[1:500] <- NA


test_that("missing dates", {

  # Include all dates except missing
  expect_equal(
    nrow(codify(pe, icd, id = "name",
                date = "event", days = c(-Inf, Inf))),
    2
  )

  # Include all cases, no mather the date
  expect_warning(codify(pe, icd, id = "name", date = "event", days = NULL))
  expect_silent(codify(pe, icd, id = "name"))
  suppressWarnings(
    expect_equal(
      nrow(codify(pe, icd, id = "name", date = "event", days = NULL)),
      3
    )
  )


  expect_error(
    codify(ex_people, ex_icd10, id = "wrong", date = "event"),
    "No id column 'wrong' in data!"
  )
  ex_people$wrong_class <- as.numeric(as.factor(ex_people$name))
  expect_error(
    codify(ex_people, ex_icd10, id = "wrong_class", date = "event"),
    "Id column must be of type character!"
  )
  expect_error(
    codify(ex_people, ex_icd10, id = "name", days = c(-10, 10)),
    "Argument 'date' must be specified if 'days' is not NULL!"
  )
  ex_people$wrong_date <- as.character(ex_people$event)
  expect_error(
    codify(ex_people, ex_icd10, id = "name",
           date = "wrong_date", days = c(-10, 10)),
    "Date column 'wrong_date' is not of class 'Date'!"
  )

  expect_equal(
    codify(ex_people, ex_icd10, id = "name"),
    codify(ex_people, as.data.frame(ex_icd10), id = "name")
  )
})
