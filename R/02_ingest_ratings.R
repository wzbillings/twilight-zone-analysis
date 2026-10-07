# Scaffold only: sourcing this file performs no work.
# Expected tibble schemas are provisional; see notes/data-dictionary.md.

#' Read locally supplied modern viewer ratings.
#' @return Tibble: episode_id (character), rating (double), vote_count (integer), rating_source (character), rating_observed_at (Date).
read_episode_ratings <- function() {
  # TODO: Select the canonical rating source, scale, and observation date; do not scrape.
  stop("read_episode_ratings(): Not implemented yet.", call. = FALSE)
}
