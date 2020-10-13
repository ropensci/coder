
a <- decoder::as.keyvalue(elixhauser, "icd10se")


test_that("as.keyvalue", {
  expect_message(
    decoder::as.keyvalue(elixhauser, "icd10se"),
    "Classification based on: icd10"
  )
  expect_s3_class(a, "keyvalue")
  expect_gte(nrow(a), 1500)
})

