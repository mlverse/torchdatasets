

test_that("dogs-vs-cats dataset", {

  tmp <- tempfile()

  dataset <- dogs_vs_cats_dataset(
    tmp,
    download = TRUE
  )

  expect_length(dataset$.getitem(1), 2)

  if (fs::dir_exists(tmp))
    fs::dir_delete(tmp)

})

