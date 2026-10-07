# Scaffold only: sourcing this file performs no work.
# Expected tibble schemas are provisional; see notes/data-dictionary.md.

#' List locally available episode videos.
#' @return Character vector of local video paths.
list_video_files <- function() {
  # TODO: Resolve the naming convention and video extensions; no downloads.
  stop("list_video_files(): Not implemented yet.", call. = FALSE)
}

#' Call the future Python scene detector on local videos.
#' @param video_files Character vector of local video paths.
#' @return Scene-level tibble: episode_id, video_path, scene_number, start_time_seconds, end_time_seconds, duration_seconds.
extract_scene_features_python <- function(video_files) {
  # TODO: Map files to episode_id, invoke detect_scenes.py, and read its future output.
  stop("extract_scene_features_python(): Not implemented yet.", call. = FALSE)
}

#' Call the future Python frame extractor on local videos.
#' @param video_files Character vector of local video paths.
#' @return Frame-level tibble: episode_id, frame_time_seconds, mean_luminance, sd_luminance, contrast, dark_pixel_prop, bright_pixel_prop, edge_density, face_count, largest_face_area_prop.
extract_frame_features_python <- function(video_files) {
  # TODO: Specify frame sampling and invoke extract_video_features.py.
  stop("extract_frame_features_python(): Not implemented yet.", call. = FALSE)
}

#' Aggregate scene and frame features by episode.
#' @param scene_features Scene-level feature tibble.
#' @param frame_features Frame-level feature tibble.
#' @return Episode-level tibble: episode_id, scene_count, mean_scene_duration_seconds, mean_luminance, mean_contrast, mean_dark_pixel_prop, mean_bright_pixel_prop, mean_edge_density, mean_face_count, mean_largest_face_area_prop.
combine_video_features <- function(scene_features, frame_features) {
  # TODO: Aggregate each granular source before joining; document weighting and missingness.
  stop("combine_video_features(): Not implemented yet.", call. = FALSE)
}
