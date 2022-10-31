

test_that("dogs-vs-cats dataset", {

  dataset <- dogs_vs_cats_dataset(
    "./dogs-vs-cats",
    download = TRUE
  )

  expect_length(dataset$.getitem(1), 2)

})

