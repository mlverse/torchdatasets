#' Oxford Pet Dataset
#'
#'
#'
#'
#'
#'
oxford_pet_dataset <- torch::dataset(
  "OxfordPet",

  trimap_classes = c("Pixel belonging to the pet", "Pixel bordering the pet", "Surrounding pixel"),
  specie_classes = c("cat", "dog"),
  breed_classes = c("Abyssinian", "american_bulldog", "american_pit_bull_terrier",
                    "basset_hound", "beagle", "Bengal", "Birman", "Bombay", "boxer",
                    "British_Shorthair", "chihuahua", "Egyptian_Mau", "english_cocker_spaniel",
                    "english_setter", "german_shorthaired", "great_pyrenees", "havanese",
                    "japanese_chin", "keeshond", "leonberger", "Maine_Coon", "miniature_pinscher",
                    "newfoundland", "Persian", "pomeranian", "pug", "Ragdoll", "Russian_Blue",
                    "saint_bernard", "samoyed", "scottish_terrier", "shiba_inu",
                    "Siamese", "Sphynx", "staffordshire_bull_terrier", "wheaten_terrier",
                    "yorkshire_terrier"),

  initialize = function(root, split = "train", target_type = c("trimap", "specie", "breed"),
                        download = FALSE, ..., transform = NULL, target_transform = NULL) {

    rlang::check_installed("readr")

    data_path <- fs::path_expand(fs::path(root, "oxford-pet"))
    self$data_path <- data_path

    if (!fs::dir_exists(data_path) && download) {

      images <- download_file(
        "https://www.robots.ox.ac.uk/~vgg/data/pets/data/images.tar.gz",
        tempfile(fileext = ".tar.gz")
      )

      targets <- download_file(
        "https://www.robots.ox.ac.uk/~vgg/data/pets/data/annotations.tar.gz",
        tempfile(fileext = ".tar.gz")
      )

      fs::dir_create(data_path)
      untar(images, exdir = data_path)
      untar(targets, exdir = data_path)
    }

    if (!fs::dir_exists(data_path))
      stop("No data found. Please use `download = TRUE`.")

    self$split <- split
    self$target_type <- rlang::arg_match(target_type)
    self$target_reader <- get(
      paste0("read_", self$target_type),
      envir = self
    )
    self$classes <- get(
      paste0(self$target_type, "_classes"),
      envir = self
    )

    if (self$split == "train") {
      img_list <- fs::path(data_path, "annotations", "trainval.txt")
    } else {
      img_list <- fs::path(data_path, "annotations", "test.txt")
    }

    self$imgs <- readr::read_delim(
      img_list,
      delim = " ",
      col_names = c("image", "class_id", "specie_id", "breed_id"),
      col_types = readr::cols()
    )

    self$transform <- if (is.null(transform)) identity else transform
    self$target_transform <- if (is.null(target_transform)) identity else target_transform
  },

  .getitem = function(i) {
    img <- self$imgs[i,]
    list(
      x = self$transform(self$read_img(img)),
      y = self$target_transform(self$target_reader(img))
    )
  },

  .length = function() {
    nrow(self$imgs)
  },

  read_img = function(img) {
    jpeg::readJPEG(fs::path(self$data_path, "images", paste0(img$image, ".jpg")))
  },

  read_trimap = function(img) {
    mask <- png::readPNG(fs::path(self$data_path, "annotations", "trimaps", paste0(img$image, ".png")))
    dimensions <- dim(mask)
    mask <- as.integer(mask*255)
    dim(mask) <- dimensions
    mask
  },

  read_specie = function(img) {
    as.integer(img$specie_id)
  },

  read_breed = function(img) {
    as.integer(img$breed_id)
  }

)
