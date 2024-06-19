flower_categories <- c(
  "pink primrose",
  "hard-leaved pocket orchid",
  "canterbury bells",
  "sweet pea",
  "english marigold",
  "tiger lily",
  "moon orchid",
  "bird of paradise",
  "monkshood",
  "globe thistle",
  "snapdragon",
  "colt's foot",
  "king protea",
  "spear thistle",
  "yellow iris",
  "globe-flower",
  "purple coneflower",
  "peruvian lily",
  "balloon flower",
  "giant white arum lily",
  "fire lily",
  "pincushion flower",
  "fritillary",
  "red ginger",
  "grape hyacinth",
  "corn poppy",
  "prince of wales feathers",
  "stemless gentian",
  "artichoke",
  "sweet william",
  "carnation",
  "garden phlox",
  "love in the mist",
  "mexican aster",
  "alpine sea holly",
  "ruby-lipped cattleya",
  "cape flower",
  "great masterwort",
  "siam tulip",
  "lenten rose",
  "barbeton daisy",
  "daffodil",
  "sword lily",
  "poinsettia",
  "bolero deep blue",
  "wallflower",
  "marigold",
  "buttercup",
  "oxeye daisy",
  "common dandelion",
  "petunia",
  "wild pansy",
  "primula",
  "sunflower",
  "pelargonium",
  "bishop of llandaff",
  "gaura",
  "geranium",
  "orange dahlia",
  "pink-yellow dahlia?",
  "cautleya spicata",
  "japanese anemone",
  "black-eyed susan",
  "silverbush",
  "californian poppy",
  "osteospermum",
  "spring crocus",
  "bearded iris",
  "windflower",
  "tree poppy",
  "gazania",
  "azalea",
  "water lily",
  "rose",
  "thorn apple",
  "morning glory",
  "passion flower",
  "lotus",
  "toad lily",
  "anthurium",
  "frangipani",
  "clematis",
  "hibiscus",
  "columbine",
  "desert-rose",
  "tree mallow",
  "magnolia",
  "cyclamen",
  "watercress",
  "canna lily",
  "hippeastrum",
  "bee balm",
  "ball moss",
  "foxglove",
  "bougainvillea",
  "camellia",
  "mallow",
  "mexican petunia",
  "bromelia",
  "blanket flower",
  "trumpet creeper",
  "blackberry lily"
)

#' 102 Category Flower Dataset
#'
#' The Oxford Flower Dataset is a 102 category dataset, consisting of 102 flower
#' categories. The flowers chosen to be flower commonly occuring in the United
#' Kingdom. Each class consists of between 40 and 258 images. The details of the
#' categories and the number of images for each class can be found on
#' [this category statistics page](https://www.robots.ox.ac.uk/%7Evgg/data/flowers/102/categories.html).
#'
#' The images have large scale, pose and light variations. In addition, there are
#' categories that have large variations within the category and several very
#' similar categories. The dataset is visualized using isomap with shape and colour
#' features.
#'
#' You can find more info in the dataset [webpage](https://www.robots.ox.ac.uk/%7Evgg/data/flowers/102/).
#'
#' @note The official splits leaves far too many images in the test set. Depending
#'   on your work you might want to create different train/valid/test splits.
#'
#' @inheritParams oxford_pet_dataset
#' @param target_type Currently only 'categories' is supported.
#' @importFrom torch dataset
#' @export
oxford_flowers102_dataset <- torch::dataset(
  "OxfordFlowers102",
  classes = flower_categories,
  initialize = function(root, split = "train", target_type = c("categories"),
                        download = FALSE, ..., transform = NULL, target_transform = NULL) {
    rlang::check_installed(c("R.matlab"))

    data_path <- fs::path_expand(fs::path(root, "oxford-flowers102"))
    self$data_path <- data_path

    if (!fs::dir_exists(data_path) && download) {

      images <- download_file(
        "https://torch-cdn.mlverse.org/datasets/oxford_flowers102/102flowers.tgz",
        tempfile(fileext = ".tgz")
      )

      targets <- download_file(
        "https://torch-cdn.mlverse.org/datasets/oxford_flowers102/imagelabels.mat",
        tempfile(fileext = ".mat"),
        mode = "wb"
      )

      splits <- download_file(
        "https://torch-cdn.mlverse.org/datasets/oxford_flowers102/setid.mat",
        tempfile(fileext = ".mat"),
        mode = "wb"
      )

      fs::dir_create(data_path)
      untar(images, exdir = data_path)
      fs::file_move(targets, fs::path(data_path, "imagelabels.mat"))
      fs::file_move(splits, fs::path(data_path, "setid.mat"))
    }

    if (!fs::dir_exists(data_path))
      cli::cli_abort("No data found. Please use {.var download = TRUE}.")

    self$split <- split
    splits <- R.matlab::readMat(fs::path(self$data_path, "setid.mat"))
    splits <- lapply(splits, as.integer)
    names(splits) <- c("train", "valid", "test")

    self$target_type <- target_type
    targets <- R.matlab::readMat(fs::path(self$data_path, "imagelabels.mat"))
    targets <- as.integer(targets$labels)

    ids <- unlist(splits[names(splits) %in% self$split])
    self$targets <- targets[ids]

    self$imgs <- fs::path(
      self$data_path,
      "jpg",
      sprintf("image_%05d.jpg", ids)
    )

    self$transform <- if (is.null(transform)) identity else transform
    self$target_transform <- if (is.null(target_transform)) identity else target_transform
  },
  .getitem = function(i) {
    list(
      x = self$transform(jpeg::readJPEG(self$imgs[i])),
      y = self$target_transform(self$targets[i])
    )
  },
  .length = function() {
    length(self$imgs)
  }
)
