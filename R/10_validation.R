# Scaffold only: sourcing this file performs no work.
# Expected tibble schemas are provisional; see notes/data-dictionary.md.

#' Validate the canonical episode spine.
#' @param episode_spine Canonical episode spine tibble.
#' @return TRUE on success; abort with actionable details on invalid data.
validate_episode_spine <- function(episode_spine) {
  # TODO: Check required columns/types, nonmissing unique episode_id, episode coverage, dates/order, and source-dependent rating bounds.
  stop("validate_episode_spine(): Not implemented yet.", call. = FALSE)
}

#' Validate the combined episode-level analytic table.
#' @param episode_features Combined analytic tibble.
#' @return TRUE on success; abort with actionable details on invalid data.
validate_episode_features <- function(episode_features) {
  # TODO: Check unique episode_id, required columns/types, spine row preservation, feature ranges, and missingness.
  stop("validate_episode_features(): Not implemented yet.", call. = FALSE)
}
