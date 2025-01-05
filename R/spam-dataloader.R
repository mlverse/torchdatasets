#' Spam Data Loader
#'
#' A dataloader for the spam dataset commonly used in machine learning.
#'
#' @param url A character string representing the URL of the dataset.
#' @param batch_size Number of samples per batch. Defaults to 32.
#' @param shuffle Logical; whether to shuffle the data. Defaults to TRUE.
#' @param download Logical; whether to download the dataset. Defaults to FALSE.
#' @return A torch dataloader object for the spam dataset.
#' @examples
#' \dontrun{
#' # Simple usage:
#' loader <- spam_dataloader(download = TRUE)
#' batch <- dataloader_make_iter(loader) %>% dataloader_next()
#' dim(batch$x)
#' length(batch$y)
#' }
#' @export
spam_dataloader <- function(
    url = "https://hastie.su.domains/ElemStatLearn/datasets/spam.data",
    batch_size = 32,
    shuffle = TRUE,
    download = FALSE
) {
  library(torch)
  
  # Decide where to put the data
  data_path <- tempfile(fileext = ".data")
  
  # Download the dataset if requested
  if (download) {
    download.file(url, data_path, mode = "wb")
  } else {
    data_path <- url
  }
  
  # Read data from file (must have 57 features + 1 target column)
  raw_spam_data <- read.table(data_path, header = FALSE)
  
  # Split into predictors (x) and targets (y)
  x_data <- as.matrix(raw_spam_data[, -ncol(raw_spam_data)])
  y_data <- as.numeric(raw_spam_data[, ncol(raw_spam_data)])
  
  # Validate shape and data
  if (is.null(dim(x_data)) || ncol(x_data) != 57) {
    stop("The predictors matrix must have 57 features.")
  }
  if (anyNA(x_data)) {
    stop("The predictors matrix contains missing values.")
  }
  if (!all(y_data %in% c(0, 1))) {
    stop("The target labels must be binary (0/1).")
  }
  if (nrow(x_data) == 0 || ncol(x_data) == 0) {
    stop("The predictors matrix is empty.")
  }
  if (length(y_data) == 0) {
    stop("The target vector is empty.")
  }
  
  # Convert R data to torch tensors
  x_tensor <- torch_tensor(x_data, dtype = torch_float())
  y_tensor <- torch_tensor(y_data, dtype = torch_long())
  
  # Create a dataset class
  spam_dataset <- dataset(
    name = "spam_dataset",
    initialize = function(x, y) {
      self$x <- x
      self$y <- y
    },
    .getitem = function(index) {
      # Return list of features and target for the given index
      list(
        x = self$x[index, ],
        y = self$y[index]
      )
    },
    .length = function() {
      # Total number of examples
      self$y$size(1)
    }
  )
  
  # Instantiate the dataset
  ds <- spam_dataset(x = x_tensor, y = y_tensor)
  
  # Return a dataloader
  dataloader(ds, batch_size = batch_size, shuffle = shuffle)
}
