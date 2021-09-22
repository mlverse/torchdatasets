#' IMDB movie review sentiment classification dataset
#'
#' The format of this dataset is meant to replicate the same as
#' [Keras's](https://keras.io/api/datasets/imdb/).
#'
#' @inheritParams bird_species_dataset
#' @param shuffle wether to shuffle or not the dataset. `TRUE` if `split=="train"`
#' @param num_words Words are ranked by how often they occur (in the training set)
#'   and only the num_words most frequent words are kept. Any less frequent word
#'   will appear as oov_char value in the sequence data. If `Inf`, all words are
#'   kept. Defaults to None, so all words are kept.
#' @param skip_top skip the top N most frequently occurring words (which may not be informative).
#'   These words will appear as oov_char value in the dataset. Defaults to 0, so
#'   no words are skipped.
#' @param maxlen int or `Inf`. Maximum sequence length. Any longer sequence will
#'   be truncated. Defaults to None, which means no truncation.
#' @param start_char The start of a sequence will be marked with this character.
#'   Defaults to 2 because 1 is usually the padding character.
#' @param oov_char int. The out-of-vocabulary character. Words that were cut out
#'   because of the num_words or skip_top limits will be replaced with this character.
#' @param index_from int. Index actual words with this index and higher.
#
#'
#' @export
imdb_dataset <- torch::dataset(
  initialize = function(root, download = FALSE, split = "train", shuffle = (split == "train"),
                        num_words = Inf, skip_top = 0, maxlen = Inf,
                        start_char = 2, oov_char = 3, index_from = 4) {

    rlang::check_installed("tokenizers")

    url = "https://ai.stanford.edu/~amaas/data/sentiment/aclImdb_v1.tar.gz"
    data_path <- maybe_download(
      url = url,
      root = root,
      download = download,
      name = "imdb",
      extract_fun = function(tmp, expath) {
        untar(tmp, exdir = expath)
      }
    )
    self$data_path <- data_path

    if (!split %in% c("train", "test"))
      rlang::abort(paste0("Unknown split `", split, "`"))

    texts <- self$read_and_tokenize(split)
    response <- texts$response
    texts <- texts$texts

    vocabulary <- self$get_vocabulary()

    if (skip_top > 0)
      vocabulary <- vocabulary[-seq_len(skip_top)]

    if (num_words < length(vocabulary))
      vocabulary <- vocabulary[seq_len(num_words)]

    if (shuffle) {
      new_order <- sample.int(length(texts))
      texts <- texts[new_order]
      response <- response[new_order]
    }

    self$texts <- texts
    self$response <- response
    self$vocabulary <- vocabulary
    self$start_char <- start_char
    self$oov_char <- oov_char
    self$maxlen <- maxlen
    self$index_from <- index_from
  },
  .getitem = function(i) {
    words <- self$texts[[i]]

    # word indexes start at 1, but we want it to start from `index_from`
    int <- match(words, names(self$vocabulary)) + as.integer(self$index_from - 1)
    int[is.na(int)] <- as.integer(self$oov_char)
    int <- c(as.integer(self$start_char), int)

    if (is.finite(self$maxlen)) {
      int <- int[seq_len(self$maxlen)]
      int[is.na(int)] <- 1L # padding character
    }

    list(
      x = int,
      y = self$response[i]
    )
  },
  .length = function() {
    length(self$texts)
  },
  get_vocabulary = function() {

    data_path <- self$data_path
    cached <- fs::path(data_path, "aclimdb", "cached-vocab.rds")
    if (!fs::file_exists(cached)) {
      texts <- self$read_and_tokenize("train")$texts
      vocabulary <- texts %>%
        unlist() %>%
        table() %>%
        sort(decreasing = TRUE)
      saveRDS(vocabulary, file = cached)
    } else {
      vocabulary <- readRDS(cached)
    }

    vocabulary
  },
  read_and_tokenize = function(split) {

    data_path <- self$data_path
    cached <- fs::path(data_path, "aclimdb", split, "cached.rds")

    if (!fs::file_exists(cached)) {
      pos <- fs::dir_ls(fs::path(data_path, "aclimdb", split, "pos"))
      neg <- fs::dir_ls(fs::path(data_path, "aclimdb", split, "neg"))

      texts <- sapply(c(pos, neg), function(x) readr::read_file(x)) %>%
        tokenizers::tokenize_words()

      response <- c(
        rep(1, length.out = length(pos)),
        rep(0, length.out = length(neg))
      )

      rlang::inform(paste0("Caching tokenized texts for split: ", split))
      saveRDS(
        list(texts = texts, response = response),
        file = cached
      )
    } else {
      texts <- readRDS(cached)

      response <- texts$response
      texts <- texts$texts
    }

    list(
      texts = texts,
      response = response
    )
  }
)
