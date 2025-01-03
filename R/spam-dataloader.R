#' Spam Data Loader
#'
#' A dataloader for the spam dataset commonly used in machine learning.
#'
#' @param url A character string representing the URL of the dataset.
#' @param batch_size Number of samples per batch. Defaults to 32.
#' @param shuffle Logical; whether to shuffle the data. Defaults to TRUE.
#' @param download Logical; whether to download the dataset. Defaults to FALSE.
#' @return A dataloader object for the spam dataset.
#' @export
spam_dataloader <- function(url = "https://hastie.su.domains/ElemStatLearn/datasets/spam.data",
                            batch_size = 32, shuffle = TRUE, download = FALSE) {
  library(torch)

  # Download the dataset if required
  data_path <- tempfile(fileext = ".data")
  if (download) {
    download.file(url, data_path, mode = "wb")
  } else {
    data_path <- url
  }

  # Load the dataset
  spam_data <- read.table(data_path, header = FALSE)

  # Prepare predictors and targets
  x_data <- as.matrix(spam_data[, -ncol(spam_data)])  # Exclude the last column (targets)
  y_data <- as.numeric(spam_data[, ncol(spam_data)])  # Extract the last column (targets)

  # Validate data
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

  # Convert to tensors
  x_tensor <- torch_tensor(x_data, dtype = torch_float())
  y_tensor <- torch_tensor(y_data, dtype = torch_long())

  # Debugging: Check tensor dimensions
  print(x_tensor$dim())
  print(y_tensor$dim())

  # Define dataset
  spam_dataset <- dataset(
    name = "spam_dataset",
    initialize = function(x, y) {
      self$x <- x
      self$y <- y
    },
    .getbatch = function(index) {
      list(
        x = self$x[index, ],
        y = self$y[index]
      )
    },
    .length = function() {
      self$y$size(1)
    }
  )

  # Create dataset and dataloader
  dataset <- spam_dataset(x = x_tensor, y = y_tensor)
  dataloader(dataset, batch_size = batch_size, shuffle = shuffle)
}