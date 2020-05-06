test_that("visualize", {
  expect_match(
    visualize("hip_ae", show = FALSE),
    "https"
  )
})
