if (requireNamespace("testthat", quietly = TRUE)) {
  library(testthat)
  
  test_that("spam_dataloader works as expected", {
    
    loader <- spam_dataloader(download = TRUE)
    
    iter <- dataloader_make_iter(loader)
    batch <- dataloader_next(iter)
    
    expect_equal(dim(batch$x), c(32, 57))
    
    expect_equal(length(batch$y), 32)
    
    expect_true(all(as.array(batch$y) %in% c(0, 1)))
  })
}
