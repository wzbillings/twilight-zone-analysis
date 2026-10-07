# The Twilight Zone Multimodal Reception Analysis: Project Plan

## Purpose

Investigate associations between textual, visual, audio, production, and temporal features and reception of the original 1959–1964 *The Twilight Zone*. This is exploratory, observational research; it does not establish causal effects or objective episode quality.

Reception is not a single current IMDb-style rating. The architecture must preserve:

- contemporary historical audience reception, such as Nielsen/ARB broadcast measurements;
- modern episode ratings and vote counts collected prospectively on repeated dates;
- longitudinal changes in modern ratings and vote counts;
- series-level dynamic attention/popularity, including TMDB metrics;
- eventual historical-to-modern reputation comparisons.

Historical broadcast measurements and modern crowd ratings arise from different measurement processes. Keep their populations, units, dates, and source definitions distinct. Vote counts and popularity are attention measures, not interchangeable measures of approval. Modern retrospective opinion may reflect reputation, nostalgia, canon formation, and episode fame.

## High-level design

R functions perform reusable computation; `targets` orchestrates dependencies and caching, and Quarto reports results. Python and external tools provide media capabilities where appropriate.

Maintain a stable episode spine and episode feature summaries separately from reception observations. Modern observations retain provider, entity identifier/level, observation date, metric definition, value, and acquisition provenance. Historical observations retain broadcast context, measurement period, units, source references, and extraction provenance. Exact schemas and collection cadence remain future work.

A one-row-per-episode feature table is still useful, but cannot represent all reception data. Repeated snapshots must not be silently collapsed to a current rating or joined in ways that duplicate feature rows. Series-level popularity must remain identifiable as series-level data. Analysis-specific joins, date selections, aggregation, and historical-to-modern comparisons require explicit scientific decisions.

## Storage architecture

These are conceptual domains, not actual filesystem paths or instructions to create directories now. The three local data domains must be outside the public working tree; the corpus and derived/cache areas must also be outside the observations Git working tree.

### A. Public analysis repository

`twilight-zone-analysis` remains public on GitHub. It contains R/Python source, `_targets.R`, Quarto analyses/reports, tests with synthetic fixtures, schemas, configuration templates, documentation, and small explicitly publishable metadata or derived numerical results. No credentials or machine-specific absolute paths belong here.

Real raw acquisition outputs do not belong in this repository. Never place, commit, push, or publish potentially copyrighted media, transcripts, captions, stills, or archival source reproductions here. Review even numerical outputs before publication for rights and possible reconstruction of source content.

### B. Local observations repository

A separate local-only Git repository preserves small structured research observations that are historically valuable and may be impossible to reconstruct later. It will have **no GitHub remote** under the current design. Essentially everything placed in it should be suitable for local Git tracking; it is not a mixed store requiring extensive media exclusions.

Conceptual layout:

```text
observations/
  modern/
    imdb/
    tmdb/
    tvmaze/
    omdb/
  historical/
    audience/
    archival_extractions/
  crosswalks/
  manifests/
  provenance/
  README.md
```

Contents include dated rating and vote-count snapshots, TMDB attention/popularity snapshots, canonical/provider crosswalks, acquisition-run provenance, manually extracted Nielsen/ARB measurements, and structured archival research results. Structured extractions mean observations and source references, not copied articles or transcript passages.

The initial location will be on the user's current data SSD, with a possible later move to a dedicated physical drive. No actual path is chosen and no repository is created in this job. Local Git history preserves revisions; it does not make this material approved for public redistribution.

### C. Local corpus store

Large and/or potentially copyrighted sources live outside Git entirely. No `.git` repository may govern the corpus, including through a parent working tree.

```text
corpus/
  transcripts/
  video/
    disc_images/
    episodes/
    clips/
  audio/
  subtitles/
  images/
  archival_sources/
```

This includes ripped/remuxed episode files, disc images, extracted audio, copied transcripts, captions, frames/stills, and archival PDFs/scans whose redistribution rights are unclear. Listing these storage categories does not add ripping or acquisition automation; the media pipeline still begins with canonical local files already available to the user.

The observations repository may later hold manifests of corpus-relative paths, hashes, sizes, and provenance without tracking the media. Preserve source inputs as immutable files.

### D. Local derived/cache storage

Reproducible or disposable machine-generated artifacts belong in external non-Git storage, especially when large:

```text
derived/
  audio_features/
  video_features/
  embeddings/
  transcript_features/
  scene_detection/
  temporary/
targets/
logs/
```

These conceptual areas need not share a physical parent directory. Regenerable intermediates and caches generally do not need Git history. Cleaned transcript text, sampled frames, audio derivatives, and proxies remain outside Git even when reproducible; derivation does not remove copyright concerns. Small safe results may be deliberately selected for publication.

The physical placement of the targets store remains undecided. Fast local storage may be preferable to a future spinning HDD; this job makes no placement decision.

### Configuration contract and relocation

The public project resolves external roots through machine-local configuration/environment variables:

| Variable | Intended role |
| --- | --- |
| `TZ_OBSERVATIONS_ROOT` | Root of the separate local observations Git repository. |
| `TZ_CORPUS_ROOT` | Root of the unversioned source corpus. |
| `TZ_DERIVED_ROOT` | Root of reproducible derived artifacts and temporary work. |
| `TZ_LOGS_ROOT` | Local runtime logs; durable acquisition provenance belongs with observations. |
| `TZ_TARGETS_STORE` | Optional targets cache location; fallback and physical placement remain undecided. |

Job 2 implements this contract; see [configuration and helper semantics](STORAGE_CONFIGURATION.md). Moving data requires changing machine-local configuration only, not committed R code. Relative corpus manifests remain valid when a root moves. No actual paths are selected or real directories created. Job 3 will bootstrap storage. An unset optional targets store returns `NULL`; targets wiring and placement remain deferred.

### Safety boundary and transition

Physical separation is the primary boundary: public reproducible methods and safe outputs, local Git history for irreplaceable structured observations, and unversioned corpus/derived storage. `.gitignore` provides defense-in-depth only; it neither removes tracked files nor authorizes redistribution. Backups are important, especially for observations that cannot be reconstructed, but backup design and implementation are explicitly outside the current architecture scope.

Earlier instructions to store real inputs under `data/raw/`, including its ratings, metadata, video, audio, and transcripts subdirectories, are superseded. Existing directories and ignore guards remain; repo-local `data/` is reserved for synthetic fixtures, tiny explicitly publishable examples, or safe derived results. Do not populate legacy paths with actual sources.

`R/00_paths.R` now provides explicit external-domain helpers; the unused repo-local raw/interim/features/analytic helpers have been removed. The ingestion, spine, validation, and `_targets.R` placeholders still assume a selected rating snapshot joined to the episode spine. Those pipeline assumptions remain implementation debt, not the new storage or reception contract. The provisional data dictionary labels these legacy interfaces. The earlier `twilight-zone-ratings.qmd` exploration is preserved, not adopted as an acquisition workflow.

## Public repository organization

Keep the existing `R/`, `python/`, `reports/`, `tests/`, `docs/`, and `notes/` organization. Add schemas, configuration templates, or publishable metadata deliberately when needed. The existing project file remains `twilight-zone-ratings.Rproj`; its filename does not change the public repository name. Existing `output/` ignore rules remain guards for local outputs, not a mandate to store large intermediates here.

## Central episode spine

Use stable `series_id` and `episode_id` identifiers, never title alone. The spine should describe canonical identity, season/episode order where applicable, title, air date, runtime, and production metadata. Provider crosswalks connect observations to these identities; corpus manifests connect identities to local sources.

Reception measurements belong in separate tables. Coverage, runtime differences, missing modalities, and source availability need explicit validation. Final schemas, keys, and migrations from scaffold fields remain future implementation work.

## Roadmap and scope

This architectural documentation update is Job 1. It does not create local stores, acquire data, implement API clients or snapshot writing, change dependencies, configure Windows automation, or modify the targets DAG.

**Job 2 is implemented:** machine-local storage/path helpers replace the legacy repo-local data helpers. **Job 3** will bootstrap real storage and the local observations repository; it has not begun.

Later jobs can define observation schemas, provider crosswalks, collection cadence and provenance; collect modern snapshots prospectively; and encode historical audience observations separately. Implement one source family at a time. Feature extraction phases below remain candidate research work; final inferential models, variable selection, and conclusions require human decisions.

## Phase 1: Reception observations and time/order

Establish the canonical episode spine and retain dated observations in the local observations repository. Start with provider-specific definitions for modern ratings, vote counts, and attention; preserve repeated dates rather than overwriting history. Record historical Nielsen/ARB observations with their original measurement context.

Distinguish three clocks: original broadcast dates, modern observation dates, and acquisition/extraction timestamps. Rating-by-air-date plots describe retrospective opinion ordered by broadcast history; they are not longitudinal rating trajectories. Longitudinal analysis requires repeated observation dates.

Candidate episode covariates include season, episode order, air date, days since premiere, broadcast gaps, runtime, and Season 4's hour-long format. Descriptive summaries can examine each reception domain separately before any model is selected.

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

Store human-authored, publishable lexicons in a reviewable public metadata/configuration file (for example, `metadata/theme_lexicons.csv`). Keep machine-generated intermediates under the external derived root.

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

Keep source video in the external corpus and generated audio, proxies, and frames in external non-Git storage. None belongs in the public working tree.

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

## Phase 6: Episode features and analysis-specific tables

Store reproducible episode feature tables under the external derived root, using Parquet when justified. Publish only deliberately reviewed, small safe numerical results.

Keep one row per episode in the feature summary. Join reception tables only for an explicitly selected analysis, with provider, metric, entity level, and observation/broadcast date retained as appropriate. Longitudinal tables have repeated observations; historical audience and series-level popularity require their own keys and semantics.

Example feature groups:

```text
# episode identifiers
episode_id
title

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

## Analysis and reporting decisions

There are 156 episodes in the original series. Repeated observations do not create additional independent episodes. Final statistical models, outcome priorities, adjustment variables, resampling strategies, and causal interpretations are not selected by this architecture.

Candidate feature-family comparisons remain time/order, production metadata, text, video, audio, and combined summaries. Any later evaluation must respect observation dates, provider scales, entity level, and dependence among repeated measurements. Historical-to-modern reputation comparisons require an explicit comparability argument; do not pool historical audience measurements with crowd ratings by default.

Reports should distinguish:

- historical audience reception and its measurement limits;
- modern ratings and vote counts at stated provider/date selections;
- longitudinal changes in modern reception;
- series-level attention/popularity over observation dates;
- multimodal associations and eventual historical-to-modern comparisons;
- missingness, source coverage, uncertainty, and limitations.

Season 4 treatment, culturally canonical episodes, source/release differences, and feature stability remain potential sensitivity questions for later human review.

## Targets scaffold transition

The existing `_targets.R` is a non-runnable placeholder graph: metadata and one ratings table feed a spine, feature families are summarized by episode, validation gates assembly, and placeholder model/report targets follow. It is intentionally unchanged here.

Future storage and reception work must make external file dependencies explicit and keep computation in ordinary functions. The current graph and rating fields do not define the final longitudinal or historical acquisition design. Do not run it to validate this documentation update.

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

Before the relevant implementation or analysis:

1. Define provider-specific rating scales, vote-count availability, attention metrics, collection cadence, and observation schemas.
2. Define historical audience units, broadcast context, source coverage, and extraction quality checks.
3. Choose local roots through machine configuration and decide targets-store placement.
4. Finalize video naming, transcript coverage/speaker labels, and source/release provenance.
5. Decide Season 4 treatment, interpretable versus embedding features, and granular feature retention.
6. Select scientific questions and appropriate analysis designs for each reception domain and eventual reputation comparisons.

The public repository's storage boundary and local-only observations policy are decided above; they are not open questions.
