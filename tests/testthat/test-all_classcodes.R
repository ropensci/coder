ac <- all_classcodes()

test_that("all_classcodes", {
  expect_named(ac, c("classcodes", "regex", "indices"))
  expect_gte(nrow(ac), 7)
  expect_true(
    all(c("charlson", "cps", "elixhauser", "hip_ae",
      "hip_ae_hailer", "knee_ae", "rxriskv") %in% ac$classcodes)
  )
})
