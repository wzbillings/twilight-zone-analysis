# The Twilight Zone Multimodal Ratings Analysis: Project Plan

## Purpose

This project investigates which measurable episode-level features are associated with modern viewer ratings of the original 1959-1964 *The Twilight Zone* series.

The goal is not to prove what makes an episode objectively good. The defensible research question is:

> What textual, visual, audio, production, and temporal features are associated with IMDb-style episode ratings for *The Twilight Zone*, after accounting for season and episode order?

The project should be treated as exploratory, multimodal, and observational. Ratings reflect modern retrospective viewer opinion and are likely affected by cultural reputation, canon formation, nostalgia, and episode fame.

## High-level design

All data sources should eventually be reduced to one episode-level analytic table, with one row per episode.

```text
Raw sources
  ├── ratings
  ├── air dates / episode order
  ├── metadata: season, writer, director, cast, crew, runtime
  ├── transcripts
  └── video/audio files

Feature extraction
  ├── time/order features
  ├── metadata features
  ├── transcript/text features
  ├── video/visual features
  └── audio/sound features

Episode-level analytic dataset
  one row per episode

Models and reports
  ├── baseline time/order model
  ├── metadata model
  ├── text model
  ├── video model
  ├── audio model
  ├── combined regularized model
  └── sensitivity analyses
```

R should be the orchestration, data modeling, and reporting layer. Python and command-line tools can be used for video/audio extraction where appropriate. The recommended project backbone is an R `{targets}` pipeline with Quarto reporting.

## Scope

### In scope

- Build a reproducible R/Quarto/targets project.
- Create a validated master episode spine.
- Join episode ratings, episode order, air dates, metadata, transcripts, and video/audio-derived features.
- Extract interpretable text, video, and audio features.
- Compare feature families against baseline season/order models.
- Use regularized models and sensitivity analyses to avoid overfitting.
- Produce a final Quarto report and a reusable analytic dataset.

### Out of scope for the scaffold

- Downloading or distributing copyrighted video files.
- Downloading or redistributing full copyrighted transcripts.
- Claiming causal effects of features on ratings.
- Building a production-grade machine-learning system.
- Making the initial scaffold fully runnable before data are available.

## Legal and data-handling notes

*The Twilight Zone* is old, but age does not make it public domain. Treat transcripts and video files as copyrighted unless proven otherwise.

Recommended practice:

- Store video and transcript files locally only.
- Do not commit raw video, audio, or transcript text to Git.
- Publish only derived episode-level features, model summaries, and visualizations.
- Use `.gitignore` to exclude `data/raw/video/`, `data/raw/audio/`, and `data/raw/transcripts/`.
- If transcript scraping is implemented later, include clear comments that raw transcripts should not be redistributed.

## Central episode spine

The first durable object should be a master episode table. Every downstream table should join to this table by `episode_id`, not by title alone.

Recommended columns:

```text
episode_id
series
season
episode_in_season
episode_overall
title
air_date
rating
rating_votes
runtime_minutes
writer
director
cast_count
guest_cast_count
transcript_path
video_path
audio_path
```

Recommended validation columns:

```text
has_rating
has_transcript
has_video
has_audio
has_metadata
runtime_metadata
runtime_video
runtime_difference_seconds
transcript_word_count
video_file_size_mb
```

## Recommended repository structure

```text
twilight-zone-analysis/
  ├── twilight-zone-analysis.Rproj
  ├── README.md
  ├── renv.lock
  ├── renv/
  ├── .Rprofile
  ├── .gitignore
  ├── _targets.R
  ├── _quarto.yml
  ├── reports/
  │   ├── index.qmd
  │   ├── methods.qmd
  │   └── appendix.qmd
  ├── R/
  │   ├── 00_paths.R
  │   ├── 01_ingest_metadata.R
  │   ├── 02_ingest_ratings.R
  │   ├── 03_episode_spine.R
  │   ├── 04_text_features.R
  │   ├── 05_video_features.R
  │   ├── 06_audio_features.R
  │   ├── 07_feature_engineering.R
  │   ├── 08_models.R
  │   ├── 09_plots.R
  │   └── 10_validation.R
  ├── python/
  │   ├── requirements.txt
  │   ├── detect_scenes.py
  │   ├── extract_video_features.py
  │   └── extract_audio_features.py
  ├── data/
  │   ├── raw/
  │   │   ├── ratings/
  │   │   ├── metadata/
  │   │   ├── transcripts/
  │   │   ├── video/
  │   │   └── audio/
  │   ├── interim/
  │   ├── features/
  │   └── analytic/
  ├── output/
  │   ├── figures/
  │   ├── tables/
  │   └── models/
  ├── tests/
  │   └── testthat/
  └── notes/
      ├── data-dictionary.md
      ├── coding-decisions.md
      └── open-questions.md
```

## Phase 1: Ratings and time/order analysis

Start with ratings, air dates, season, and episode order.

### Features

```text
episode_overall
season
episode_in_season
air_date
days_since_premiere
days_since_previous_episode
season_gap_indicator
month
year
runtime_minutes
is_season_4_hourlong
```

### Analyses

- Rating by original air date.
- Rating by episode order.
- Rating distribution by season.
- Monthly rating summaries.
- Optional STL decomposition of monthly average ratings.
- Baseline models:

```r
rating ~ season + episode_overall + runtime_minutes
rating ~ factor(season) + splines::ns(episode_overall, df = 3)
```

Purpose: establish the baseline amount of rating variation explained by time/order alone.

## Phase 2: Production metadata features

Metadata features are relatively cheap and important controls.

### Features

```text
writer
director
writer_episode_count
director_episode_count
cast_count
guest_cast_count
recurring_actor_count
actor_prior_appearances
actor_future_appearances
runtime_minutes
```

Avoid overinterpreting individual writer/director/actor effects unless using shrinkage or leave-one-out summaries. With 156 episodes, sparse categorical predictors can overfit easily.

## Phase 3: Transcript/text analysis

### Transcript cleaning

For each transcript, preserve or derive:

```text
raw_text
clean_text
dialogue_text
narration_text
stage_direction_text
speaker_labels
```

Potential cleaning tasks:

- Remove website boilerplate.
- Remove headers/footers.
- Normalize whitespace.
- Preserve speaker labels where possible.
- Identify Rod Serling intro/outro where possible.
- Separate dialogue, narration, and stage directions if the transcript format supports it.

### Interpretable text features

```text
word_count
unique_word_count
type_token_ratio
mean_sentence_length
median_sentence_length
dialogue_word_count
narration_word_count
narration_prop
question_mark_count
exclamation_mark_count
question_rate
first_person_pronoun_rate
second_person_pronoun_rate
negative_word_rate
```

### Theme lexicons

Hand-build small, transparent lexicons for themes likely relevant to *The Twilight Zone*:

```text
time / clocks / age / future / past
death / grave / funeral / corpse
war / bomb / enemy / soldier
space / alien / planet / ship
machine / robot / computer / technology
identity / mirror / face / body / self
dream / nightmare / sleep / memory
justice / punishment / guilt / sin
fear / terror / panic / scream
religion / heaven / hell / devil / angel
```

Store lexicons in a data file such as `data/raw/metadata/theme_lexicons.csv` or `data/interim/theme_lexicons.rds`.

### Flexible text features

Optional later additions:

- TF-IDF terms with regularization.
- Topic model loadings.
- Episode-level embedding summaries.
- Sentiment features.

For the first full analysis, prefer a small set of interpretable features over hundreds of sparse terms.

## Phase 4: Video/visual analysis

Video analysis should be piloted on a subset before being scaled.

### Pilot subset

Start with 10 episodes:

- 5 high-rated episodes.
- 5 lower-rated episodes.

Use this pilot to verify whether feature extraction behaves sensibly on black-and-white television footage.

### Preprocessing

Use FFmpeg/ffprobe externally or through Python/R wrappers.

Recommended proxy workflow:

```text
input video
  ├── inspect metadata with ffprobe
  ├── extract standardized analysis audio
  ├── optionally create downsampled video proxy
  └── sample frames at a fixed interval
```

Raw video files should not be committed to Git.

### Shot/scene features

Use PySceneDetect or equivalent.

Episode-level shot features:

```text
n_shots
cuts_per_minute
mean_shot_length
median_shot_length
sd_shot_length
p10_shot_length
p90_shot_length
long_take_count
short_shot_count
```

### Frame-level visual features

Sample one frame every 1-5 seconds initially. Compute frame-level features and aggregate to episode level.

Frame-level candidates:

```text
mean_luminance
sd_luminance
p10_luminance
p90_luminance
contrast
dark_pixel_prop
bright_pixel_prop
edge_density
visual_complexity
center_luminance
border_luminance
```

Episode-level summaries:

```text
mean_luminance_mean
mean_luminance_sd
dark_pixel_prop_mean
dark_pixel_prop_p90
contrast_mean
contrast_sd
edge_density_mean
edge_density_sd
```

### Face/close-up features

Optional, noisier, but potentially useful:

```text
face_frame_prop
mean_face_count_when_present
largest_face_area_prop_mean
total_face_area_prop_mean
closeup_prop
two_plus_face_prop
face_centeredness_mean
```

Face detection may be less reliable on black-and-white 1950s/1960s footage, so this should be validated manually.

## Phase 5: Audio/sound analysis

Extract mono audio from each episode, then compute features over short windows.

Recommended window size: start with 1-second or 5-second windows.

### Basic audio features

```text
rms_mean
rms_sd
rms_p10
rms_p90
dynamic_range
silence_prop
low_energy_prop
high_energy_prop
spectral_centroid_mean
spectral_centroid_sd
spectral_bandwidth_mean
zero_crossing_rate_mean
mfcc_1_mean
mfcc_2_mean
mfcc_3_mean
...
mfcc_13_mean
```

### Optional advanced audio features

```text
speech_prop
music_prop
mean_pause_length
dramatic_silence_count
speaker_change_rate
speech_rate_proxy
```

These are useful but harder. They should not block the first complete version.

## Phase 6: Combined analytic table

The combined table should live at something like:

```text
data/analytic/episode_features.parquet
data/analytic/episode_features.csv
```

The dataset should include one row per episode and columns for rating, time/order, metadata, text, video, and audio features.

Example feature groups:

```text
# identifiers/outcome
episode_id
title
rating
rating_votes

# time/order
season
episode_overall
episode_in_season
air_date
runtime_minutes
is_season_4_hourlong

# metadata
cast_count
guest_cast_count
writer_episode_count
director_episode_count
recurring_actor_count

# text
word_count
narration_prop
mean_sentence_length
type_token_ratio
question_rate
death_word_rate
time_word_rate
technology_word_rate
identity_word_rate
fear_word_rate

# video
cuts_per_minute
mean_shot_length
shot_length_sd
mean_luminance
dark_frame_prop
contrast_mean
edge_density_mean
closeup_prop

# audio
rms_mean
rms_sd
dynamic_range
silence_prop
spectral_centroid_mean
mfcc_1_mean
mfcc_2_mean
mfcc_3_mean
```

## Modeling strategy

The project has only 156 episode-level observations. Model complexity must be constrained.

### Primary outcome

```text
rating
```

### Secondary outcomes

```text
rating_residual_after_season_order_adjustment
top_quartile_rating_indicator
log_rating_votes
```

The residualized rating outcome is especially useful:

```r
baseline <- lm(rating ~ factor(season) + episode_overall, data = episode_features)
episode_features$rating_resid <- residuals(baseline)
```

Then ask which features are associated with episodes rated higher than expected for their season/order.

### Model sequence

1. Baseline time/order model.
2. Metadata model.
3. Text-only incremental model.
4. Video-only incremental model.
5. Audio-only incremental model.
6. Combined regularized model.
7. Optional Bayesian shrinkage model.

### Recommended model families

- Linear regression for simple baselines.
- Robust regression as a sensitivity analysis.
- Ridge/elastic net regression for high-dimensional combined models.
- Random forest or gradient boosting only as exploratory nonlinear checks.
- Bayesian models with regularizing priors if using a smaller, theory-driven feature set.

### Model comparison metrics

```text
RMSE
MAE
cross-validated R²
observed-vs-predicted correlation
incremental performance over baseline
feature-selection stability
```

## Sensitivity analyses

Recommended checks:

1. Exclude Season 4, because those episodes are hour-long.
2. Model residual rating after adjusting for season and episode order.
3. Model top-quartile rating as a binary outcome.
4. Exclude culturally canonical episodes to assess outlier influence.
5. Use robust regression.
6. Bootstrap or repeated-CV feature stability.
7. Include source/release indicators if video files come from different transfers.
8. Compare results with and without rating vote count adjustment.

## Reporting plan

The main Quarto report should answer:

1. How do ratings vary across time, season, and episode order?
2. Do production metadata features explain rating variation?
3. Are higher-rated episodes textually different?
4. Are higher-rated episodes visually different?
5. Are higher-rated episodes sonically different?
6. Do multimodal features improve prediction beyond season/order?
7. Which associations are stable across sensitivity analyses?
8. What can and cannot be concluded?

## Suggested timeline

Assuming data files are available and the project is part-time:

| Phase | Duration | Output |
|---|---:|---|
| 1. Project setup | 2-3 days | R project, renv, targets, Quarto structure |
| 2. Episode spine + ratings | 2-4 days | Validated master episode table |
| 3. Metadata ingestion | 3-5 days | Cast/crew/writer/director features |
| 4. Transcript cleaning | 1 week | Clean transcript corpus and transcript QC |
| 5. Text feature extraction | 1 week | Episode-level text feature table |
| 6. Video/audio pilot | 1 week | Extraction validated on 10 episodes |
| 7. Full video extraction | 1-2 weeks | Visual and shot features for all episodes |
| 8. Full audio extraction | 1 week | Audio feature table |
| 9. Combined feature table | 3-5 days | Final analytic dataset |
| 10. Modeling | 1-2 weeks | Baseline, family-specific, and combined models |
| 11. Sensitivity analyses | 1 week | Robustness checks |
| 12. Quarto report | 1 week | Final report and appendix |

A minimal feasibility version can be done in 2-3 weeks:

```text
Week 1: episode spine, ratings, metadata, transcript ingestion
Week 2: basic text features and 10-episode video/audio pilot
Week 3: simple models and preliminary report
```

## Initial targets pipeline shape

The scaffold should include a placeholder `_targets.R` with this conceptual shape:

```r
library(targets)
library(tarchetypes)

tar_option_set(
  packages = c(
    "tidyverse", "lubridate", "tidymodels", "glmnet",
    "tidytext", "textrecipes", "arrow", "qs"
  )
)

list(
  tar_target(raw_episode_metadata, read_episode_metadata()),
  tar_target(raw_ratings, read_episode_ratings()),
  tar_target(episode_spine, build_episode_spine(raw_episode_metadata, raw_ratings)),

  tar_target(transcript_files, list_transcript_files()),
  tar_target(clean_transcripts, clean_all_transcripts(transcript_files)),
  tar_target(text_features, extract_text_features(clean_transcripts)),

  tar_target(cast_metadata, read_cast_metadata()),
  tar_target(metadata_features, build_metadata_features(episode_spine, cast_metadata)),

  tar_target(video_files, list_video_files()),
  tar_target(scene_features, extract_scene_features_python(video_files)),
  tar_target(frame_features, extract_frame_features_python(video_files)),
  tar_target(video_features, combine_video_features(scene_features, frame_features)),

  tar_target(audio_files, extract_audio_files_python(video_files)),
  tar_target(audio_features, extract_audio_features_python(audio_files)),

  tar_target(
    episode_features,
    build_episode_features(
      episode_spine,
      metadata_features,
      text_features,
      video_features,
      audio_features
    )
  ),

  tar_target(model_baseline, fit_baseline_model(episode_features)),
  tar_target(model_metadata, fit_metadata_model(episode_features)),
  tar_target(model_text, fit_text_model(episode_features)),
  tar_target(model_video, fit_video_model(episode_features)),
  tar_target(model_audio, fit_audio_model(episode_features)),
  tar_target(model_combined, fit_combined_model(episode_features)),

  tar_target(
    model_comparison,
    compare_models(
      model_baseline,
      model_metadata,
      model_text,
      model_video,
      model_audio,
      model_combined
    )
  ),

  tar_render(report, "reports/index.qmd")
)
```

## Initial package/tool choices

### R

```text
tidyverse
lubridate
janitor
arrow
qs
here
fs
targets
tarchetypes
quarto
tidymodels
glmnet
broom
tidytext
textrecipes
quanteda or tidytext, if needed
ggplot2
patchwork
testthat
```

### Python

```text
pandas
numpy
opencv-python
scikit-image
scenedetect
librosa
soundfile
moviepy, optional
```

### Command-line tools

```text
ffmpeg
ffprobe
```

## Open decisions for the user

These do not block the scaffold, but they matter before real implementation:

1. What exact rating source should be treated as canonical?
2. Will rating vote counts be available?
3. What file naming convention will be used for video files?
4. What file naming convention will be used for transcripts?
5. Are transcripts speaker-labeled?
6. Are video files all from the same release/transfer/source quality?
7. Should Season 4 be included in the main analysis or only in sensitivity analyses?
8. Should the project use only interpretable features, or also embeddings/deep-learning features?
9. Should raw derived frame/audio window-level features be retained, or only episode summaries?
10. Should the final public repo include only code and synthetic/example data?

## Recommended first implementation target

The first implementation should not try to do everything. It should scaffold the repository and create placeholders for the following deliverables:

1. Validated episode spine.
2. Text feature extractor.
3. Video feature extractor interface.
4. Audio feature extractor interface.
5. Combined episode feature table.
6. Baseline model functions.
7. Placeholder Quarto report.
8. Data dictionary and open-questions document.

Once the scaffold exists, implement one source family at a time.
