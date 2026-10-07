# Scaffold only: sourcing this file performs no work.
# Expected tibble schemas are provisional; see notes/data-dictionary.md.

#' Read locally supplied episode production metadata.
#' @return Tibble: episode_id (character), title, season, episode_number, series_order, air_date (Date), runtime_minutes, writer, director.
read_episode_metadata <- function() {
  # TODO: Choose a documented local metadata format and preserve source provenance.
  stop("read_episode_metadata(): Not implemented yet.", call. = FALSE)
}

#' Read locally supplied cast metadata.
#' @return Tibble: episode_id (character), person_id (character), actor_name, character_name; multiple rows per episode.
read_cast_metadata <- function() {
  # TODO: Define cast identifiers and credit coding before reading local files.
  stop("read_cast_metadata(): Not implemented yet.", call. = FALSE)
}
