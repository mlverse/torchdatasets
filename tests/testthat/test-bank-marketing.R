test_that("bank marketting works", {

  data <- bank_marketing_dataset(
    root = tempfile(),
    download = TRUE
  )

  expect_length(data$.getitem(1), 2)

  dl <- torch::dataloader(data, batch_size = 32)
  x <- coro::collect(dl, n = 1)

  expect_equal(x[[1]]$x$shape, c(32, 55))
  expect_equal(x[[1]]$y$shape, c(32))

})
