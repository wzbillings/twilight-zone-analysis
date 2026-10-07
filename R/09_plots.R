# Scaffold only: sourcing this file performs no work.
# Expected tibble schemas are provisional; see notes/data-dictionary.md.

#' Plot modern ratings against original air dates.
#' @param episode_features Combined episode-level analytic tibble.
#' @return ggplot object using air_date and rating.
plot_ratings_over_time <- function(episode_features) {
  # TODO: Show missingness and label this as an exploratory association.
  stop("plot_ratings_over_time(): Not implemented yet.", call. = FALSE)
}

#' Plot the distribution of ratings by season.
#' @param episode_features Combined episode-level analytic tibble.
#' @return ggplot object using season and rating.
plot_rating_by_season <- function(episode_features) {
  # TODO: Show episode-level observations and season distributions.
  stop("plot_rating_by_season(): Not implemented yet.", call. = FALSE)
}

#' Plot comparable model performance estimates.
#' @param model_comparison Tibble containing model_name, metric, estimate, std_error.
#' @return ggplot object of model comparison estimates.
plot_model_comparison <- function(model_comparison) {
  # TODO: Use consistent resampling metrics and avoid causal interpretation.
  stop("plot_model_comparison(): Not implemented yet.", call. = FALSE)
}
