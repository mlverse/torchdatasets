# torchdatasets

<!-- badges: start -->

[![R-CMD-check](https://github.com/mlverse/torchdatasets/workflows/R-CMD-check/badge.svg)](https://github.com/mlverse/torchdatasets/actions) [![CRAN status](https://www.r-pkg.org/badges/version/torchdatasets)](https://CRAN.R-project.org/package=torchdatasets)

<!-- badges: end -->

torchdatasets provides ready-to-use datasets compatible with the [torch](https://github.com/mlverse/torch) package.

## Installation

torchdatasets is not yet on CRAN, but you can install the development version with:

``` {.r}
remotes::install_github("mlverse/torchdatasets")
```

## Datasets

Currently, the following datasets are implemented:

| Dataset                            | Domain | Type           | Authentication    |
|------------------------------------|--------|----------------|-------------------|
| bird\_species\_dataset()           | Images | Classification | Kaggle (via pins) |
| dogs\_vs\_cats\_dataset()          | Images | Classification | Kaggle (via pins) |
| guess\_the\_correlation\_dataset() | Images | Regression     | Not required      |
