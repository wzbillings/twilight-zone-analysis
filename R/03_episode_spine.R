# Scaffold only: sourcing this file performs no work.
# Expected tibble schemas are provisional; see notes/data-dictionary.md.

#' Build the canonical episode-level spine.
#' @param raw_episode_metadata Episode metadata tibble.
#' @param raw_ratings Ratings tibble.
#' @return Tibble with one row per episode: episode_id, title, season, episode_number, series_order, air_date, runtime_minutes, rating, vote_count, rating_source, rating_observed_at.
build_episode_spine <- function(raw_episode_metadata, raw_ratings) {
  # TODO: Reconcile episode identifiers and preserve all canonical episodes; never silently duplicate joins.
  stop("build_episode_spine(): Not implemented yet.", call. = FALSE)
}
