# Scaffold only: sourcing this file performs no work.
# Expected tibble schemas are provisional; see notes/data-dictionary.md.

#' Extract local audio tracks from supplied videos in the future.
#' @param video_files Character vector of local video paths.
#' @return Character vector of local audio paths mapped to episode_id by a documented convention.
extract_audio_files_python <- function(video_files) {
  # TODO: Define the future FFmpeg invocation and audio format; this scaffold executes no media tools.
  stop("extract_audio_files_python(): Not implemented yet.", call. = FALSE)
}

#' Call the future Python audio extractor and summarize windows.
#' @param audio_files Character vector of local audio paths.
#' @return Episode-level tibble: episode_id, mean_rms, mean_spectral_centroid, mean_spectral_bandwidth, mean_zero_crossing_rate, mean_mfcc_1, mean_mfcc_2, mean_mfcc_3.
extract_audio_features_python <- function(audio_files) {
  # TODO: Invoke extract_audio_features.py and aggregate its window-level output before returning.
  stop("extract_audio_features_python(): Not implemented yet.", call. = FALSE)
}
