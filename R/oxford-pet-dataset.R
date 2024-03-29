#' Oxford Pet Dataset
#'
#' The Oxford-IIIT Pet Dataset is a 37 category pet dataset with roughly
#' 200 images for each class. The images have a large variations in scale,
#' pose and lighting. All images have an associated ground truth annotation of
#' species (cat or dog), breed, and pixel-level trimap segmentation.
#'
#' @inheritParams cityscapes_pix2pix_dataset
#' @param target_type The type of the target:
#'   - 'trimap': returns a mask array with one class per pixel.
#'   - 'species': returns the species id. 1 for cat and 2 for dog.
#'   - 'breed': returns the breed id. see `dataset$breed_classes`.
#'
#' @export
oxford_pet_dataset <- torch::dataset(
  "OxfordPet",

  trimap_classes = c("Pixel belonging to the pet", "Pixel bordering the pet", "Surrounding pixel"),
  species_classes = c("cat", "dog"),
  breed_classes = c("Abyssinian", "american_bulldog", "american_pit_bull_terrier",
                    "basset_hound", "beagle", "Bengal", "Birman", "Bombay", "boxer",
                    "British_Shorthair", "chihuahua", "Egyptian_Mau", "english_cocker_spaniel",
                    "english_setter", "german_shorthaired", "great_pyrenees", "havanese",
                    "japanese_chin", "keeshond", "leonberger", "Maine_Coon", "miniature_pinscher",
                    "newfoundland", "Persian", "pomeranian", "pug", "Ragdoll", "Russian_Blue",
                    "saint_bernard", "samoyed", "scottish_terrier", "shiba_inu",
                    "Siamese", "Sphynx", "staffordshire_bull_terrier", "wheaten_terrier",
                    "yorkshire_terrier"),

  initialize = function(root, split = "train", target_type = c("trimap", "species", "breed"),
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
      col_names = c("image", "class_id", "species_id", "breed_id"),
      col_types = readr::cols()
    )

    self$transform <- if (is.null(transform)) identity else transform
    self$target_transform <- if (is.null(target_transform)) identity else target_transform

    # rename files known to be PNG's
    self$imgs$ext <- "jpg"
    pngs <- c("Egyptian_Mau_14", "Egyptian_Mau_156", "Egyptian_Mau_186", "Abyssinian_5")
    self$imgs$ext[self$imgs$image %in% pngs] <- "png"

    # remove corrupt file
    self$imgs <- self$imgs[self$imgs$image != "beagle_116",]

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
    path <- fs::path(self$data_path, "images", paste0(img$image, ".jpg"))
    if (img$ext == "jpg")
      jpeg::readJPEG(path)
    else
      png::readPNG(path)[,,1:3] # we remove the alpha channel
  },

  read_trimap = function(img) {
    mask <- png::readPNG(fs::path(self$data_path, "annotations", "trimaps", paste0(img$image, ".png")))
    dimensions <- dim(mask)
    mask <- as.integer(mask*255)
    dim(mask) <- dimensions
    mask
  },

  read_species = function(img) {
    as.integer(img$species_id)
  },

  read_breed = function(img) {
    as.integer(img$breed_id)
  }

)
