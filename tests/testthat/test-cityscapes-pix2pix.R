test_that("cityscapes_pix2pix works", {

  root <- tempfile()

  train <- cityscapes_pix2pix_dataset(
    root = root,
    download = TRUE,
    transform = torchvision::transform_to_tensor,
    target_transform = torchvision::transform_to_tensor
  )

  valid <- cityscapes_pix2pix_dataset(
    root = root,
    split = "valid",
    download = FALSE,
    transform = torchvision::transform_to_tensor,
    target_transform = torchvision::transform_to_tensor
  )

  expect_tensor_shape(train[1][[1]], c(3, 256, 256))
  expect_tensor_shape(train[1][[2]], c(3, 256, 256))

  expect_tensor_shape(valid[1][[1]], c(3, 256, 256))
  expect_tensor_shape(valid[1][[2]], c(3, 256, 256))
})
