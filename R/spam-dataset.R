#' Spam Dataset Loader
#'
#' Defines the spam dataset commonly used in machine learning.
#'
#' @param url A character string representing the URL of the dataset.
#' @param download Logical; whether to download the dataset. Defaults to FALSE.
#' @param transform Function to apply transformations to the features. Defaults to NULL.
#' @param target_transform Function to apply transformations to the labels. Defaults to NULL.
#' @return A `torch::dataset` object for the spam dataset.
#' @examples
#' \dontrun{
#' # Simple usage:
#' ds <- spam_dataset(download = TRUE)
#' loader <- dataloader(ds, batch_size = 32, shuffle = TRUE)
#' batch <- dataloader_make_iter(loader) %>% dataloader_next()
#' dim(batch$x)
#' length(batch$y)
#' }
#' @export
spam_dataset <- torch::dataset(
  name = "spam_dataset",
  
  initialize = function(
    url = "https://hastie.su.domains/ElemStatLearn/datasets/spam.data",
    download = FALSE,
    transform = NULL,
    target_transform = NULL
  ) {
    data_path <- tempfile(fileext = ".data")
    
    if (download) {
      download.file(url, data_path, mode = "wb")
    } else {
      data_path <- url
    }
    
    raw_spam_data <- read.table(data_path, header = FALSE)
    
    self$x_data <- as.matrix(raw_spam_data[, -ncol(raw_spam_data)])
    self$y_data <- as.numeric(raw_spam_data[, ncol(raw_spam_data)])
    
    self$transform <- transform
    self$target_transform <- target_transform
  },
  
  .getitem = function(index) {
    x <- self$x_data[index, ]
    y <- self$y_data[index]
    
    if (!is.null(self$transform)) {
      x <- self$transform(x)
    }
    
    if (!is.null(self$target_transform)) {
      y <- self$target_transform(y)
    }
    
    list(
      x = torch::torch_tensor(x, dtype = torch_float()),
      y = torch::torch_tensor(y, dtype = torch_long())
    )
  },
  
  .length = function() {
    nrow(self$x_data)
  }
)
