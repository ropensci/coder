x <- summary(elixhauser, "icd10cm")

test_that("summary.classcodes", {

  expect_is(x, "summary.classcodes")
  expect_equal(x$object, elixhauser)
  expect_equal(x$coding, "icd10cm")
  expect_message(
    summary(elixhauser, "icd10cm"),
    "Classification based on: icd10"
  )

  expect_error(summary(elixhauser, coding = "hej"), "'coding' should be one of")
  expect_equal(
    x$summary,
    summary(elixhauser, coding = decoder::icd10cm$key)$summary
  )
})


test_that("print.summary.classcodes", {
  expect_output(
    print(x),
    "Summary of classcodes object",
    fixed = TRUE
  )
})
