# Paths assume the working directory is the project root.
# These helpers return character paths and do not create directories.

#' Build a project-relative path.
#' @param ... Character path components.
#' @return A character path rooted at the current project working directory.
project_path <- function(...) {
  file.path(getwd(), ...)
}

#' Build a raw-data path; ... contains character path components.
#' @return A character path under data/raw.
data_raw_path <- function(...) {
  project_path("data", "raw", ...)
}

#' Build an interim-data path; ... contains character path components.
#' @return A character path under data/interim.
data_interim_path <- function(...) {
  project_path("data", "interim", ...)
}

#' Build a feature-data path; ... contains character path components.
#' @return A character path under data/features.
data_features_path <- function(...) {
  project_path("data", "features", ...)
}

#' Build an analytic-data path; ... contains character path components.
#' @return A character path under data/analytic.
data_analytic_path <- function(...) {
  project_path("data", "analytic", ...)
}

#' Build an output path; ... contains character path components.
#' @return A character path under output.
output_path <- function(...) {
  project_path("output", ...)
}
