test_that("spam_dataset works as expected", {
  
  dataset <- spam_dataset(download = TRUE)
  
  iter <- dataloader_make_iter(dataset)
  batch <- dataloader_next(iter)
  
  expect_equal(dim(batch$x), c(32, 57))
  
  expect_equal(length(batch$y), 32)
  
  expect_true(all(as.array(batch$y) %in% c(0, 1)))
})
