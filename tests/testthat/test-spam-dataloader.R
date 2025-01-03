test_that("spam_dataloader loads and batches data correctly", {
  # Create the dataloader
  dl <- spam_dataloader(batch_size = 32, shuffle = TRUE, download = TRUE)
  expect_true(inherits(dl, "dataloader"), "The returned object is not a dataloader.")

  # Get a batch
  iter <- dl$.iter()
  batch <- iter$.next()

  # Verify batch structure
  expect_true(is.list(batch), "Batch should be a list.")
  expect_equal(length(batch), 2, "Batch should have predictors (x) and targets (y).")

  # Check tensor dimensions
  dim_x <- batch[[1]]$dim()
  expect_true(length(dim_x) == 2, "Predictors tensor should have 2 dimensions.")
  expect_true(!is.na(dim_x[2]), "Predictors tensor should have a valid second dimension.")
  expect_equal(dim_x[2], 57, "Predictors tensor should have 57 features.")
  expect_equal(batch[[1]]$size(1), 32, "Batch size for predictors (x) should match 32.")
  expect_equal(batch[[2]]$size(1), 32, "Batch size for targets (y) should match 32.")

  # Check tensor data types
  expect_true(batch[[1]]$dtype() == torch_float(), "Predictors tensor should have dtype torch_float.")
  expect_true(batch[[2]]$dtype() == torch_long(), "Targets tensor should have dtype torch_long.")

  # Check target values
  expect_true(all(batch[[2]]$to(dtype = torch_int())$numpy() %in% c(0, 1)),
              "Targets should only contain binary values (0, 1).")
})