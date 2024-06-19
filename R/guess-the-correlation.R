#' Guess The Correlation dataset
#'
#' Prepares the Guess The Correlation dataset available on Kaggle [here](https://www.kaggle.com/c/guess-the-correlation)
#' A copy of this dataset is hosted in a public Google Cloud
#' bucket so you don't need to authenticate.
#'
#' @param root path to the data location
#' @param split string. 'train' or 'submission'
#' @param transform function that takes a torch tensor representing an image and return another tensor, transformed.
#' @param target_transform function that takes a scalar torch tensor and returns another tensor, transformed.
#' @param indexes set of integers for subsampling (e.g. 1:140000)
#' @param download whether to download or not
#'
#' @return A torch dataset that can be consumed with [torch::dataloader()].
#' @examples
#' if (torch::torch_is_installed() && FALSE) {
#' gtc <- guess_the_correlation_dataset("./data", download = TRUE)
#' length(gtc)
#' }
#' @export
guess_the_correlation_dataset <- torch::dataset(
  "GuessTheCorrelation",
  initialize = function(root, split = "train", transform = NULL, target_transform = NULL, indexes = NULL, download = FALSE) {

    self$transform <- transform
    self$target_transform <- target_transform

    # donwload ----------------------------------------------------------
    data_path <- maybe_download(
      root = root,
      name = "guess-the-correlation",
      url = "https://torch-cdn.mlverse.org/datasets/guess-the-correlation.zip",
      download = download,
      extract_fun = function(temp, data_path) {
        unzip2(temp, exdir = data_path)
        unzip2(fs::path(data_path, "train_imgs.zip"), exdir = data_path)
        unzip2(fs::path(data_path, "test_imgs.zip"), exdir = data_path)
      }
    )

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
    x <- torchvision::base_loader(file.path(self$.path, paste0(sample$id, ".png")))
    x <- torchvision::transform_to_tensor(x) %>% torchvision::transform_rgb_to_grayscale()

    if (!is.null(self$transform))
      x <- self$transform(x)

    y <- torch::torch_scalar_tensor(sample$corr)
    if (!is.null(self$target_transform))
      y <- self$target_transform(y)

    return(list(x = x, y = y, id = id))
  },

  .length = function() {
    nrow(self$images)
  }
)
