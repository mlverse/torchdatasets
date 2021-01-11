#' Guess The Correlation dataset
#'
#' Prepares the Guess The Correlation dataset available in Kaggle [here](https://www.kaggle.com/c/guess-the-correlation)
#'
#' We use pins for downloading and managing authetication.
#' If you want to download the dataset you need to register the Kaggle board as
#' described in [this link](https://pins.rstudio.com/articles/boards-kaggle.html).
#' or pass the `token` argument.
#'
#' @param root path to the data location
#' @param token a path to the json file obtained in Kaggle. See [here](https://pins.rstudio.com/articles/boards-kaggle.html)
#'   for additional info.
#' @param split string. 'train' or 'submition'
#' @param transform function that receives a torch tensor and return another torch tensor, transformed.
#' @param indexes set of integers for subsampling (e.g. 1:140000)
#' @param download wether to download or not
#'
#' @export
guess_the_correlation_dataset <- torch::dataset(
  "GuessTheCorrelation",
  initialize = function(root, token = NULL, split = "train", transform = NULL, indexes = NULL, download = FALSE) {

    self$transform <- transform

    # donwload ----------------------------------------------------------
    data_path <- fs::path(root, "guess-the-correlation")

    if (!fs::dir_exists(data_path) && download) {
      file <- kaggle_download("c/guess-the-correlation", token)
      fs::dir_create(data_path)
      fs::file_copy(stringr::str_subset(file, "csv$"), data_path)
      from <- stringr::str_subset(file, "csv$")
      to <- gsub("csv", "zip", from)
      file.rename(from, to)

      sapply(c(to, stringr::str_subset(file, "zip")), function(x) zip::unzip(x, exdir = data_path))
    }

    if (!fs::dir_exists(data_path))
      stop("No data found. Please use `download = TRUE`.")

    # variavel resposta -------------------------------------------------

    if(split == "train") {
      self$images <- readr::read_csv(fs::path(data_path, "train.csv"), col_types = c("cn"))
      if(!is.null(indexes)) self$images <- self$images[indexes, ]
      self$.path <- file.path(data_path, "train_imgs")
    } else if(split == "submition") {
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
