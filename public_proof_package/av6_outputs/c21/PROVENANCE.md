# Provenance — `av6_outputs/c21/`

Added 2026-09-05 to close a gap identified by verification: the root `README.md` has carried
concrete `C=21` headline numbers since commit `f14af7f998ffaa03430f6aa9d369fb8d0c73ff09`
("README: update bounded enumeration to C21", 2026-05-20), but `manifest.json` and
`av6_outputs/` were last touched by the `2026-05-11` initial-publication commit, which only
covers `C=18/19/20`. The `C=21` claim was true but had no hashed artifact backing it in this
package. This directory and the corresponding `manifest.json` update close that gap.

## Source

- Machine/run root: `av6_exhaustive_c40_plan_20260430T133000Z` (Hive research host,
  `/data/research/programs/g-decode/local_runs/av6_exhaustive_c40_plan_20260430T133000Z/`).
- Engine: `jl15` (`run_av6_exhaustive_c40_jl15.jl`, byte-identical to
  `av6_engine/run_av6_exhaustive_c40_jl15.jl` in this package).
- Output subdirectory at the source: `jl15_c21_outputs/`, files renamed here to drop the
  `c14_c25_` run-family prefix, matching the `c18/`, `c19/`, `c20/` naming convention already
  in this package:
  - `c14_c25_bounded_shell_stats.csv` → `bounded_shell_stats.csv`
  - `c14_c25_same_target_rank_tables.csv` → `same_target_rank_tables.csv`
  - `c14_c25_sham_best_ledger.csv` → `sham_best_ledger.csv`
  - Byte content is unmodified (verified with `diff` against the source files).

## Run timeline (from `logs/run_julia_jl15_c21_auto.log`, `run_julia_jl15_c21_restart_20260515.log`)

The `cost=21` shell was computed across checkpointed restarts (normal for a multi-day run on
this engine, which checkpoints per completed cost and resumes on relaunch):
- Restart attempt starting `2026-05-15T21:49:00Z`, completed `2026-05-19T12:42:12Z`.
- Final restart starting `2026-05-20T14:14:03Z`, completed `2026-05-20T18:16:36Z`
  (`Highest cost completed: 21`, matches root README's "completed 2026-05-20").
- The `elapsed_sec` column in `bounded_shell_stats.csv` is the engine's own internal timer for
  the `cost=21` enumeration+dedup step specifically (`307404.3s` = 85h 23m 24s), not the
  wall-clock span across restarts above. This is the same convention already used for the
  `C=19` and `C=20` rows bundled in this package (their last-row `elapsed_sec` reproduces the
  root README's "8 h 54 m" and "28 h 12 m" cells almost exactly).

## Verification performed 2026-09-05 (all reproduce from the bundled files)

| Root README C21 claim | Bundled artifact | Value found |
|---|---|---|
| "2.67 billion raw expressions" | `bounded_shell_stats.csv`, `cost=21` row | `raw_generated=2672779634` |
| "777,191 canonical-unique survivors" | `bounded_shell_stats.csv`, `cost=21` row | `canonical_unique=kept=777191` |
| "growth factor 1.19" | `bounded_shell_stats.csv`, `cost=21` row | `growth_factor=1.1866` |
| "wall time 85 h 24 m" | `bounded_shell_stats.csv`, `cost=21` row, `elapsed_sec` | `307404.3s = 85h 23m 24s` (rounds to the README's 85h24m within ~1 minute) |
| "sham₄₀ = 1/256" | `sham_best_ledger.csv`, `budget=40` rows | exactly 1 of 256 rows has `matches_or_beats_g=true`: `sham_index=28`, `best_expr=(exp((1)-(3 * 4) * pi))^3`, classified `TRASH_BROAD_GRAMMAR` — same `sham_index=28` drift already disclosed for `C19`/`C20` in `manifest.json` |
| "rel_err = 1.85e-6 stable, rank-1 at budget=40 (and 30)" | `same_target_rank_tables.csv`, `target=g_decode_alpha_ge` | `rank=1` at both `budget=30` and `budget=40`, `expr=4/3 * alpha^21 * exp((-5/2)*alpha)`, `rel_err=1.8539024855725e-6` |

No claim in the root README's `C21` table row, or in the sentence introducing it, required
adjustment. All of it reproduces from these three files.

## What this does not change

- `candidate_list_sha256` (bounded-prior Python scan) is untouched — it is a separate evidence
  layer (Section 3), unaffected by the AV6 Julia engine's `C=21` extension.
- `av6_engine/spec.json` is untouched. See the note added to `public_proof_package/README.md`
  about its `mode: "pilot_beam_pruned_not_exhaustive"` field, which is not read by the engine
  at runtime and predates the jl15 group-gate design; changing the file would break the
  `EXPECTED_SPEC_FILE_SHA256` pin hard-coded in `av6_engine/run_av6_exhaustive_c40_jl15.jl`.
- No `diff_ledgers_publication_verdict.md`-style KPI verdict file exists for `C21` because that
  verdict file is specific to the `C18` publication baseline (comparison against the `jl13c16`
  comparator engine); `C19`/`C20` do not have one either, for the same reason.
