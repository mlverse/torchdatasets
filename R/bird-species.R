
#' Bird species dataset
#'
#'
#' Downloads and prepares the 450 bird species dataset found on Kaggle.
#' The dataset description, license, etc can be found [here](https://www.kaggle.com/datasets/gpiosenka/100-bird-species).
#'
#'
#' @param root path to the data location
#' @param split train, test or valid
#' @param download wether to download or not
#' @param ... other arguments passed to [torchvision::image_folder_dataset()].
#'
#' @return A [torch::dataset()] ready to be used with dataloaders.
#'
#' @examples
#' if (torch::torch_is_installed() && FALSE) {
#' birds <- bird_species_dataset("./data", token = "path/to/kaggle.json",
#'                               download = TRUE)
#' length(birds)
#' }
#' @export
bird_species_dataset <- torch::dataset(
  inherit = torchvision::image_folder_dataset,
  initialize = function(root, split = "train", download = FALSE, ...) {

    url <- "https://storage.googleapis.com/torch-datasets/bird-species.zip"
    data_path <- maybe_download(
      root = root,
      name = "bird-species",
      url = url,
      download = download,
      extract_fun = function(temp, data_path) {
        zip::unzip(temp, exdir = data_path)
      }
    )

    if (!fs::dir_exists(data_path))
      cli::cli_abort("No data found. Please use `download = TRUE`.")

    possible_splits <- c("train", "valid", "test")
    if (!split %in% possible_splits) {
      cli::cli_abort(c(
        "Found split {.val {split}} but expected one of {.or {.val {possible_splits}}}."
      ))
    }

    p <- fs::path(data_path, split)
    super$initialize(root = p, ...)
  }
)

