# Storage configuration

The path layer reads machine-local environment variables at call time. Copy
`.Renviron.example` to the ignored project-local `.Renviron`, fill in absolute
directory paths, and restart R (or set variables in the process environment).
Use forward slashes, including on Windows, and quote paths with spaces. Never
commit actual paths or secrets. Relocation requires changing only these values.

| Variable | Helper | Meaning |
| --- | --- | --- |
| `TZ_OBSERVATIONS_ROOT` | `observations_path(...)` | Separate local-only observations Git repository. |
| `TZ_CORPUS_ROOT` | `corpus_path(...)` | Non-Git source corpus. |
| `TZ_DERIVED_ROOT` | `derived_path(...)` | Non-Git reproducible intermediates and caches. |
| `TZ_LOGS_ROOT` | `logs_path(...)` | Non-Git runtime logs; durable provenance belongs in observations. |
| `TZ_TARGETS_STORE` | `targets_store_path(...)` | Optional cache directory; not wired into targets. |

The first four variables are required only when their domain is requested.
Sourcing helpers or `targets::tar_source("R")` needs no configuration and has no
filesystem side effects. Requested roots must be existing absolute directories
on the current operating system. Missing, blank, relative, malformed, and
nonexistent required roots produce errors naming the variable and `.Renviron`.
Physical paths are resolved, including symlinks/junctions. Windows containment
comparisons ignore case.

External roots must neither be inside nor contain the public project. Call
`validate_storage_config()` to require all four and reject equal or nested
external domains; siblings are valid. It returns a named list of normalized
roots, including `targets = NULL` when unset. Individual helpers validate their
own root; validate the whole configuration before work spanning domains.
`storage_root(domain)` accepts `observations`, `corpus`, `derived`, `logs`, or
`targets` for callers needing just the root.

An unset or blank `TZ_TARGETS_STORE` returns `NULL`, even with child components.
A configured value must be an existing absolute directory but can be inside the
project or another domain: its placement remains undecided. No cache location
is inferred and targets configuration is unchanged.

Helpers accept scalar character components, including nested relative paths and
spaces. They reject absolute children, parent traversal (`..`), malformed names,
and existing links escaping the root. Future children need not exist. Helpers
never create directories or files. These checks guard accidental placement;
they cannot prevent another process changing links after validation.

`project_path(...)` walks upward from the current working directory using
`_targets.R` and `R/00_paths.R` as markers. Run from the project or a subdirectory.
`output_path(...)` remains shorthand for public `output/`. The unused
`data_raw_path()`, `data_interim_path()`, `data_features_path()`, and
`data_analytic_path()` were removed; choose an explicit domain instead.

## Job 3 handoff

Job 3 must explicitly create the user-selected directories before calling these
helpers, initialize observations as local-only Git, and verify that corpus,
derived, and logs are not governed by any Git working tree. This layer checks
path separation, not Git policy. Run `validate_storage_config()` after bootstrap.
No real storage has been created by Job 2. See the
[architecture](TZ_PROJECT_PLAN.md#storage-architecture) for content boundaries.

## Verification

Run `testthat::test_dir("tests/testthat")` from the project root with `fs`,
`testthat`, and `withr` available. Storage tests use temporary synthetic fixtures
and restore environment overrides. Existing analysis tests remain scaffold skips.
