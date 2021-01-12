test_that("guess_the_correlation_dataset works", {

  dataset <- guess_the_correlation_dataset(
    root = tempfile(),
    download = TRUE
  )

  expect_length(dataset$.getitem(1), 3)
  expect_true(dataset$.getitem(1)$y$dtype == torch::torch_float())


})
