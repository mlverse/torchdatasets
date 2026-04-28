test_that("spam_dataset works as expected", {
  dataset <- tryCatch(
    spam_dataset(download = TRUE),
    error = function(e) {
      if (grepl("cannot open URL|HTTP status|download.file", conditionMessage(e)))
        skip(paste("Spam dataset download failed:", conditionMessage(e)))
      stop(e)
    }
  )

  expect_true(length(dataset) > 0)

  item <- dataset[1]
  expect_named(item, c("x", "y"))
  expect_equal(length(item$x), 57)
  expect_true(as.integer(item$y) %in% c(0, 1))
})
