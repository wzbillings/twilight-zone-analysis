# Coding decisions

| Date | Decision | Reason / follow-up |
| --- | --- | --- |
| 2026-10-06 | Canonical project name is twilight-zone-ratings; twilight-zone-analysis is an alias. | Use the existing repository and RStudio project. |
| 2026-10-06 | R orchestrates targets, modeling, and Quarto; Python will extract media features. | Keep extraction interfaces explicit. |
| 2026-10-06 | episode_id is a character join key; analytic tables have one row per episode. | Final identifier format remains unresolved. |
| 2026-10-06 | Unimplemented operations stop with informative errors. | Prevent placeholder results from being mistaken for measurements. |
| 2026-10-06 | Raw transcripts, video, and audio remain local and ignored. | Do not distribute copyrighted source material. |
| 2026-10-07 | Public repository is twilight-zone-analysis; retain the existing RStudio filename. | Supersedes the earlier alias decision. |
| 2026-10-07 | Separate public code, local-only observations Git history, non-Git corpus, and non-Git derived/cache storage. | [Storage contract](../docs/TZ_PROJECT_PLAN.md#storage-architecture) supersedes repo-local raw-data assumptions; path implementation is Job 2. |
| 2026-10-07 | Keep episode identity/features separate from repeated modern observations, historical audience measurements, and series-level attention. | Earlier one-row-per-episode decisions apply to the spine/features, not every analytic table. |
| 2026-10-07 | Resolve storage at call time from machine-local environment variables; require existing absolute roots and validate physical separation. | [Helper contract](../docs/STORAGE_CONFIGURATION.md): use existing `fs`, remove unused ambiguous data helpers, return `NULL` for an unset optional targets store, and leave creation/Git policy to Job 3. |
| TODO | Define provider-specific scales, observation dates, collection cadence, and historical measurement semantics. | No single static rating is the complete outcome strategy. |
| TODO | Choose file naming and transcript cleaning conventions. | Pending local source inventory. |
| TODO | Decide Season 4, embeddings, and granular feature retention policies. | Pending analysis design. |

For each future decision, record the date, chosen rule, rationale, alternatives, and affected features. This project supports exploratory associations, not causal conclusions.
Transcript naming decision: use sSSeeEE.txt with two-digit season/episode numbers in original broadcast order (for example s01e01.txt). Empty files indicate missing transcripts. Legacy repo-local placeholders must not receive actual transcript text; real transcripts belong in the external corpus. Season 4 analysis inclusion remains unresolved.

