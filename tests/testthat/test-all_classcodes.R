ac <- all_classcodes()

test_that("multiplication works", {
  expect_named(ac, c("classcodes", "regex", "indices"))
  expect_gte(nrow(ac), 8)
  expect_true(
    all(c("charlson", "cps", "elixhauser", "ex_carbrands", "hip_ae",
      "hip_ae_hailer", "knee_ae", "rxriskv") %in% ac$classcodes)
  )
})
