# Scaffold only: sourcing this file performs no work.
# Expected tibble schemas are provisional; see notes/data-dictionary.md.

#' Build episode-level production metadata features.
#' @param episode_spine Canonical episode spine tibble.
#' @param cast_metadata Cast credit tibble with multiple rows per episode.
#' @return Episode-level tibble: episode_id, writer, director, cast_count.
build_metadata_features <- function(episode_spine, cast_metadata) {
  # TODO: Summarize cast credits before joining and define writer/director coding.
  stop("build_metadata_features(): Not implemented yet.", call. = FALSE)
}

#' Join all feature families to the canonical spine.
#' @param episode_spine Episode-level tibble keyed by episode_id.
#' @param metadata_features Episode-level tibble keyed by episode_id.
#' @param text_features Episode-level tibble keyed by episode_id.
#' @param video_features Episode-level tibble keyed by episode_id.
#' @param audio_features Episode-level tibble keyed by episode_id.
#' @return Tibble with one row per canonical episode and all documented feature columns; see notes/data-dictionary.md.
build_episode_features <- function(episode_spine, metadata_features, text_features, video_features, audio_features) {
  # TODO: Use checked left joins, preserve spine rows, and distinguish missing values from zero.
  stop("build_episode_features(): Not implemented yet.", call. = FALSE)
}
