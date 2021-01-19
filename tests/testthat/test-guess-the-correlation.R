test_that("guess_the_correlation_dataset works", {

  dataset <- guess_the_correlation_dataset(
    root = tempfile(),
    download = TRUE,
    transform = function(x) torch::torch_zeros(3,3)
  )

  expect_length(dataset$.getitem(1), 3)
  expect_equal(dim(dataset$.getitem(1)$x), c(3,3))
  expect_true(dataset$.getitem(1)$y$dtype == torch::torch_float())

})
