#' Bank marketing dataset
#'
#' Prepares the Bank marketing dataset available on UCI Machine Learning repository [here](https://archive.ics.uci.edu/ml/datasets/Bank+Marketing)
#' The data is available publicly for download, there is no need to authenticate.
#' Please cite the data as Moro et al., 2014
#' S. Moro, P. Cortez and P. Rita. A Data-Driven Approach to Predict the Success of Bank Telemarketing. Decision Support Systems, Elsevier, 62:22-31, June 2014
#'
#' @param root path to the data location
#' @param split string. 'train' or 'submission'
#' @param transform function that takes a torch tensor representing an image and return another tensor, transformed.
#' @param target_transform function that takes a scalar torch tensor and returns another tensor, transformed.
#' @param indexes set of integers for subsampling (e.g. 1:140000)
#' @param download whether to download or not
#' @param target_as_numeric whether the target 'y' variable should be returned as 0/1 values or as "no"/"yes"
#'
#' @return A torch dataset that can be consumed with [torch::dataloader()].
#' @examples
#' if (torch::torch_is_installed() && FALSE) {
#' bank_mkt <- bank_marketing_dataset("./data", download = TRUE)
#' length(bank_mkt)
#' }
#' @export
bank_marketing_dataset <- torch::dataset(
  "BankMarketing",
  initialize = function(root, split = "train", transform = NULL, target_transform = NULL, indexes = NULL, download = FALSE, target_as_numeric = TRUE) {

    self$transform <- transform
    self$target_transform <- target_transform

    # donwload ----------------------------------------------------------
    data_path <- fs::path(root, "bank-marketing")

    if (!fs::dir_exists(data_path) && download) {
      fs::dir_create(data_path)
      zip_path <- fs::path(data_path, "bank-additional.zip")
      download.file(
        "https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank-additional.zip",
        destfile = zip_path
      )
      zip::unzip(zip_path, exdir = data_path)
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
    dataset <- readr::read_csv2(fs::path(data_path, "bank-additional/bank-additional-full.csv"))
    self$features <- dataset[-ncol(dataset)]
    self$target <- dataset[ncol(dataset)]
    self$.path <- file.path(data_path, "bank-additional")
    if(target_as_numeric) {
      self$target <- ifelse(self$target == "yes", 1, 0)
    }
  }
)
