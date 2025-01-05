if (requireNamespace("testthat", quietly = TRUE)) {
  library(testthat)
  
  test_that("spam_dataloader works as expected", {
    skip_on_cran()  # Skip if running on CRAN to avoid download overhead
    
    # Instantiate dataloader
    loader <- spam_dataloader(download = TRUE)
    
    # Get the first batch
    iter <- dataloader_make_iter(loader)
    batch <- dataloader_next(iter)
    
    # Check batch dimensions (32 x 57 by default)
    expect_equal(dim(batch$x), c(32, 57))
    
    # Check length of target
    expect_equal(length(batch$y), 32)
    
    # Verify binary labels
    expect_true(all(as.array(batch$y) %in% c(0, 1)))
  })
}
