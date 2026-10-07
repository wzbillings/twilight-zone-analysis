# Scaffold only: sourcing this file performs no work.
# Expected tibble schemas are provisional; see notes/data-dictionary.md.

#' List locally available transcript files.
#' @return Character vector of local transcript paths.
list_transcript_files <- function() {
  # TODO: Resolve the naming convention and allowed extensions; no downloads.
  stop("list_transcript_files(): Not implemented yet.", call. = FALSE)
}

#' Clean one local transcript.
#' @param path Character path to a local transcript.
#' @return Tibble: episode_id (character), text (character); one row per episode.
clean_transcript_file <- function(path) {
  # TODO: Define narration, stage-direction, speaker-label, and punctuation handling.
  stop("clean_transcript_file(): Not implemented yet.", call. = FALSE)
}

#' Clean all supplied local transcripts.
#' @param transcript_files Character vector of transcript paths.
#' @return Tibble: episode_id (character), text (character); one row per episode.
clean_all_transcripts <- function(transcript_files) {
  # TODO: Apply clean_transcript_file and check identifier uniqueness; keep text local.
  stop("clean_all_transcripts(): Not implemented yet.", call. = FALSE)
}

#' Summarize transcripts into episode-level features.
#' @param clean_transcripts Tibble with episode_id and text.
#' @return Tibble: episode_id, word_count, lexical_diversity, mean_sentence_length, sentiment_score.
extract_text_features <- function(clean_transcripts) {
  # TODO: Specify tokenization and sentiment methods; avoid retaining full text in public features.
  stop("extract_text_features(): Not implemented yet.", call. = FALSE)
}
