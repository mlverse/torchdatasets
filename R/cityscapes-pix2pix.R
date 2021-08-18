#' Cityscapes Pix2Pix dataset
#'
#' Downloads and prepares the cityscapes dataset that has been used in the
#' [pix2pix paper](https://arxiv.org/abs/1611.07004).
#'
#' Find more information in the [project website](https://phillipi.github.io/pix2pix/)
#'
#' @inheritParams bird_species_dataset
#' @inheritParams torchvision::image_folder_dataset
#' @param ... Currently unused.
#'
#' @export
cityscapes_pix2pix_dataset <- torch::dataset(
  "CityscapesImagePairs",
  initialize = function(root, split = "train", download = FALSE, ...,
                        transform = NULL, target_transform = NULL) {

    data_path <- fs::path_expand(fs::path(root, "cityscapes-image-pairs"))

    if (!fs::dir_exists(data_path) && download) {
      tmp <- tempfile(fileext = ".tar.gz")
      download_file("http://efrosgans.eecs.berkeley.edu/pix2pix/datasets/cityscapes.tar.gz", tmp)
      fs::dir_create(data_path)
      untar(tmp, exdir = data_path)
    }

    if (!fs::dir_exists(data_path))
      stop("No data found. Please use `download = TRUE`.")

    self$split <- split

    path <- fs::path(
      data_path,
      "cityscapes",
      ifelse(self$split == "train", "train", "val")
    )

    self$files <- fs::dir_ls(path, glob = "*.jpg")
    self$transform <- if (is.null(transform)) identity else transform
    self$target_transform <- if (is.null(target_transform)) identity else target_transform
  },
  .getitem = function(i) {
    img <- jpeg::readJPEG(self$files[i])

    list(
      input_img = self$transform(img[,257:512,]),
      real_img = self$target_transform(img[,1:256,])
    )
  },
  .length = function() {
    length(self$files)
  }
)

