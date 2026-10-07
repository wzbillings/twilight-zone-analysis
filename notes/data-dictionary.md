# Data dictionary

Provisional schemas document interfaces, not measured data. Feature definitions will be finalized before implementation. All episode-level tables use a nonmissing, unique character `episode_id`; granular outputs repeat this key. Missing measurements are NA, not zero. No raw text or media belongs in the combined analytic table.

## Episode spine

| Column | R type | Meaning |
| --- | --- | --- |
| episode_id | character | Canonical, nonmissing unique join key; final format pending. |
| title | character | Episode title. |
| season | integer | Original broadcast season. |
| episode_number | integer | Episode order within season. |
| series_order | integer | Episode order across the series. |
| air_date | Date | Original air date. |
| runtime_minutes | double | Episode runtime in minutes. |
| rating | double | Modern viewer rating; source and scale pending. |
| vote_count | integer | Rating vote count when available; otherwise missing. |
| rating_source | character | Source identifier. |
| rating_observed_at | Date | Date of rating observation. |

## Metadata features

| Column | R type | Meaning |
| --- | --- | --- |
| episode_id | character | Canonical join key. |
| writer | character | Writer credit coding pending; multiple credits need an explicit rule. |
| director | character | Director credit coding pending. |
| cast_count | integer | Count of cast members under agreed credit rule. |

## Text features

| Column | R type | Meaning |
| --- | --- | --- |
| episode_id | character | Canonical join key. |
| word_count | integer | Token count after agreed cleaning. |
| lexical_diversity | double | Provisional type/token measure; exact estimator pending. |
| mean_sentence_length | double | Mean tokens per sentence. |
| sentiment_score | double | Episode summary; method and scale pending. |

## Video features: episode summaries

| Column | R type | Meaning |
| --- | --- | --- |
| episode_id | character | Canonical join key. |
| scene_count | integer | Number of detected scenes/shots under agreed detector settings. |
| mean_scene_duration_seconds | double | Mean scene/shot duration in seconds. |
| mean_luminance | double | Episode summary; sampling, weighting, and estimator pending. |
| mean_contrast | double | Episode summary; sampling, weighting, and estimator pending. |
| mean_dark_pixel_prop | double | Episode summary; sampling, weighting, and estimator pending. |
| mean_bright_pixel_prop | double | Episode summary; sampling, weighting, and estimator pending. |
| mean_edge_density | double | Episode summary; sampling, weighting, and estimator pending. |
| mean_face_count | double | Episode summary; sampling, weighting, and estimator pending. |
| mean_largest_face_area_prop | double | Episode summary; sampling, weighting, and estimator pending. |

## Audio features: episode summaries

| Column | R type | Meaning |
| --- | --- | --- |
| episode_id | character | Canonical join key. |
| mean_rms | double | Episode mean across audio windows; windowing/weighting pending. |
| mean_spectral_centroid | double | Episode mean across audio windows; windowing/weighting pending. |
| mean_spectral_bandwidth | double | Episode mean across audio windows; windowing/weighting pending. |
| mean_zero_crossing_rate | double | Episode mean across audio windows; windowing/weighting pending. |
| mean_mfcc_1 | double | Episode mean across audio windows; windowing/weighting pending. |
| mean_mfcc_2 | double | Episode mean across audio windows; windowing/weighting pending. |
| mean_mfcc_3 | double | Episode mean across audio windows; windowing/weighting pending. |

## Granular Python output: detect_scenes

| Column | R type | Meaning |
| --- | --- | --- |
| episode_id | character | Canonical episode join key. |
| video_path | character | Local input path; keep local. |
| scene_number | integer | Granular measurement; definition, units, and sampling settings to be finalized. |
| start_time_seconds | double | Seconds relative to the start of the local media file. |
| end_time_seconds | double | Seconds relative to the start of the local media file. |
| duration_seconds | double | Seconds relative to the start of the local media file. |

## Granular Python output: extract_video_features

| Column | R type | Meaning |
| --- | --- | --- |
| episode_id | character | Canonical episode join key. |
| frame_time_seconds | double | Seconds relative to the start of the local media file. |
| mean_luminance | double | Granular measurement; definition, units, and sampling settings to be finalized. |
| sd_luminance | double | Granular measurement; definition, units, and sampling settings to be finalized. |
| contrast | double | Granular measurement; definition, units, and sampling settings to be finalized. |
| dark_pixel_prop | double | Proportion in [0, 1]; thresholds/estimator pending. |
| bright_pixel_prop | double | Proportion in [0, 1]; thresholds/estimator pending. |
| edge_density | double | Granular measurement; definition, units, and sampling settings to be finalized. |
| face_count | integer | Granular measurement; definition, units, and sampling settings to be finalized. |
| largest_face_area_prop | double | Proportion in [0, 1]; thresholds/estimator pending. |

## Granular Python output: extract_audio_features

| Column | R type | Meaning |
| --- | --- | --- |
| episode_id | character | Canonical episode join key. |
| window_start_seconds | double | Seconds relative to the start of the local media file. |
| window_end_seconds | double | Seconds relative to the start of the local media file. |
| rms | double | Granular measurement; definition, units, and sampling settings to be finalized. |
| spectral_centroid | double | Frequency measurement in Hz. |
| spectral_bandwidth | double | Frequency measurement in Hz. |
| zero_crossing_rate | double | Granular measurement; definition, units, and sampling settings to be finalized. |
| mfcc_1 | double | Granular measurement; definition, units, and sampling settings to be finalized. |
| mfcc_2 | double | Granular measurement; definition, units, and sampling settings to be finalized. |
| mfcc_3 | double | Granular measurement; definition, units, and sampling settings to be finalized. |

## Combined analytic table

One row per canonical episode, preserving the episode spine. Columns are the full episode spine schema plus non-key columns from metadata, text, video summaries, and audio summaries above. `episode_id` occurs once. No scene/frame/window rows may be joined directly to the spine. Missing modality coverage remains explicit; no imputation policy has been selected.

## Supporting local inputs and modeling outputs

- Episode metadata input contains spine metadata plus writer/director credits.
- Ratings input contains episode_id, rating, vote_count, rating_source, and rating_observed_at.
- Cast input contains episode_id, person_id, actor_name, and character_name (all character); multiple rows per episode are expected.
- Clean transcripts contain episode_id and text (character), one row per episode, and must remain local.
- Model functions will return a list with model_name (character), fit (model/workflow), and metrics (tibble).
- Model comparison contains model_name and metric (character), estimate and std_error (double). Estimation and resampling choices remain pending.

## Local transcript filenames

Use `sSSeeEE.txt`, with two-digit season and episode numbers in original broadcast order: for example, `s01e01.txt` and `s05e36.txt`. The filename stem identifies the episode for transcript mapping. Season counts are 36, 29, 37, 18, and 36, giving 156 local placeholders. Save pasted text as UTF-8. Empty files indicate missing transcripts; future ingestion must not treat them as zero-word transcripts. All transcript files remain excluded from Git.
