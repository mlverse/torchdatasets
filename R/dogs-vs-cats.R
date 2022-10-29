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
#'
#' @importFrom torchvision base_loader
#' @export
dogs_vs_cats_dataset <- torch::dataset(
  classes = c("dog", "cat"),
  initialize = function(root, split = "train", download = FALSE, ..., transform = NULL,
                        target_transform = NULL) {

    self$transform <- transform
    self$target_transform <- target_transform

    url <- "https://storage.googleapis.com/torch-datasets/dogs-vs-cats.zip"

    data_path <- maybe_download(
      root = root,
      name = "dogs-vs-cats",
      url = url,
      download = download,
      extract_fun = function(temp, data_path) {
        zip::unzip(temp, exdir = data_path)
        zip::unzip(fs::path(data_path, "train.zip"), exdir = data_path)
        zip::unzip(fs::path(data_path, "test1.zip"), exdir = data_path)
        fs::file_delete(fs::path(data_path, "train.zip"))
        fs::file_delete(fs::path(data_path, "test1.zip"))
      }
    )

    if (!fs::dir_exists(data_path))
      cli::cli_abort("No data found. Please use `download = TRUE`.")

    if(split == "train") {
      self$images <- fs::dir_ls(fs::path(data_path, "train"))
    } else if(split == "test") {
      self$images <- fs::dir_ls(fs::path(data_path, "test1"))
    } else {
      cli::cli_abort(c(
        "Only 'train' and 'test' split are supported.",
        i = "Got {.str {split}}"
      ))
    }
    self$targets <- stringr::str_extract(
      fs::path_file(self$images),
      "[^.]+(?=\\.)"
    )
    self$targets <- match(self$targets, self$classes)
  },
  .getitem = function(i) {
    x <- base_loader(self$images[i])
    y <- self$targets[i]

    if (!is.null(self$transform))
      x <- self$transform(x)

    if (!is.null(self$target_transform))
      y <- self$target_transform(y)

    list(x, y)
  },
  .length = function() {
    length(self$images)
  }
)
