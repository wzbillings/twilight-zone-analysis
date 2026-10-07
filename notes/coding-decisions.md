# Coding decisions

| Date | Decision | Reason / follow-up |
| --- | --- | --- |
| 2026-10-06 | Canonical project name is twilight-zone-ratings; twilight-zone-analysis is an alias. | Use the existing repository and RStudio project. |
| 2026-10-06 | R orchestrates targets, modeling, and Quarto; Python will extract media features. | Keep extraction interfaces explicit. |
| 2026-10-06 | episode_id is a character join key; analytic tables have one row per episode. | Final identifier format remains unresolved. |
| 2026-10-06 | Unimplemented operations stop with informative errors. | Prevent placeholder results from being mistaken for measurements. |
| 2026-10-06 | Raw transcripts, video, and audio remain local and ignored. | Do not distribute copyrighted source material. |
| TODO | Choose rating source and record rating scale and observation date. | Pending source review. |
| TODO | Choose file naming and transcript cleaning conventions. | Pending local source inventory. |
| TODO | Decide Season 4, embeddings, and granular feature retention policies. | Pending analysis design. |

For each future decision, record the date, chosen rule, rationale, alternatives, and affected features. This project supports exploratory associations, not causal conclusions.
Transcript naming decision: use sSSeeEE.txt with two-digit season/episode numbers in original broadcast order (for example s01e01.txt). Empty files indicate missing transcripts. All five seasons have local placeholders; Season 4 analysis inclusion remains unresolved.

