# AGENTS.md

## Purpose

This repository is a reproducible research project for multimodal analysis of episodic television, beginning with *The Twilight Zone*. The immediate scientific goal is series-specific analysis, but ingestion and feature extraction should be designed so they can be reused for other series later.

Treat this file as the repo-wide default instruction set. A more deeply nested `AGENTS.md` may add or refine rules for its subtree, but should not silently weaken the copyright, reproducibility, or Git requirements below.

## Core design principles

1. **Separate reusable computation from research orchestration.**
   - `targets`/`tarchetypes` orchestrate dependencies, caching, branching, and report generation.
   - Ordinary R functions perform the actual computation and should be callable/testable without a `targets` pipeline.
   - Keep `_targets.R` declarative and relatively small. Put substantive logic in functions under `R/` (or, later, in a reusable package).

2. **Keep generic infrastructure series-agnostic.**
   - Generic code should operate on concepts such as series, episodes, media streams, captions, audio, video, shots, timestamps, and feature tables.
   - Do not hard-code *The Twilight Zone*, season counts, episode counts, file names, codecs, subtitle formats, or other source-specific assumptions into reusable functions.
   - Put series-specific values in manifests, configuration files, metadata, or series-specific analysis code.

3. **Do not prematurely package unstable abstractions.**
   - During the first case study, reusable functions may live in the project `R/` directory.
   - Once interfaces and schemas are stable across real media, extract reusable functionality into a conventional R package (working name such as `tvfeatures` is acceptable, but no package name is assumed by this file).
   - The future package's core API should remain usable independently of `targets`.
   - Reusable `targets` factories may be added later if multiple projects repeat the same DAG structure; do not make the computational core depend on a pipeline merely for convenience.

4. **Keep scientific decisions human-in-the-loop.**
   - Automate ingestion, validation, feature extraction, reproducible transformations, and descriptive reporting where appropriate.
   - Do not automatically select final inferential models, causal interpretations, variable-selection strategies, or substantive conclusions.
   - Keep series-specific modeling and interpretation separate from generic feature extraction unless a cross-series analysis is explicitly requested.
   - Never describe an observational association as causal without a defensible identification strategy.

## Copyright, media, and repository safety

**Never commit, push, publish, or otherwise place potentially copyrighted source material in the Git repository.** This rule applies even when the user's local possession or research use of the material may be lawful.

Do **not** add any of the following to Git:

- ripped or remuxed video files;
- DVD/Blu-ray images, title streams, or media backups;
- extracted audio;
- subtitles, closed captions, or full/partial episode transcripts copied from a copyrighted source;
- extracted video frames, stills, thumbnails, or contact sheets from episodes;
- scripts or screenplay text from copyrighted sources;
- commentary tracks, isolated scores, bonus-feature media, or similar source material;
- any other artifact that could redistribute or substantially reconstruct copyrighted audiovisual or textual content.

Use **synthetic fixtures** for tests. Do not solve testing convenience by committing short copyrighted clips, frames, subtitle excerpts, or transcript snippets.

Permitted repository content may include code, configuration, documentation, bibliographic/source references, human-authored metadata, episode identifiers/titles where appropriate, and derived numerical/statistical features that do not reproduce the underlying work. When uncertain whether an artifact is safe to publish, keep it out of Git and ask before adding it.

The pipeline boundary begins with canonical local media files already available to the user. Do not add DRM/copy-protection circumvention or disc-ripping automation unless the user explicitly changes the project scope and requests it.

Maintain `.gitignore` rules that default to excluding local source and derived media directories. Before every commit, inspect `git status` and the staged diff specifically for accidental media, transcripts, credentials, personal paths, large binaries, or generated artifacts.

## Repository and data layout

Prefer a clear separation between immutable inputs, reproducible derived artifacts, and analysis outputs. A typical layout may evolve toward:

```text
R/                  # reusable R functions used by the project
python/             # Python only where it provides a material capability advantage
config/             # series-specific configuration
metadata/           # small publishable manifests / metadata
analysis/           # series-specific analyses and Quarto documents
tests/               # automated tests using synthetic fixtures
data/
  raw/              # local-only inputs; never publish copyrighted media
  derived/          # reproducible local-only media/text derivatives unless explicitly safe
_targets.R
renv.lock
```

Do not assume this exact structure exists until the repository is scaffolded. Follow the established repository structure when one exists, and change it deliberately rather than opportunistically.

Human-edited manifests should use simple, reviewable formats such as CSV/YAML where practical. Large machine-generated tabular intermediates should prefer efficient typed formats such as Parquet when justified.

## Canonical data model

Design interfaces around stable identifiers and standardized schemas. Prefer at least:

- `series_id`: stable machine-readable series identifier;
- `episode_id`: stable identifier unique within the project;
- season/episode numbers where applicable, but do not assume every series uses the same numbering scheme;
- time positions represented consistently, preferably numeric seconds from episode start for analysis tables;
- explicit start/end intervals for time-windowed features.

Reusable outputs should converge on well-defined tables such as:

- `episode_metadata`;
- `transcript_segments`;
- `audio_windows`;
- `video_windows`;
- `shots`;
- `episode_features`.

Validate required columns, types, uniqueness constraints, interval ordering, and key relationships at boundaries between pipeline stages. Do not allow silent schema drift.

## `targets` / `tarchetypes` standards

Use `targets` as orchestration infrastructure, not as a substitute for ordinary software design.

- Keep target commands thin; call named functions for substantive work.
- Keep reusable functions pure where practical: explicit inputs, explicit return values, minimal hidden global state.
- Declare file dependencies and outputs so `targets` can track them correctly.
- Use dynamic branching for repeated work across series/episodes/windows instead of hand-written repeated targets.
- Avoid reading objects that exist only in an interactive global environment.
- Do not hide important side effects inside helper functions without representing their files or state in the pipeline.
- Make expensive media-processing steps cacheable and independently invalidatable.
- Prefer deterministic transformations. Where stochastic computation is required, use explicit, reproducible seeds and document the randomization strategy.
- Use `tarchetypes` when it materially simplifies a standard pattern (for example, report rendering or a well-supported branching pattern); do not introduce abstractions solely to shorten `_targets.R`.
- Do not run the entire expensive media pipeline merely to validate a small unrelated change. Run the narrowest meaningful targets/checks unless the change affects global orchestration.

If target factories are introduced later, they should compose ordinary tested functions rather than contain otherwise inaccessible computational logic.

## R coding standards

Use modern, readable R.

- **Prefer the base R pipe `|>` over `%>%`. Do not introduce `%>%` in new or modified code.** When touching a small nearby block that uses `%>%`, convert it to `|>` when doing so is safe and does not create noisy unrelated diffs.
- Use `<-` for assignment in R code.
- Use `snake_case` for objects and functions unless an external API dictates otherwise.
- Give functions narrow responsibilities and explicit arguments; avoid dependence on mutable global options/state.
- Prefer vectorized, clear code over clever metaprogramming.
- Use tidyverse packages when they improve clarity, but do not require tidyverse idioms where base R is simpler.
- In package code, manage imports explicitly and avoid relying on packages being attached in the caller's session.
- Do not use `setwd()`. Use project-relative paths/configuration and path helpers.
- Do not encode machine-specific absolute paths in committed files.
- Handle expected errors deliberately and emit informative messages that identify the episode/file/tool involved.
- Preserve source precision and provenance; do not silently round or coerce important timestamps, ratings, counts, or IDs.
- Comments should explain *why* a non-obvious decision exists, not narrate obvious syntax.

When a reusable R package is created:

- follow conventional R package structure;
- use `testthat` for tests;
- use roxygen2-style documentation for exported functions;
- keep the public API intentionally small;
- distinguish exported user-facing functions from internal helpers;
- treat schema or API changes as deliberate compatibility decisions.

## Python and external tools

R is the primary project language. Python or command-line tools are appropriate when they provide a clear capability or ecosystem advantage (for example, computer vision, model inference, FFmpeg/ffprobe, or caption extraction).

- Do not reimplement mature media tooling in R merely to avoid an external dependency.
- Wrap external commands behind small, testable interfaces.
- Prefer robust process execution with captured exit status/stdout/stderr rather than brittle shell-string construction.
- Check tool availability and fail with actionable errors.
- Record/document material external-tool and model versions needed for reproducibility.
- Keep Python code in a defined location and environment; do not scatter ad hoc Python snippets through R scripts.
- Normalize external outputs into the project's canonical R/tabular schemas as soon as practical.

## Dependency and environment management

- Use `renv` for the R project environment once initialized; keep `renv.lock` current when dependencies intentionally change.
- Do not update unrelated packages or rewrite the lockfile as collateral damage.
- Add a dependency only when it earns its maintenance cost.
- Prefer stable, maintained packages with clear licenses and APIs.
- Document non-R system dependencies required for reproducibility.
- Never commit secrets, tokens, license keys, personal credentials, or machine-specific configuration.

## Testing and validation

Tests should emphasize deterministic units, schemas, and boundary conditions rather than expensive end-to-end processing of copyrighted episodes.

- Use synthetic media/text fixtures or freely licensed/generated fixtures only.
- Add regression tests for bugs when practical.
- Test parsing, validation, timestamp alignment, schema invariants, identifier handling, and external-tool failure modes.
- Keep slow/integration tests separable from fast unit tests.
- Tests that require optional external tools should detect missing dependencies and skip or fail with a clear reason, according to the intended test tier.

Validation is change-dependent. Before committing:

- for documentation/config-only changes, inspect rendered/parsed output as relevant; do not run expensive unrelated analyses;
- for R logic changes, run the relevant `testthat` tests if a test suite exists;
- for package changes, run package checks appropriate to the scope (and full `R CMD check`/`rcmdcheck` before release-quality changes when the package exists);
- for `targets` graph changes, at minimum verify the manifest/graph can be constructed, then run the smallest affected branch or target set practical;
- for formatting/lint configuration changes, run the configured formatter/linter on the affected scope.

Never claim a check passed unless it was actually run. Report skipped checks and the reason.

## Reproducible analysis standards

- Preserve raw inputs as immutable local source data; create derived artifacts rather than modifying source files in place.
- Record provenance linking derived features to series, episode, source file, extraction method, and relevant tool/model version where feasible.
- Make cleaning/exclusion rules explicit and reproducible.
- Keep exploratory work clearly distinguishable from production pipeline logic.
- Prefer Quarto for durable analytical reports when reports are needed.
- Set and document random seeds for simulations, resampling, stochastic models, or randomized algorithms.
- Avoid manual spreadsheet edits to machine-generated analysis data; encode transformations in code.
- Do not overwrite intermediate artifacts merely to save space unless regeneration is reliable and the choice is documented.

## Cross-series design

Do not pool series by default. The reusable infrastructure should make comparable features available across series, while each series may retain its own statistical model, covariates, rating scale behavior, historical context, and interpretation.

If cross-series comparisons are added later:

- define harmonized feature semantics explicitly;
- document comparability limitations;
- prefer within-series standardization or hierarchical modeling where scientifically appropriate rather than naive pooling;
- distinguish exploratory comparison from confirmatory inference.

## Git workflow

All repository work must be organized into **logical, reviewable Git commits**. Avoid one giant commit containing unrelated changes, and avoid fragmenting a single coherent change into meaningless micro-commits.

Use **Conventional Commits 1.0.0** for every commit message:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Use `feat` for new features and `fix` for bug fixes. Other useful types include `docs`, `test`, `refactor`, `perf`, `build`, `ci`, `chore`, and `revert`. Scopes should be short nouns such as `media`, `captions`, `audio`, `video`, `targets`, `metadata`, `analysis`, or a package name.

Examples:

```text
feat(captions): add CEA-608 extraction interface
fix(targets): track subtitle files as file targets
test(audio): add synthetic fixture for window alignment
docs: add repository agent instructions
refactor(video): separate shot detection from feature summarization
```

Mark breaking changes with `!` and/or a `BREAKING CHANGE:` footer as required by Conventional Commits 1.0.0.

Commit rules:

- one commit should represent one coherent intent;
- do not mix refactors with unrelated behavior changes when they can be separated cleanly;
- do not commit generated caches, local media, temporary outputs, editor state, or environment secrets;
- inspect the staged diff before committing;
- do not amend, squash, rebase, force-push, or rewrite existing history unless explicitly instructed;
- do not discard unrelated user changes;
- after committing, verify `git status` and leave the worktree clean unless the user has intentionally left unrelated uncommitted work.

Conventional Commits specification: <https://www.conventionalcommits.org/en/v1.0.0/>

## Documentation and decision records

Keep documentation close to the code it governs.

- README content is for human project orientation; use `AGENTS.md` for coding-agent operating rules.
- Document non-obvious architectural decisions and important schema contracts.
- For substantial or cross-cutting work, prefer a short written plan/design note before implementation rather than making architecture implicitly through code edits.
- If a future nested component needs materially different instructions, add a scoped `AGENTS.md` in that subtree rather than bloating the root file with local exceptions.

## Agent behavior in this repository

Before making changes:

1. Read this file and any more specific nested `AGENTS.md` files that apply.
2. Inspect the existing repository structure and conventions before inventing new ones.
3. Check the working tree so unrelated user changes are preserved.
4. Identify whether the task touches local copyrighted data and keep all such material outside Git.

While working:

1. Prefer the smallest change that cleanly solves the requested problem.
2. Keep generic infrastructure generic and series-specific science explicit.
3. Add or update tests/documentation when behavior or interfaces change.
4. Do not perform opportunistic broad refactors without a clear benefit to the requested task.

Before finishing:

1. Run the relevant change-dependent validation.
2. Review `git diff`/staged diff for correctness and accidental copyrighted or sensitive files.
3. Commit in logical Conventional Commit(s) when the task includes repository modifications.
4. Report what changed, what was tested, and any limitations or follow-up work.
