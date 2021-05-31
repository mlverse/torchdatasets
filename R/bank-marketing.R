#' Bank marketing dataset
#'
#' Prepares the Bank marketing dataset available on UCI Machine Learning repository [here](https://archive.ics.uci.edu/ml/datasets/Bank+Marketing)
#' The data is available publicly for download, there is no need to authenticate.
#' Please cite the data as Moro et al., 2014
#' S. Moro, P. Cortez and P. Rita. A Data-Driven Approach to Predict the Success of Bank Telemarketing. Decision Support Systems, Elsevier, 62:22-31, June 2014
#'
#' @param root path to the data location
#' @param split string. 'train' or 'submission'
#' @param indexes set of integers for subsampling (e.g. 1:41188)
#' @param download whether to download or not
#' @param with_call_duration whether the call duration should be included as a feature. Could lead to leakage. Default: FALSE.
#'
#' @return A torch dataset that can be consumed with [torch::dataloader()].
#' @examples
#' if (torch::torch_is_installed() && FALSE) {
#' bank_mkt <- bank_marketing_dataset("./data", download = TRUE)
#' length(bank_mkt)
#' }
#' @export
bank_marketing_dataset <- torch::dataset(
  "BankMarketing",
  initialize = function(root, split = "train", indexes = NULL, download = FALSE, with_call_duration = FALSE) {

    # download ----------------------------------------------------------
    data_path <- fs::path(root, "bank-marketing")

    if (!fs::dir_exists(data_path) && download) {
      fs::dir_create(data_path)
      zip_path <- fs::path(data_path, "bank-additional.zip")
      download.file(
        "https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank-additional.zip",
        destfile = zip_path
      )
      zip::unzip(zip_path, exdir = data_path)
    }

    if (!fs::dir_exists(data_path))
      stop("No data found. Please use `download = TRUE`.")

    if(tolower(split) != "train") {
      stop("The bank marketing dataset only has a `train` split")
    }

    self$.path <- file.path(data_path, "bank-additional")

    dataset <- read.csv2(fs::path(data_path, "bank-additional/bank-additional-full.csv"))

    if (!with_call_duration)
      dataset <- dataset[,-which(colnames(dataset)=="duration")]

    # one-hot encode unordered categorical features

    unordered_categorical_features <- c("default",
                                        "job",
                                        "marital",
                                        "housing",
                                        "loan",
                                        "contact",
                                        "month",
                                        "day_of_week",
                                        "poutcome")
    for (catvar in unordered_categorical_features) {
      tmp_df <- model.matrix(~ 0 + as.data.frame(dataset)[,catvar])
      colnames(tmp_df) <- paste(catvar, levels(as.factor(as.data.frame(dataset)[,catvar])), sep = "_")
      dataset <- dataset[,-which(colnames(dataset)==catvar)]
      dataset <- cbind(dataset, tmp_df)
    }
    # encodes with integers the only ordered categorical feature, education

    educ_factors <- c("unknown",
                      "illiterate",
                      "basic.4y",
                      "basic.6y",
                      "basic.9y",
                      "high.school",
                      "professional.course",
                      "university.degree")
    educ <- factor(dataset[, "education"], order = TRUE, levels = educ_factors)
    dataset[, "education"] <- as.numeric(educ)
    dataset[, "y"] <- ifelse(dataset[, "y"] == "yes", 1, 0)
    
    # attributes the numbers to the data instance

    self$features <- as.matrix(dataset[,-which(colnames(dataset)=="y")])

    self$target <- dataset[,"y"]
  },

  .getitem = function(index) {

    force(index)

    x <- self$features[index, ]
    y <- self$target[index]

    x <- torch::torch_tensor(as.numeric(unlist(x)))
    y <- torch::torch_scalar_tensor(y)

    return(list(x = x, y = y))
  },

  .length = function() {
    nrow(self$features)
  }
)
