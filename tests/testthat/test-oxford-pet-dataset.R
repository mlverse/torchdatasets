test_that("oxford pet dataset", {

  root <- tempfile()

  train <- oxford_pet_dataset(
    root = root,
    download = TRUE,
    transform = torchvision::transform_to_tensor,
    target_transform = torchvision::transform_to_tensor
  )

  valid <- oxford_pet_dataset(
    root = root,
    split = "valid",
    download = FALSE,
    transform = torchvision::transform_to_tensor,
    target_transform = torchvision::transform_to_tensor
  )

  expect_tensor_shape(train[1][[1]], c(3, 500, 394))
  expect_tensor_shape(train[1][[2]], c(1, 500, 394))

  expect_tensor_shape(valid[1][[1]], c(3, 225, 300))
  expect_tensor_shape(valid[1][[2]], c(1, 225, 300))
})
