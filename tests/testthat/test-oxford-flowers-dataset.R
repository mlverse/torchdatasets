test_that("oxford flowers dataset", {

  root <- tempfile()

  train <- oxford_flowers102_dataset(
    root = root,
    download = TRUE
  )

  valid <- oxford_flowers102_dataset(
    root = root,
    split = "valid",
    download = FALSE,
    transform = torchvision::transform_to_tensor
  )

  test <- oxford_flowers102_dataset(
    root = root,
    split = "test",
    download = FALSE,
    transform = torchvision::transform_to_tensor
  )

  all <- oxford_flowers102_dataset(
    root = root,
    split = c("train", "valid", "test"),
    download = FALSE,
    transform = torchvision::transform_to_tensor
  )

  expect_equal(train$classes[train[1]$y], "pink primrose")

  expect_equal(length(all), 8189)
  expect_equal(length(valid), 1020)
  expect_equal(length(train), 1020)
  expect_equal(length(test), 6149)

  expect_tensor_shape(train[1][[1]], c(3, 500, 754))
  expect_tensor_shape(valid[1][[1]], c(3, 500, 606))
  expect_tensor_shape(all[1][[1]], c(3, 500, 754))
})
