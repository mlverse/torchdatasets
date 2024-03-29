% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/oxford-flowers-dataset.R
\name{oxford_flowers102_dataset}
\alias{oxford_flowers102_dataset}
\title{102 Category Flower Dataset}
\usage{
oxford_flowers102_dataset(
  root,
  split = "train",
  target_type = c("categories"),
  download = FALSE,
  ...,
  transform = NULL,
  target_transform = NULL
)
}
\arguments{
\item{root}{path to the data location}

\item{split}{train, test or valid}

\item{target_type}{Currently only 'categories' is supported.}

\item{download}{wether to download or not}

\item{...}{Currently unused.}

\item{transform}{A function/transform that takes in an PIL image and returns
a transformed version. E.g, \code{\link[torchvision:transform_random_crop]{transform_random_crop()}}.}

\item{target_transform}{A function/transform that takes in the target and
transforms it.}
}
\description{
The Oxford Flower Dataset is a 102 category dataset, consisting of 102 flower
categories. The flowers chosen to be flower commonly occuring in the United
Kingdom. Each class consists of between 40 and 258 images. The details of the
categories and the number of images for each class can be found on
\href{https://www.robots.ox.ac.uk/\%7Evgg/data/flowers/102/categories.html}{this category statistics page}.
}
\details{
The images have large scale, pose and light variations. In addition, there are
categories that have large variations within the category and several very
similar categories. The dataset is visualized using isomap with shape and colour
features.

You can find more info in the dataset \href{https://www.robots.ox.ac.uk/\%7Evgg/data/flowers/102/}{webpage}.
}
\note{
The official splits leaves far too many images in the test set. Depending
on your work you might want to create different train/valid/test splits.
}
