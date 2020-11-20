test_that("visualize", {
  expect_match(
    visualize("hip_ae", show = FALSE),
    "https"
  )

  expect_match(
    visualize("charlson", "AIDS/HIV", show = FALSE),
    "re=%5E\\(%5E\\(B2\\[0124\\]\\)\\)"
  )
})
