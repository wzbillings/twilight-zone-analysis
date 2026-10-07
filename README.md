# twilight-zone-analysis

The public repository is `twilight-zone-analysis`. The existing RStudio project file remains `twilight-zone-ratings.Rproj`.

## Goal and current status

Investigate how episode-level time/order, production metadata, text, visual, and sound features relate to reception of the original 1959–1964 *The Twilight Zone*. Reception includes historical broadcast audiences, repeated modern ratings and vote counts, changing attention/popularity, and eventual historical-to-modern reputation comparisons. Historical Nielsen/ARB measurements and modern crowd ratings remain distinct measurement domains.

**Scaffold only:** no data are included, no extraction or models are implemented, and the targets pipeline is intentionally not runnable yet. This is an observational, exploratory project; associations will not establish causal effects.

## Storage boundaries

The [project plan](docs/TZ_PROJECT_PLAN.md#storage-architecture) defines four storage domains:

| Domain | Contents and Git policy |
| --- | --- |
| Public analysis repository | Reproducible code, `_targets.R`, Quarto reports, tests/synthetic fixtures, schemas, configuration templates, documentation, and small explicitly publishable metadata or numerical results. |
| Separate local observations repository | Small structured dated snapshots, historical audience observations, crosswalks, manifests, and provenance; suitable for local Git history, with no GitHub remote. |
| External corpus store | Video, disc images, audio, transcripts, captions, frames, archival PDFs/scans, and other large or potentially copyrighted sources; outside Git entirely. |
| External derived/cache area | Reproducible feature intermediates, embeddings, temporary artifacts, logs, and caches; no Git history required. |

Physical separation protects source material and preserves hard-to-reconstruct observations without versioning large regenerable artifacts. Never put raw copyrighted media or transcripts in this public working tree, commit them, or push them. Derived text/media can still reproduce copyrighted content. `.gitignore` remains defense-in-depth, not the primary boundary or permission to redistribute.

The intended machine-local configuration contract is `TZ_OBSERVATIONS_ROOT`, `TZ_CORPUS_ROOT`, `TZ_DERIVED_ROOT`, `TZ_LOGS_ROOT`, and optional `TZ_TARGETS_STORE`. These variables are **not implemented yet**. Moving from the current data SSD to a future dedicated drive should eventually require changing local configuration only, without editing committed code. No actual paths are selected; targets-cache placement remains open. Backups are important but outside the current architecture scope.

Existing `data/raw`, `data/interim`, `data/features`, and `data/analytic` path assumptions are superseded. Retained repo-local `data/` directories are for synthetic fixtures, tiny explicitly publishable examples, or safe derived results only. Job 2 will refactor the path helpers; do not supply real inputs to legacy paths. Existing output ignore rules remain in place.

## Planned pipeline

`_targets.R` sources the numbered `R/` modules and still describes the original single-snapshot scaffold below. Its ratings-in-spine assumption is provisional; future reception tables must retain repeated dates and provider/entity distinctions separately from the episode spine. No DAG change is made in this documentation update.

1. Read local metadata and ratings; construct and validate the canonical episode spine.
2. Clean local transcripts and summarize text features; derive production metadata features.
3. Detect scenes and sample video frames through Python placeholders.
4. Extract audio locally in a future FFmpeg integration, then compute and summarize audio windows through Python.
5. Aggregate every feature family to one row per `episode_id`, join to the spine, and validate the analytic table.
6. Explore baseline, metadata, text, video, audio, and combined associations after human selection of outcomes, models, and evaluation design.
7. Compare models and render the main Quarto report.

Validation targets gate downstream assembly and modeling. Granular scene/frame/window data must be summarized before analytic joins. Missing feature measurements must remain distinguishable from zero.

## Future setup and execution

Open `twilight-zone-ratings.Rproj` with the project root as the working directory. `.Rprofile` activates `renv` only if its activation script exists. The existing `renv` setup and lockfile are preserved; this scaffold does not initialize, install, or restore anything. The current lockfile may need updating when future dependencies are chosen.

Planned R dependencies are `targets`, `tarchetypes`, `tidyverse`, `lubridate`, `janitor`, `arrow`, `qs`, `tidymodels`, `glmnet`, `broom`, `tidytext`, `textrecipes`, and `testthat` for tests. Quarto is the reporting CLI. Likely Python dependencies are listed in `python/requirements.txt`; FFmpeg will be a separate system dependency. Python help uses only the standard library.

After Job 2 configures external storage, subsequent jobs implement the functions, and dependencies and inputs are deliberately configured, the intended command is:

```r
targets::tar_make()
```

Until then, extraction and R analysis functions fail with informative unimplemented messages. Python script interfaces use `--episode-id`, `--input`, and `--output`; `python python/detect_scenes.py --help` documents one interface without requiring media packages.

Future report chunks can use `targets::tar_read()` for pipeline outputs. The current reports contain prose placeholders only; `_quarto.yml` limits website rendering to the three files in `reports/` and writes to `_site/`.

## Extending the scaffold

Use snake_case and explicit tibble columns. See `notes/data-dictionary.md` for provisional schemas, `notes/coding-decisions.md` for the decision log, and `notes/open-questions.md` for unresolved choices. Provider-specific measurement definitions, collection cadence, video file naming, Season 4 treatment, and embeddings remain undecided.

The two files under `tests/testthat/` contain skipped future checks. Once implemented, run them from the project root with `testthat::test_dir("tests/testthat")` using synthetic fixtures.

The pre-existing `twilight-zone-ratings.qmd` is an earlier single-rating exploration, not the complete reception strategy or the future acquisition workflow. It and the `renv` files remain unchanged; do not run the old report to populate the new storage domains.
