kaggle_download <- function(name, token = NULL) {

  if ("kaggle" %in% pins::board_list()) {
    file <- pins::pin_get(board = "kaggle", name,
                          extract = FALSE)
  } else if (!is.null(token)) {
    pins::board_register_kaggle(name="torchdatasets-kaggle", token = token,
                                cache = tempfile(pattern = "dir"))
    on.exit({pins::board_deregister("torchdatasets-kaggle")}, add = TRUE)
    file <- pins::pin_get(name,
                          board = "torchdatasets-kaggle",
                          extract = FALSE)
  } else {
    stop("Please register the Kaggle board or pass the `token` parameter.")
  }

  file
}

download_file <- function(url, destfile) {
  withr::with_options(new = list(timeout = max(600, getOption("timeout"))), {
    download.file(url, destfile)
  })
  destfile
}
