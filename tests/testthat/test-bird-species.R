test_that("bird-species works", {

  dataset <- bird_species_dataset(
    root = "~/Downloads/datasets",
    token = "~/Downloads/kaggle.json",
    download = TRUE
  )

  expect_length(dataset$.getitem(1), 2)

})
