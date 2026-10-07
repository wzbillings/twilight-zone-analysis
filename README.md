# twilight-zone-ratings

`twilight-zone-analysis` is an alias for this project. The canonical repository and RStudio project name is `twilight-zone-ratings`.

## Goal and current status

Investigate which episode-level time/order, production metadata, transcript/text, video/visual, and audio/sound features are associated with modern viewer ratings of the original 1959–1964 *The Twilight Zone* series.

**Scaffold only:** no data are included, no extraction or models are implemented, and the targets pipeline is intentionally not runnable yet. This is an observational, exploratory project; associations will not establish causal effects.

## Local data and outputs

Supply appropriately obtained sources locally:

- `data/raw/ratings/`: ratings, vote counts, and source/observation provenance.
- `data/raw/metadata/`: episode and cast metadata.
- `data/raw/transcripts/`: local transcripts.
- `data/raw/video/`: local episode videos.
- `data/raw/audio/`: local or eventually extracted audio tracks.
- `data/interim/`: cleaned intermediate data, including local transcript text.
- `data/features/`: feature extraction results.
- `data/analytic/`: combined episode-level analytic table.
- `output/figures/`, `output/tables/`, `output/models/`: generated outputs.

Raw transcripts, video, and audio are excluded from Git because they may be copyrighted and media files are large. Generated output directories are also ignored except for `.gitkeep` files. Review all other derived files before sharing: cleaned transcripts in `data/interim/` still contain copyrighted text and must remain local. Git ignore rules do not authorize redistribution or remove already tracked files.

## Planned pipeline

`_targets.R` sources the numbered `R/` modules and describes these stages:

1. Read local metadata and ratings; construct and validate the canonical episode spine.
2. Clean local transcripts and summarize text features; derive production metadata features.
3. Detect scenes and sample video frames through Python placeholders.
4. Extract audio locally in a future FFmpeg integration, then compute and summarize audio windows through Python.
5. Aggregate every feature family to one row per `episode_id`, join to the spine, and validate the analytic table.
6. Fit baseline, metadata, text, video, audio, and combined association models using a shared future evaluation design.
7. Compare models and render the main Quarto report.

Validation targets gate downstream assembly and modeling. Granular scene/frame/window data must be summarized before analytic joins. Missing feature measurements must remain distinguishable from zero.

## Future setup and execution

Open `twilight-zone-ratings.Rproj` with the project root as the working directory. `.Rprofile` activates `renv` only if its activation script exists. The existing `renv` setup and lockfile are preserved; this scaffold does not initialize, install, or restore anything. The current lockfile may need updating when future dependencies are chosen.

Planned R dependencies are `targets`, `tarchetypes`, `tidyverse`, `lubridate`, `janitor`, `arrow`, `qs`, `tidymodels`, `glmnet`, `broom`, `tidytext`, `textrecipes`, and `testthat` for tests. Quarto is the reporting CLI. Likely Python dependencies are listed in `python/requirements.txt`; FFmpeg will be a separate system dependency. Python help uses only the standard library.

After implementing the functions, supplying local inputs, and deliberately configuring dependencies, the intended command is:

```r
targets::tar_make()
```

Until then, extraction and R analysis functions fail with informative unimplemented messages. Python script interfaces use `--episode-id`, `--input`, and `--output`; `python python/detect_scenes.py --help` documents one interface without requiring media packages.

Future report chunks can use `targets::tar_read()` for pipeline outputs. The current reports contain prose placeholders only; `_quarto.yml` limits website rendering to the three files in `reports/` and writes to `_site/`.

## Extending the scaffold

Use snake_case and explicit tibble columns. See `notes/data-dictionary.md` for provisional schemas, `notes/coding-decisions.md` for the decision log, and `notes/open-questions.md` for unresolved choices. Rating source, file naming, Season 4 treatment, and embeddings are intentionally undecided.

The two files under `tests/testthat/` contain skipped future checks. Once implemented, run them from the project root with `testthat::test_dir("tests/testthat")` using synthetic fixtures.

The pre-existing `twilight-zone-ratings.qmd`, project notes in `docs/`, and `renv` files are preserved.
