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
    utils::download.file(url, destfile)
  })
  destfile
}

maybe_download <- function(url, root, name, extract_fun, download) {
  data_path <- fs::path_expand(fs::path(root, name))

  if (!fs::dir_exists(data_path) && download) {
    tmp <- tempfile()
    download_file(url, tmp)
    fs::dir_create(fs::path_dir(data_path), recurse = TRUE)
    extract_fun(tmp, data_path)
  }

  if (!fs::dir_exists(data_path))
    stop("No data found. Please use `download = TRUE`.")

  data_path
}

unzip2 <- function(path, exdir) {
  if (grepl("linux", R.version$os)) {
    unzip(path, exdir = exdir)
  } else {
    unzip2(path, exdir = exdir)
  }
}
