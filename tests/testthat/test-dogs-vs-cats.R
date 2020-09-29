

test_that("dogs-vs-cats dataset", {

  dataset <- dogs_vs_cats_dataset(
    tempfile(),
    download = TRUE,
    token = "kaggle.json"
  )

  expect_length(dataset$.getitem(1), 2)

})

