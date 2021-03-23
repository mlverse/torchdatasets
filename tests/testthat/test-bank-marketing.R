test_that("bank marketting works", {

  data <- bank_marketing_dataset(
    root = tempfile(),
    download = TRUE
  )

  expect_length(dataset$.getitem(1), 2)


})
