#' Guess The Correlation dataset
#'
#' Prepares the Guess The Correlation dataset available on Kaggle [here](https://www.kaggle.com/c/guess-the-correlation)
#' A copy of this dataset is hosted in a public Google Cloud
#' bucket so you don't need to authenticate.
#'
#' @param root path to the data location
#' @param split string. 'train' or 'submission'
#' @param transform function that receives a torch tensor and return another torch tensor, transformed.
#' @param indexes set of integers for subsampling (e.g. 1:140000)
#' @param download whether to download or not
#'
#' @return A torch dataset that can be consumed with [torch::dataloader()].
#' @examples
#' if (torch::torch_is_installed()) {
#' gtc <- guess_the_correlation_dataset("./data")
#' length(gtc)
#' }
#' @export
guess_the_correlation_dataset <- torch::dataset(
  "GuessTheCorrelation",
  initialize = function(root, split = "train", transform = NULL, indexes = NULL, download = FALSE) {

    self$transform <- transform

    # donwload ----------------------------------------------------------
    data_path <- fs::path(root, "guess-the-correlation")

    if (!fs::dir_exists(data_path) && download) {
      fs::dir_create(data_path)
      zip_path <- fs::path(data_path, "guess-the-correlation.zip")
      download.file(
        "https://storage.googleapis.com/torch-datasets/guess-the-correlation.zip",
        destfile = zip_path
      )
      zip::unzip(zip_path, exdir = data_path)
      zip::unzip(fs::path(data_path, "train_imgs.zip"), exdir = data_path)
      zip::unzip(fs::path(data_path, "test_imgs.zip"), exdir = data_path)
    }

    if (!fs::dir_exists(data_path))
      stop("No data found. Please use `download = TRUE`.")

    # variavel resposta -------------------------------------------------

    if(split == "train") {
      self$images <- readr::read_csv(fs::path(data_path, "train.csv"), col_types = c("cn"))
      if(!is.null(indexes)) self$images <- self$images[indexes, ]
      self$.path <- file.path(data_path, "train_imgs")
    } else if(split == "submission") {
      self$images <- readr::read_csv(fs::path(data_path, "example_submition.csv"), col_types = c("cn"))
      self$images$corr <- NA_real_
      self$.path <- file.path(data_path, "test_imgs")
    }
  },

  .getitem = function(index) {
    force(index)
    sample <- self$images[index, ]

    id <- sample$id
    y <- sample$corr
    x <- torchvision::base_loader(file.path(self$.path, paste0(sample$id, ".png")))
    x <- torchvision::transform_to_tensor(x) %>% torchvision::transform_rgb_to_grayscale()

    if (!is.null(self$transform))
      x <- self$transform(x)

    return(list(x = x, y = torch::torch_scalar_tensor(y), id = id))
  },

  .length = function() {
    nrow(self$images)
  }
)
