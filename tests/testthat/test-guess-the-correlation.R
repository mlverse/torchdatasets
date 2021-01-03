test_that("guess_the_correlation_dataset works", {

  dataset <- guess_the_correlation_dataset(
    root = tempfile(),
    token = "kaggle.json",
    download = TRUE
  )

  expect_length(dataset$.getitem(1), 3)

})
