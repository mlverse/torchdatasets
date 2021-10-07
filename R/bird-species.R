
#' Bird species dataset
#'
#' Prepares the bird species dataset available in Kaggle [here](https://www.kaggle.com/gpiosenka/100-bird-species)
#'
#' We use pins for downloading and managing authetication.
#' If you want to download the dataset you need to register the Kaggle board as
#' described in [this link](https://pins.rstudio.com/reference/legacy_kaggle.html).
#' or pass the `token` argument.
#'
#' @param root path to the data location
#' @param token a path to the json file obtained in Kaggle. See [here](https://pins.rstudio.com/reference/legacy_kaggle.html)
#'   for additional info.
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
  initialize = function(root, token = NULL, split = "train", download = FALSE, ...) {

    data_path <- fs::path(root, "100-bird-species")

    if (!fs::dir_exists(data_path) && download) {

      file <- kaggle_download("gpiosenka/100-bird-species", token)
      fs::dir_create(data_path)
      zip::unzip(file, exdir = data_path)

    }

    if (!fs::dir_exists(data_path))
      stop("No data found. Please use `download = TRUE`.")

    p <- fs::path(data_path, split)

    super$initialize(root = p, ...)
  }

)

