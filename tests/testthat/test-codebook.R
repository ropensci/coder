cb <- codebook(elixhauser, "icd10cm")
cb2 <- codebook(elixhauser, "icd9cmd",
         cc_args = list(regex = "regex_icd9cm_enhanced")
)

cbs <- codebooks(cb1 = cb, cb2 = cb2)

test_that("codebook", {
  expect_is(cb, "list")
  expect_named(cb, c("readme", "summary", "all_codes"))
  expect_named(
    cbs,
    c("README", "cb1.summary", "cb1.all_codes", "cb2.summary", "cb2.all_codes")
  )
})
