test_that("bird-species works", {

  dataset <- bird_species_dataset(
    root = tempfile(),
    download = TRUE
  )

  expect_length(dataset$.getitem(1), 2)

})
