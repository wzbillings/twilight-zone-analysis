library(targets)
library(tarchetypes)

tar_source("R")

tar_option_set(
  packages = c(
    "tidyverse", "lubridate", "janitor", "arrow", "qs",
    "tidymodels", "glmnet", "broom", "tidytext", "textrecipes"
  )
)

# Placeholder graph: data and function implementations are required before execution.
list(
  tar_target(raw_episode_metadata, read_episode_metadata()),
  tar_target(raw_ratings, read_episode_ratings()),
  tar_target(episode_spine, build_episode_spine(raw_episode_metadata, raw_ratings)),
  tar_target(spine_validation, validate_episode_spine(episode_spine)),
  tar_target(transcript_files, list_transcript_files()),
  tar_target(clean_transcripts, clean_all_transcripts(transcript_files)),
  tar_target(text_features, extract_text_features(clean_transcripts)),
  tar_target(cast_metadata, read_cast_metadata()),
  tar_target(metadata_features, {
    spine_validation
    build_metadata_features(episode_spine, cast_metadata)
  }),
  tar_target(video_files, list_video_files()),
  tar_target(scene_features, extract_scene_features_python(video_files)),
  tar_target(frame_features, extract_frame_features_python(video_files)),
  tar_target(video_features, combine_video_features(scene_features, frame_features)),
  tar_target(audio_files, extract_audio_files_python(video_files)),
  tar_target(audio_features, extract_audio_features_python(audio_files)),
  tar_target(episode_features, {
    spine_validation
    build_episode_features(
      episode_spine, metadata_features, text_features, video_features, audio_features
    )
  }),
  tar_target(feature_validation, validate_episode_features(episode_features)),
  tar_target(model_baseline, {
    feature_validation
    fit_baseline_model(episode_features)
  }),
  tar_target(model_metadata, {
    feature_validation
    fit_metadata_model(episode_features)
  }),
  tar_target(model_text, {
    feature_validation
    fit_text_model(episode_features)
  }),
  tar_target(model_video, {
    feature_validation
    fit_video_model(episode_features)
  }),
  tar_target(model_audio, {
    feature_validation
    fit_audio_model(episode_features)
  }),
  tar_target(model_combined, {
    feature_validation
    fit_combined_model(episode_features)
  }),
  tar_target(model_comparison, compare_models(
    model_baseline, model_metadata, model_text,
    model_video, model_audio, model_combined
  )),
  tar_render(report, "reports/index.qmd")
)
