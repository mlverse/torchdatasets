test_that("bird-species works", {

  dataset <- bird_species_dataset(
    root = "./bird",
    download = TRUE
  )

  expect_length(dataset$.getitem(1), 2)

})
