test_that("spam_dataset works as expected", {

  dataset <- spam_dataset(download = TRUE)

  expect_true(length(dataset) > 0)

  item <- dataset[1]
  expect_named(item, c("x", "y"))
  expect_equal(length(item$x), 57)
  expect_true(as.integer(item$y) %in% c(0, 1))
})
