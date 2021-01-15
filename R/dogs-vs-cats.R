#' Dog vs cats dataset
#'
#' Prepares the dog vs cats dataset available in Kaggle
#' [here](https://www.kaggle.com/c/dogs-vs-cats)
#'
#' @inheritParams bird_species_dataset
#'
#' @return A [torch::dataset()] ready to be used with dataloaders.
#' @examples
#' if (torch::torch_is_installed() && FALSE) {
#' dogs_cats <- dogs_vs_cats_dataset("./data", token = "path/to/kaggle.json",
#'                                   download = TRUE)
#' length(dogs_cats)
#' }
#' @export
dogs_vs_cats_dataset <- torch::dataset(
  inherit = torchvision::image_folder_dataset,
  initialize = function(root, token = NULL, download = TRUE, ...) {

    data_path <- fs::path(root, "dogs-vs-cats")

    if (!fs::dir_exists(data_path) && download) {

      file <- kaggle_download("c/dogs-vs-cats", token)
      fs::dir_create(data_path)
      file <- file[grepl("train", file)]
      zip::unzip(file, exdir = data_path)

      new_path <- fs::path(data_path, "train")
      files <- fs::dir_ls(new_path)
      fs::dir_create(fs::path(new_path, c("cat", "dog")))
      cat_or_dog <- ifelse(grepl("cat", fs::path_file(files)), "cat", "dog")
      fs::file_move(
        files,
        new_path = fs::path(new_path, cat_or_dog, fs::path_file(files))
      )

    }

    if (!fs::dir_exists(data_path))
      stop("No data found. Please use `download = TRUE`.")

    super$initialize(root = fs::path(data_path, "train"), ...)
  }
)
