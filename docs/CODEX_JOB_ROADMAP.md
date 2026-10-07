# Codex Implementation Roadmap

## Purpose

This document defines the planned implementation jobs for building the metadata, reception, storage, and automated acquisition infrastructure for the *Twilight Zone* analysis project.

It is a roadmap, not an implementation specification. Each job should receive its own detailed Codex prompt when work begins.

The jobs are intentionally scoped so that each produces a coherent, reviewable change and does not prematurely implement later work.

## Current status

| Job | Status | Summary |
| --- | --- | --- |
| 1 | Complete | Document external local data architecture |
| 2 | Next | Implement external storage configuration and path helpers |
| 3 | Planned | Bootstrap local observations repository and storage contract |
| 4 | Planned | Define canonical identifiers, schemas, and provenance |
| 5 | Planned | Implement IMDb official-dataset adapter |
| 6 | Planned | Implement TMDB adapter |
| 7 | Planned | Implement TVmaze and OMDb adapters |
| 8 | Planned | Build provider crosswalk and canonical metadata layer |
| 9 | Planned | Implement append-only longitudinal snapshot storage |
| 10 | Planned | Refactor the `targets` graph around acquisition and analysis |
| 11 | Planned | Build metadata/reception QA report and test suite |
| 12 | Planned | Implement unattended local automation and baseline capture |
| 13 | Later research phase | Reconstruct historical audience measurements |

---

## Job 1 — Document external local data architecture

**Status:** Complete.

### Goal

Replace the original assumption that real raw data live inside the public analysis repository with a four-domain storage architecture:

1. public analysis repository;
2. local-only Git-tracked observations repository;
3. local non-Git corpus;
4. local non-Git derived/cache/log storage.

### Main responsibilities

- Update architecture and project documentation.
- Make `.gitignore` defense-in-depth rather than the primary copyright/data boundary.
- Establish that raw/copyright-sensitive material must physically live outside the public Git working tree.
- Establish that repeated modern reception measurements and historical audience measurements are distinct data domains.
- Document machine-local storage variables that later jobs will implement.
- Explicitly leave implementation for later jobs.

### Completion criteria

A contributor or coding agent can determine what belongs in each storage domain and what may be committed or pushed publicly.

### Completed implementation

Commit:

`857fa5d` — `docs(architecture): separate local research data storage`

---

## Job 2 — Implement external storage configuration and path infrastructure

### Goal

Implement the machine-independent configuration layer that allows analysis code to locate external observations, corpus, derived, log, and optional `targets` storage.

### Planned configuration

The path layer should support:

```text
TZ_OBSERVATIONS_ROOT
TZ_CORPUS_ROOT
TZ_DERIVED_ROOT
TZ_LOGS_ROOT
TZ_TARGETS_STORE
```

The first four represent external storage domains. `TZ_TARGETS_STORE` is optional.

### Main responsibilities

- Refactor `R/00_paths.R`.
- Implement explicit domain-specific path helpers such as:
  - `observations_path()`
  - `corpus_path()`
  - `derived_path()`
  - `logs_path()`
  - optional `targets_store_path()`
- Preserve `project_path()` or an equivalent helper for legitimate public-repository paths.
- Validate configured roots only when they are actually required.
- Do not fail merely because the repository is sourced on a machine without private data.
- Reject unsafe configurations such as external roots inside the public repository.
- Reject unintended nesting among observations/corpus/derived/log roots.
- Retire ambiguous legacy helpers such as `data_raw_path()` rather than silently mapping them to a new domain.
- Add focused `testthat` coverage.
- Provide a safe environment-variable template if appropriate.

### Explicitly out of scope

- Creating the actual storage directories.
- Initializing the observations Git repository.
- Selecting the user's current SSD path.
- Data acquisition.
- API clients.
- Schema design.
- `targets` acquisition DAG changes.
- Automation.

### Completion criteria

Relocating the external storage to another drive requires only a change to machine-local configuration and no committed code changes.

---

## Job 3 — Bootstrap the local observations repository and storage contract

### Goal

Create the real local storage structure using the path infrastructure from Job 2.

This is the first job that should use the user's actual current data-storage location.

### Planned local domains

Conceptually:

```text
<storage-parent>/
├── observations/
├── corpus/
├── derived/
└── logs/
```

The exact physical path is machine-local and must not be committed to the public repository.

### Main responsibilities

- Create the external storage roots needed for the project.
- Initialize `observations/` as a separate **local-only Git repository**.
- Do not configure a GitHub or other remote for the observations repository.
- Establish an observations structure such as:

```text
observations/
├── modern/
│   ├── imdb/
│   ├── tmdb/
│   ├── tvmaze/
│   └── omdb/
├── historical/
│   ├── audience/
│   └── archival_extractions/
├── crosswalks/
├── manifests/
├── provenance/
└── README.md
```

- Create the non-Git corpus, derived, and log roots.
- Define storage-format conventions:
  - Parquet for typed machine-generated tables where appropriate;
  - CSV/YAML/Markdown for small human-reviewed data/configuration where appropriate.
- Document the local observations repository's policy: essentially everything placed there should be suitable for local Git tracking.
- Verify that corpus and derived data cannot accidentally fall under the observations Git root.

### Explicitly out of scope

- Backups.
- API acquisition.
- Episode schemas.
- Historical research.
- Media ingestion.

### Completion criteria

The machine has a valid external storage layout, the observations directory is an independent local Git repository with no remote, and the analysis project can resolve all configured roots through Job 2's path layer.

---

## Job 4 — Define canonical identifiers, schemas, and provenance model

### Goal

Define the data contracts before writing source-specific acquisition code.

### Main responsibilities

Formalize schemas for at least:

- series identity;
- canonical episode identity;
- provider identifiers/crosswalks;
- people;
- episode credits;
- provider-specific episode metadata;
- modern longitudinal metric observations;
- acquisition-run provenance;
- historical sources;
- broadcast instances;
- historical audience observations.

### Important design rules

- Maintain a stable internal `episode_id`.
- Keep provider IDs separate from canonical IDs.
- Separate metric **provider** from metric **source** so, for example, an IMDb-derived rating returned through OMDb is not treated as an independent OMDb rating.
- Preserve provider-specific raw/normalized values before canonical reconciliation.
- Define required columns, types, uniqueness constraints, allowable missingness, and key relationships.
- Use synthetic fixtures for schema tests.

### Explicitly out of scope

- Real API acquisition.
- Final conflict-resolution decisions requiring source data.
- Statistical modeling.

### Completion criteria

Schemas and validation tests exist independently of real external data and provide a stable contract for Jobs 5–9.

---

## Job 5 — Implement the IMDb official-dataset adapter

### Goal

Use IMDb's official downloadable noncommercial datasets as the primary IMDb acquisition route, without scraping IMDb webpages.

### Main responsibilities

- Acquire/cache the necessary official IMDb datasets.
- Identify the original 1959 series through its IMDb identifier.
- Construct provider-specific episode mappings.
- Extract the available episode metadata required for the current project.
- Extract IMDb rating and vote-count observations.
- Extract relevant people/credits information supported by the official datasets.
- Preserve retrieval/source provenance.
- Normalize outputs to Job 4 schemas.
- Add validation and tests that do not depend unnecessarily on live downloads.

### Important rule

IMDb source tables remain provider-specific at this stage. Do not silently declare every IMDb field canonical before cross-source reconciliation.

### Completion criteria

The adapter reproducibly identifies the expected 156 original-series episodes across five seasons and produces valid IMDb-specific tables.

---

## Job 6 — Implement the TMDB adapter

### Goal

Add TMDB as an independent metadata/reception source and as the source of a dynamic series-level attention metric.

### Main responsibilities

Acquire and normalize:

- series metadata;
- seasons;
- episodes;
- air dates;
- production metadata;
- relevant credits;
- episode vote averages;
- episode vote counts;
- series-level TMDB popularity.

### Engineering requirements

- Read credentials only from machine-local environment configuration.
- Isolate HTTP/API communication from normalization logic.
- Implement sensible error, retry, and rate-limit behavior.
- Preserve provider IDs and retrieval provenance.
- Normalize outputs to Job 4 schemas.

### Important distinction

TMDB episode vote averages/counts are episode-level reception measures. TMDB popularity is a separate **series-level attention metric**, not an episode rating.

### Completion criteria

TMDB records can be linked to the candidate episode set and emit valid metadata, reception, and series-attention observations.

---

## Job 7 — Implement TVmaze and OMDb adapters

### Goal

Add TVmaze as another independent metadata/reception source and OMDb as a validation/fallback source.

### Main responsibilities

#### TVmaze

- Acquire episode metadata and available ratings/votes.
- Acquire useful cast/crew/guest-credit information where appropriate.
- Preserve source/provenance fields.
- Normalize to Job 4 schemas.

#### OMDb

- Implement title/episode lookup as a secondary validation/fallback source.
- Preserve the distinction between:
  - the API provider (`omdb`);
  - the underlying metric source (`imdb`, etc.) when OMDb republishes another provider's metric.
- Never count republished IMDb values as an independent reception source.

### Completion criteria

Both adapters emit schema-valid provider-specific data, and provenance prevents duplicated external metrics from being mistaken for independent measurements.

---

## Job 8 — Build provider crosswalk and canonical metadata layer

### Goal

Reconcile provider-specific records into stable internal episode, person, and credit identities.

### Main responsibilities

- Build the provider-ID crosswalk.
- Construct the canonical episode table.
- Construct relational people and episode-credit tables.
- Preserve provider disagreements before resolution.
- Produce explicit conflict/reconciliation outputs.
- Establish documented source-precedence rules only where a canonical value is truly needed.
- Validate the expected original-series structure:
  - Season 1: 36 episodes
  - Season 2: 29 episodes
  - Season 3: 37 episodes
  - Season 4: 18 episodes
  - Season 5: 36 episodes
  - Total: 156 episodes

### Important rule

Never fuzzy-join silently. Provider records should either map explicitly to one canonical entity or be surfaced for review.

### Completion criteria

Every relevant provider episode either maps cleanly to one canonical episode or appears in a documented reconciliation/conflict result.

---

## Job 9 — Implement append-only longitudinal snapshot storage

### Goal

Make repeated modern reception/attention collection safe, idempotent, and auditable.

### Main responsibilities

Implement persistence for:

- monthly episode-level rating/vote snapshots;
- weekly series-level attention/popularity snapshots;
- acquisition-run provenance.

### Required properties

- Append-only historical behavior.
- Never overwrite an old observation.
- Preserve actual observation and retrieval timestamps.
- Idempotent reruns of the same acquisition period.
- No duplicate logical observations.
- Explicit handling of revised provider values.
- Acquisition metadata should include the analysis-code Git SHA where practical.
- Partial or invalid acquisitions must not corrupt existing history.

### Completion criteria

Synthetic/test captures demonstrate correct append, rerun, validation-failure, and conflict behavior.

---

## Job 10 — Refactor the `targets` graph around acquisition and analysis

### Goal

Replace the current static single-rating metadata scaffold with a narrow, explicit metadata/reception acquisition subgraph while preserving later transcript/video/audio placeholders.

### Main responsibilities

- Refactor the first portion of `_targets.R`.
- Integrate provider adapters, crosswalks, canonical metadata, snapshot reading/writing, and validation.
- Keep substantive logic in ordinary R functions.
- Ensure external observations are not permanently skipped just because local code inputs are unchanged.
- Represent snapshot period/date explicitly in acquisition invalidation.
- Make it possible to run only the metadata/reception subgraph without invoking media processing.

### Explicitly out of scope

- Final multimodal modeling.
- Full transcript/media implementation.
- Automation scheduling.

### Completion criteria

There is a well-defined, runnable metadata/reception subgraph that respects longitudinal acquisition semantics and does not attempt the unfinished media pipeline.

---

## Job 11 — Build metadata/reception QA report and test suite

### Goal

Provide a reliable answer after each acquisition to:

> Did we acquire sane data, what changed, and what disagrees across sources?

### Main responsibilities

Expand automated tests and create a Quarto QA/reporting surface covering:

- episode coverage;
- provider crosswalk completeness;
- missingness;
- metadata disagreements;
- rating distributions;
- vote counts;
- source comparisons;
- snapshot history;
- acquisition-run status;
- suspicious changes such as large missingness changes or declining vote counts.

### Validation policy

Distinguish:

- structural errors that should abort acquisition;
- unusual but plausible changes that should emit warnings.

### Completion criteria

A standard command can produce a concise QA report for the current metadata/reception state, and tests cover the important schema and acquisition invariants.

---

## Job 12 — Implement unattended local automation and baseline capture

### Goal

Make prospective data collection run locally without manual intervention.

### Planned platform

Windows Task Scheduler plus a thin PowerShell orchestration layer.

### Main responsibilities

- Add separate automation entry points for:
  - monthly episode-level reception capture;
  - weekly attention/popularity capture.
- Keep acquisition logic in R/`targets`; PowerShell should orchestrate only.
- Check required storage availability before running.
- Use a lock to prevent overlapping scheduled/manual runs.
- Produce useful logs and nonzero failure codes.
- Commit successful observation updates to the local observations Git repository only after validation succeeds.
- Do not push the observations repository anywhere.
- Prefer running committed/stable analysis code rather than an arbitrary dirty development checkout.
- Consider a dedicated automation Git worktree if it materially improves reliability.
- Configure Task Scheduler to run missed jobs when the machine becomes available where appropriate.
- Perform and validate the project's first real baseline reception snapshot.

### Completion criteria

Manual invocation of each automation entry point reproduces what Task Scheduler will run, successful captures are stored and locally committed, invalid captures do not modify history, and the first real dated snapshot is preserved.

---

## Job 13 — Historical audience reconstruction

**Status:** Later research phase.

### Goal

Recover contemporary broadcast-audience measurements for original *Twilight Zone* broadcasts and, where useful, repeats.

This work is deliberately separated from the modern API/data-engineering jobs because it is primarily archival research and source harmonization.

### Candidate sources

Potential sources include contemporary:

- Nielsen reports;
- ARB/Arbitron measurements;
- *Broadcasting*;
- *Television Digest*;
- newspapers;
- network research/publicity material;
- books or scholarly sources that reproduce historical ratings.

### Main responsibilities

- Inventory historical sources.
- Record publication/source provenance.
- Identify broadcast instances.
- Preserve the source's original metric names, units, geography, audience population, and measurement context.
- Enter structured historical observations into the schemas created in Job 4.
- Do not force unlike historical metrics onto one common raw scale.
- Record extraction confidence/notes where archival evidence is ambiguous.
- Eventually investigate comparability with modern retrospective reception.

### Completion criteria

A provenance-rich historical audience dataset exists for as many identifiable broadcast instances as can reasonably be recovered, without pretending heterogeneous historical measures are directly interchangeable.

---

## Dependency overview

```text
Job 1: architecture documentation
        ↓
Job 2: storage configuration/path helpers
        ↓
Job 3: local storage + observations repository
        ↓
Job 4: identifiers/schemas/provenance
        ↓
        ├── Job 5: IMDb
        ├── Job 6: TMDB
        └── Job 7: TVmaze + OMDb
                 ↓
Job 8: crosswalk + canonical metadata
                 ↓
Job 9: longitudinal persistence
                 ↓
Job 10: targets integration
                 ↓
Job 11: QA + tests
                 ↓
Job 12: local automation + baseline capture

Job 13: historical audience reconstruction
        uses the schemas/provenance infrastructure from Job 4
        and can proceed once the canonical episode layer is stable
```

## Scope discipline

Each Codex job should:

1. read `AGENTS.md` and this roadmap before making changes;
2. inspect the current implementation rather than assuming earlier jobs behaved exactly as planned;
3. implement only its own scope unless a small prerequisite repair is necessary;
4. preserve unrelated user changes;
5. add or update focused tests/documentation as appropriate;
6. use logical Conventional Commits;
7. report what changed, what was actually tested, and any follow-up decisions needed by the next job.

If the repository state makes a later roadmap assumption obsolete, update this roadmap deliberately rather than silently diverging from it.
