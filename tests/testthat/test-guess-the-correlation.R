test_that("guess_the_correlation_dataset works", {

  dataset <- guess_the_correlation_dataset(
    root = tempfile(),
    token = "kaggle.json",
    download = TRUE,
    transform = function(x) torch::torch_zeros(3,3)
  )
  one_item <- dataset$.getitem(1)
  expect_length(one_item, 3)
  expect_equal(dim(one_item$x), c(3,3))

})
