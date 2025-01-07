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
  
 
  data_path <- tempfile(fileext = ".data")
 
  if (download) {
    download.file(url, data_path, mode = "wb")
  } else {
    data_path <- url
  }
  
  raw_spam_data <- read.table(data_path, header = FALSE)
  
  x_data <- as.matrix(raw_spam_data[, -ncol(raw_spam_data)])
  y_data <- as.numeric(raw_spam_data[, ncol(raw_spam_data)])
  
  x_tensor <- torch_tensor(x_data, dtype = torch_float())
  y_tensor <- torch_tensor(y_data, dtype = torch_long())
  
  spam_dataset <- dataset(
    name = "spam_dataset",
    initialize = function(x, y) {
      self$x <- x
      self$y <- y
    },
    .getitem = function(index) {
      list(
        x = self$x[index, ],
        y = self$y[index]
      )
    },
    .length = function() {
      self$y$size(1)
    }
  )
  
  ds <- spam_dataset(x = x_tensor, y = y_tensor)
  
  dataloader(ds, batch_size = batch_size, shuffle = shuffle)
}
