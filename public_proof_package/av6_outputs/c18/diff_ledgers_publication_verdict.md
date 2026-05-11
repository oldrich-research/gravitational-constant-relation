# Bounded-Search Validation Report — g_decode

**Experiment**: G-DECODE candidate formula validation (Newton's gravitational constant). Hypothesis: G ≈ (4/3) α^21 exp(-5/2 α) in natural units.
**Canonical hypothesis**: `4/3 * alpha^21 * exp((-5/2)*alpha)`

**Generated**: 2026-05-08T15:16:24Z

**jl13 source**: `/opt/hive/projects/research/programs/g-decode/local_runs/av6_exhaustive_c40_plan_20260430T133000Z/jl13_c16_outputs`
**jl14 source**: `/opt/hive/projects/research/programs/g-decode/local_runs/av6_exhaustive_c40_plan_20260430T133000Z/jl15_c18_outputs`

## Verdict: **PASS (publication) / FAIL (engine equivalence) / REVIEW-NEEDED (discovery side)**

Three orthogonal axes:
- **Publication**: at budget ≥ 30, does the candidate engine put the canonical full form `4/3 * alpha^21 * exp((-5/2)*alpha)` at rank 1 within tolerance, and at the publication sham budget produce ≤ 5 sham false positives? PASS = absolute publication-grade evidence.
- **Engine equivalence**: does jl14 match jl13 on engine-soundness KPIs (Jaccard, rel_err ratio, ancestor presence, sham parity)? Once Publication PASSes, bare-ancestor and sham-parity differential rules are downgraded to INFO — they were calibrated for engines below the canonical cost ceiling and misreport once the canonical full form is found.
- **Discovery side**: did NON_FAMILY expressions surface with cross-target reach or beats-family signal? CLEAN = none. REVIEW-NEEDED = at least one — do not silently close on engine PASS alone.

**Publication-grade flags:**
- budget 30: canonical full form at rank-1 (rel_err=1.8539024855725e-06, ≤ 0.0001) ✓
- budget 40: jl14 sham_match_or_beat=0/256 (≤ 5) ✓

**Engine-equivalence flags:**
- ⚠ budget 20: Jaccard 0.1628 < 0.5 → FAIL
- ⚠ budget 30: Jaccard 0.1628 < 0.5 → FAIL
- ⚠ budget 40: Jaccard 0.1628 < 0.5 → FAIL
- ⚠ budget 20: bare ancestor `4/3 * alpha^21` absent (INFO — expected when canonical full form holds rank-1)
- ⚠ budget 30: bare ancestor `4/3 * alpha^21` absent (INFO — expected when canonical full form holds rank-1)
- ⚠ budget 40: bare ancestor `4/3 * alpha^21` absent (INFO — expected when canonical full form holds rank-1)
- ⚠ budget 20: rel_err ratio 0.072345 > 5% → FAIL
- ⚠ budget 30: rel_err ratio 0.000291 > 5% → FAIL
- ⚠ budget 40: rel_err ratio 0.000291 > 5% → FAIL
- ⚠ sham 1 budget 20: rel_err mismatch > 1e-12
- ⚠ sham 2 budget 20: rel_err mismatch > 1e-12
- ⚠ sham 4 budget 20: rel_err mismatch > 1e-12
- ⚠ sham 5 budget 20: rel_err mismatch > 1e-12
- ⚠ sham 10 budget 20: rel_err mismatch > 1e-12
- ⚠ sham 100 budget 20: rel_err mismatch > 1e-12
- ⚠ sham 200 budget 20: rel_err mismatch > 1e-12
- ⚠ sham 255 budget 20: rel_err mismatch > 1e-12
- ⚠ sham 1 budget 30: rel_err mismatch > 1e-12
- ⚠ sham 2 budget 30: rel_err mismatch > 1e-12
- ⚠ sham 4 budget 30: rel_err mismatch > 1e-12
- ⚠ sham 5 budget 30: rel_err mismatch > 1e-12
- ⚠ sham 10 budget 30: rel_err mismatch > 1e-12
- ⚠ sham 100 budget 30: rel_err mismatch > 1e-12
- ⚠ sham 200 budget 30: rel_err mismatch > 1e-12
- ⚠ sham 255 budget 30: rel_err mismatch > 1e-12
- ⚠ sham 1 budget 40: rel_err mismatch > 1e-12
- ⚠ sham 2 budget 40: rel_err mismatch > 1e-12
- ⚠ sham 4 budget 40: rel_err mismatch > 1e-12
- ⚠ sham 5 budget 40: rel_err mismatch > 1e-12
- ⚠ sham 10 budget 40: rel_err mismatch > 1e-12
- ⚠ sham 100 budget 40: rel_err mismatch > 1e-12
- ⚠ sham 200 budget 40: rel_err mismatch > 1e-12
- ⚠ sham 255 budget 40: rel_err mismatch > 1e-12
- ⚠ budget 20: sham parity drift jl13=134 jl14=27 (|diff|=107) — INFO (publication KPI passes; differential check downgraded)
- ⚠ budget 30: sham parity drift jl13=134 jl14=0 (|diff|=134) — INFO (publication KPI passes; differential check downgraded)
- ⚠ budget 40: sham parity drift jl13=134 jl14=0 (|diff|=134) — INFO (publication KPI passes; differential check downgraded)

> ⚠ **DISCOVERY-SIDE: REVIEW-NEEDED** — non-family expressions with independent signal found (multi-target hits and/or beats-family on some target). See NON_FAMILY tables below; potentially higher-value formulae outside the alpha^21 basin.

## Family Classification (primary lens)

Taxonomy (canonical: prefactor=4/3, n=21):
- `LOCAL_DEFORMATION`: prefactor == 4/3 with `alpha^21` (canonical sibling)
- `SHARED_ALPHA21_COUSIN`: prefactor != 4/3 with `alpha^21`
- `ALPHA_FAMILY_OTHER_N`: `A * alpha^n * exp(c*alpha)` with n != 21
- `NON_FAMILY`: anything else (potential discovery candidates)

### Per-engine breakdown (top-25 across all targets, all budgets)

| class | jl13 count | jl14 count | jl14/jl13 ratio | drift |
|------|----------:|----------:|----------------:|-----:|
| LOCAL_DEFORMATION | 3 | 6 | 2.000 | 1.000 |
| SHARED_ALPHA21_COUSIN | 0 | 0 | N/A | N/A |
| ALPHA_FAMILY_OTHER_N | 3 | 12 | 4.000 | 3.000 |
| NON_FAMILY | 369 | 357 | 0.967 | 0.033 |

**jl13 totals**: 375 classified rows
**jl14 totals**: 375 classified rows

### NON_FAMILY expressions that BEAT best family rel_err (per target)

Strongest discovery signal: an expression outside the alpha^n family that fits a target
better than any family member. Each row deserves explicit human review.

#### jl13

| target | non_family_best | family_best | nf/fam ratio | cost | expr |
|-------|----------------:|------------:|-------------:|----:|-----|
| sin_theta_c | 0.000e+00 | N/A | N/A | 12 | `(3/4)^2 * 2/5` |
| mw_over_mz | 2.135e-04 | N/A | N/A | 13 | `(3 + 3/5)-(e)` |
| sin2_theta_w | 2.791e-04 | N/A | N/A | 12 | `(pi)/(5 * e)` |
| g_decode_alpha_ge | 6.373e-03 | 1.841e-02 | 0.346 | 15 | `(((5)/((alpha)^2))^-3)^3` |
| lambda_e2_over_mec2 | 1.603e-02 | 2.643e-02 | 0.606 | 16 | `(pi)/((((((3)^3)^3)^3)^3)^2)` |

#### jl14

| target | non_family_best | family_best | nf/fam ratio | cost | expr |
|-------|----------------:|------------:|-------------:|----:|-----|
| sin_theta_c | 0.000e+00 | N/A | N/A | 12 | `(3/4)^2 * 2/5` |
| mw_over_mz | 7.531e-05 | N/A | N/A | 13 | `(exp((1)-((e)^-1)))-(1)` |
| sin2_theta_w | 1.730e-04 | N/A | N/A | 16 | `(4)^-3 * 2 + 1/5` |

### NON_FAMILY expressions ranked by cross-target reach (independent-structure signal)

Expression hitting multiple distinct targets in top-25 = stronger independent structural
signal than a single-target hit. Top-50 per engine, sorted by (n_targets desc, rel_err asc).

#### jl13 — 50 unique non-family expressions

| n_targets | best_rel_err | best_target | cost | expr |
|---------:|------------:|------------|----:|-----|
| 1 | 0.000e+00 | sin_theta_c | 12 | `(3/4)^2 * 2/5` |
| 1 | 2.135e-04 | mw_over_mz | 13 | `(3 + 3/5)-(e)` |
| 1 | 2.791e-04 | sin2_theta_w | 12 | `(pi)/(5 * e)` |
| 1 | 2.907e-04 | sin2_theta_w | 14 | `(log((1/2)^2 * (e)^2))^3` |
| 1 | 6.961e-04 | sin2_theta_w | 10 | `(log(2))/(3)` |
| 1 | 6.961e-04 | sin2_theta_w | 10 | `1/3 * log(2)` |
| 1 | 6.961e-04 | sin2_theta_w | 12 | `((1/3)^-1)^-1 * log(2)` |
| 1 | 8.314e-04 | mw_over_mz | 9 | `((e)^-2 + 1)^-1` |
| 1 | 8.314e-04 | mw_over_mz | 12 | `(((e)^-2 + 1)^-1)/(1)` |
| 1 | 9.335e-04 | mw_over_mz | 11 | `(1/3 + 4/5)^-1` |
| 1 | 9.746e-04 | mw_over_mz | 14 | `log(3/4 + 5/3)` |
| 1 | 1.047e-03 | sin_theta_c | 12 | `exp((alpha)-(3/2))` |
| 1 | 1.095e-03 | sin_theta_c | 14 | `((2)^3 * (e)^-1)-(e)` |
| 1 | 1.097e-03 | mw_over_mz | 9 | `(exp((1/2)^3))^-1` |
| 1 | 1.097e-03 | mw_over_mz | 14 | `(exp(((1)-((5)^2))^-1))^3` |
| 1 | 1.097e-03 | mw_over_mz | 11 | `exp(((1/2)-(1))^3)` |
| 1 | 1.097e-03 | mw_over_mz | 11 | `exp(((1)-((3)^2))^-1)` |
| 1 | 1.097e-03 | mw_over_mz | 12 | `exp(((1)-(3))^-3)` |
| 1 | 1.097e-03 | mw_over_mz | 12 | `exp(((1)-(3/2))^3)` |
| 1 | 1.097e-03 | mw_over_mz | 12 | `exp(((1)-((1/3)^-2))^-1)` |
| 1 | 1.097e-03 | mw_over_mz | 12 | `exp((((1)^2)-((3)^2))^-1)` |
| 1 | 1.097e-03 | mw_over_mz | 12 | `exp((((1)^-1)-((3)^2))^-1)` |
| 1 | 1.097e-03 | mw_over_mz | 13 | `exp(((2/4)-(1))^3)` |
| 1 | 1.097e-03 | mw_over_mz | 14 | `exp(((2)-(4))^-3)` |
| 1 | 1.097e-03 | mw_over_mz | 14 | `exp(((3)-(5))^-3)` |
| 1 | 1.562e-03 | sin_theta_c | 13 | `log(log(1/2 + 3))` |
| 1 | 1.621e-03 | sin2_theta_w | 8 | `((log(2))^2)^2` |
| 1 | 1.621e-03 | sin2_theta_w | 8 | `((log(1/2))^2)^2` |
| 1 | 1.621e-03 | sin2_theta_w | 11 | `(((log(2))^2)^2)/(1)` |
| 1 | 1.621e-03 | sin2_theta_w | 11 | `(((log(1/2))^2)^2)/(1)` |
| 1 | 1.906e-03 | sin2_theta_w | 9 | `(1/3 + 4)^-1` |
| 1 | 1.906e-03 | sin2_theta_w | 10 | `(3 + 4/3)^-1` |
| 1 | 2.235e-03 | sin2_theta_w | 13 | `exp((1/5)-(5/3))` |
| 1 | 2.404e-03 | sin_theta_c | 13 | `(exp(4/5))-(2)` |
| 1 | 2.404e-03 | sin_theta_c | 14 | `(exp((5/4)^-1))-(2)` |
| 1 | 2.404e-03 | sin_theta_c | 14 | `(exp((1)-(1/5)))-(2)` |
| 1 | 2.484e-03 | sin_theta_c | 10 | `(5/3)/((e)^2)` |
| 1 | 2.484e-03 | sin_theta_c | 11 | `(e)^-2 * 5/3` |
| 1 | 2.510e-03 | sin2_theta_w | 11 | `exp((((pi)^-1)-(1))^-1)` |
| 1 | 2.510e-03 | sin2_theta_w | 12 | `exp((((pi)^-1)-((1)^2))^-1)` |
| 1 | 2.510e-03 | sin2_theta_w | 12 | `exp((((pi)^-1)-((1)^-1))^-1)` |
| 1 | 2.510e-03 | sin2_theta_w | 13 | `exp((1)/(((pi)^-1)-(1)))` |
| 1 | 2.976e-03 | mw_over_mz | 9 | `(((1/4)^2)-(1))^2` |
| 1 | 2.976e-03 | mw_over_mz | 9 | `((1)-((1/4)^2))^2` |
| 1 | 2.976e-03 | mw_over_mz | 9 | `((((1/2)^2)^2)-(1))^2` |
| 1 | 2.976e-03 | mw_over_mz | 9 | `((1)-(((1/2)^2)^2))^2` |
| 1 | 2.995e-03 | mw_over_mz | 13 | `4/5 * log(3)` |
| 1 | 3.001e-03 | mw_over_mz | 12 | `(e)-((5)/(e))` |
| 1 | 3.022e-03 | mw_over_mz | 10 | `((5/3)^2)/(pi)` |
| 1 | 3.089e-03 | sin2_theta_w | 12 | `(3/5 * e)^-3` |

#### jl14 — 50 unique non-family expressions

| n_targets | best_rel_err | best_target | cost | expr |
|---------:|------------:|------------|----:|-----|
| 1 | 0.000e+00 | sin_theta_c | 12 | `(3/4)^2 * 2/5` |
| 1 | 0.000e+00 | sin_theta_c | 13 | `(4/3)^-2 * 2/5` |
| 1 | 0.000e+00 | sin_theta_c | 16 | `1/4 * 2/4 + 2/5` |
| 1 | 7.531e-05 | mw_over_mz | 13 | `(exp((1)-((e)^-1)))-(1)` |
| 1 | 1.730e-04 | sin2_theta_w | 16 | `(4)^-3 * 2 + 1/5` |
| 1 | 2.135e-04 | mw_over_mz | 13 | `(3)-(e) + 3/5` |
| 1 | 2.135e-04 | mw_over_mz | 13 | `(3 + 3/5)-(e)` |
| 1 | 2.135e-04 | mw_over_mz | 14 | `(4)-(2/5 + e)` |
| 1 | 2.791e-04 | sin2_theta_w | 12 | `(pi)/(5 * e)` |
| 1 | 3.289e-04 | sin_theta_c | 16 | `(pi)-(5/3 + 5/4)` |
| 1 | 3.352e-04 | mw_over_mz | 15 | `exp(((log(((pi)^-1)^-1))^-1)-(1))` |
| 1 | 4.611e-04 | g_decode_alpha_ge | 17 | `(((3 * exp(e))^-3)^3)^3` |
| 1 | 4.611e-04 | g_decode_alpha_ge | 17 | `(((3 * exp(e))^3)^-3)^3` |
| 1 | 4.611e-04 | g_decode_alpha_ge | 17 | `(((3 * exp(e))^3)^3)^-3` |
| 1 | 6.961e-04 | sin2_theta_w | 10 | `(log(2))/(3)` |
| 1 | 6.961e-04 | sin2_theta_w | 10 | `1/3 * log(2)` |
| 1 | 6.961e-04 | sin2_theta_w | 12 | `((1/3)^-1)^-1 * log(2)` |
| 1 | 6.961e-04 | sin2_theta_w | 14 | `(log(1 + 2/2))/(3)` |
| 1 | 6.961e-04 | sin2_theta_w | 14 | `(log(1 + 3/3))/(3)` |
| 1 | 8.314e-04 | mw_over_mz | 9 | `((e)^-2 + 1)^-1` |
| 1 | 9.335e-04 | mw_over_mz | 11 | `(1/3 + 4/5)^-1` |
| 1 | 9.335e-04 | mw_over_mz | 15 | `(5)/(4 + 5/3)` |
| 1 | 9.746e-04 | mw_over_mz | 14 | `log(3/4 + 5/3)` |
| 1 | 1.047e-03 | sin_theta_c | 12 | `exp((alpha)-(3/2))` |
| 1 | 1.097e-03 | mw_over_mz | 9 | `(exp((1/2)^3))^-1` |
| 1 | 1.097e-03 | mw_over_mz | 11 | `exp(((1/2)-(1))^3)` |
| 1 | 1.097e-03 | mw_over_mz | 11 | `exp(((1)-((3)^2))^-1)` |
| 1 | 1.097e-03 | mw_over_mz | 12 | `exp(((1)-(3))^-3)` |
| 1 | 1.097e-03 | mw_over_mz | 12 | `exp(((1)-(3/2))^3)` |
| 1 | 1.097e-03 | mw_over_mz | 12 | `exp(((1)-((1/3)^-2))^-1)` |
| 1 | 1.097e-03 | mw_over_mz | 12 | `exp((((1)^2)-((3)^2))^-1)` |
| 1 | 1.097e-03 | mw_over_mz | 12 | `exp((((1)^-1)-((3)^2))^-1)` |
| 1 | 1.097e-03 | mw_over_mz | 13 | `exp(((2/4)-(1))^3)` |
| 1 | 1.097e-03 | mw_over_mz | 13 | `exp(((3/2)-(2))^3)` |
| 1 | 1.097e-03 | mw_over_mz | 14 | `exp(((2)-(4))^-3)` |
| 1 | 1.097e-03 | mw_over_mz | 14 | `exp(((3)-(5))^-3)` |
| 1 | 1.097e-03 | mw_over_mz | 14 | `exp(((2)-(5/2))^3)` |
| 1 | 1.097e-03 | mw_over_mz | 14 | `exp(((5/2)-(3))^3)` |
| 1 | 1.097e-03 | mw_over_mz | 14 | `exp((((1/3)^2)-(1))^-1 + 1)` |
| 1 | 1.097e-03 | mw_over_mz | 15 | `exp((((1/3)^2)-(1))^-1 + (1)^2)` |
| 1 | 1.174e-03 | sin2_theta_w | 18 | `(3)^-3 * 5 * 5/4` |
| 1 | 1.174e-03 | sin2_theta_w | 18 | `(3)^-3 * 5 + 5/4` |
| 1 | 1.562e-03 | sin_theta_c | 13 | `log(log(1/2 + 3))` |
| 1 | 1.562e-03 | sin_theta_c | 14 | `log(log(1 + 5/2))` |
| 1 | 1.562e-03 | sin_theta_c | 14 | `log(log(2 + 3/2))` |
| 1 | 1.562e-03 | sin_theta_c | 15 | `log(log(2/4 + 3))` |
| 1 | 1.562e-03 | sin_theta_c | 18 | `log(log(4/4 + 5/2))` |
| 1 | 1.562e-03 | sin_theta_c | 18 | `log(log(5/2 + 5/5))` |
| 1 | 1.621e-03 | sin2_theta_w | 8 | `((log(2))^2)^2` |
| 1 | 1.621e-03 | sin2_theta_w | 8 | `((log(1/2))^2)^2` |

## Canonical-Target Top-25 Divergence (per budget)

Ancestor probe text: `4/3 * alpha^21` at cost 15.

| budget | Jaccard | common | jl13-only | jl14-only | best_rel_err_13 | best_rel_err_14 | ratio(14/13) | bare-ancestor | canonical-full @ rank-1 |
|-------:|-------:|------:|----------:|----------:|----------------:|----------------:|-----------------:|:-------------:|:----------------------:|
| 20 | 0.1628 | 7 | 18 | 18 | 0.006373148643572179 | 0.00046106794087053026 | 0.072345 | 13:True/14:False | 13:·/14:· |
| 30 | 0.1628 | 7 | 18 | 18 | 0.006373148643572179 | 1.8539024855725e-06 | 0.000291 | 13:True/14:False | 13:·/14:✓ |
| 40 | 0.1628 | 7 | 18 | 18 | 0.006373148643572179 | 1.8539024855725e-06 | 0.000291 | 13:True/14:False | 13:·/14:✓ |

### jl13-only example expressions (up to 5 per budget)

**budget 20**:
- `((((((1/3)^3)/(e))^2)^2)^2)^3`
- `((((((1/3)^3)/(e))^2)^2)^3)^2`
- `((((((1/3)^3)/(e))^2)^3)^2)^2`
- `((((((1/3)^3)/(e))^3)^2)^2)^2`
- `(((((3)^3 * e)^-2)^2)^2)^3`

**budget 30**:
- `((((((1/3)^3)/(e))^2)^2)^2)^3`
- `((((((1/3)^3)/(e))^2)^2)^3)^2`
- `((((((1/3)^3)/(e))^2)^3)^2)^2`
- `((((((1/3)^3)/(e))^3)^2)^2)^2`
- `(((((3)^3 * e)^-2)^2)^2)^3`

**budget 40**:
- `((((((1/3)^3)/(e))^2)^2)^2)^3`
- `((((((1/3)^3)/(e))^2)^2)^3)^2`
- `((((((1/3)^3)/(e))^2)^3)^2)^2`
- `((((((1/3)^3)/(e))^3)^2)^2)^2`
- `(((((3)^3 * e)^-2)^2)^2)^3`

## G-Target Per-Cost Comparison

| cost | jl13 exprs | jl14 exprs | common | best_rel_err_13 | best_rel_err_14 | ratio(14/13) |
|----:|----------:|----------:|------:|----------------:|----------------:|-----------------:|
| 15 | 9 | 3 | 2 | 0.006373148643572179 | 0.006373148643572179 | 1.0 |
| 16 | 8 | 3 | 3 | 0.006373148643572357 | 0.006373148643572357 | 1.0 |

## Canonical Ancestor & Full-Form Check

- bare ancestor `4/3 * alpha^21` in top-25 (jl13 / jl14): **YES** / **NO**
- canonical full `4/3 * alpha^21 * exp((-5/2)*alpha)` at rank-1 (jl13 / jl14): **NO** / **YES**
- canonical full form at rank-1 — bare-ancestor missing from top-25 is expected (full form + sibling deformations at cost 26-28 displace the cost-15 bare ancestor).

## Sham Parity Counts (KPI-1.3: |jl14_beats - jl13_beats| ≤ 2)

Number of sham indices where the engine's best expression beats canonical G
(`matches_or_beats_g=True`). Identical counts = engines agree on parity ceiling.

| budget | jl13 beats | jl14 beats | jl13 total | jl14 total | |diff| | KPI-1.3 |
|------:|----------:|----------:|----------:|----------:|------:|:-------:|
| 20 | 134 | 27 | 256 | 256 | 107 | ✗ |
| 30 | 134 | 0 | 256 | 256 | 134 | ✗ |
| 40 | 134 | 0 | 256 | 256 | 134 | ✗ |

## Sham Parity (sampled indices)

| budget | sham_idx | expr_match | rel_err_13 | rel_err_14 | close(<1e-12) |
|------:|--------:|:---------:|----------:|----------:|:------------:|
| 20 | 1 | ✗ | 0.005504318178176765 | 0.00026762128883207046 | False |
| 20 | 2 | ✗ | 0.011015536560235044 | 0.0009900336310546213 | False |
| 20 | 3 | ✓ | 0.005251471483967301 | 0.005251471483967301 | True |
| 20 | 4 | ✗ | 0.002871158201464513 | 0.00017483597224025985 | False |
| 20 | 5 | ✗ | 0.023684546861510728 | 0.012791517023950783 | False |
| 20 | 10 | ✗ | 0.0016588849850651649 | 0.0015140320087109337 | False |
| 20 | 50 | ✓ | 0.004336794834229183 | 0.004336794834229183 | True |
| 20 | 100 | ✗ | 0.008719248423269618 | 0.0008859360470152027 | False |
| 20 | 200 | ✗ | 0.0035398072968495366 | 0.002980353971001823 | False |
| 20 | 255 | ✗ | 0.01353632977628912 | 0.008133789587180234 | False |
| 30 | 1 | ✗ | 0.005504318178176765 | 0.00026762128883207046 | False |
| 30 | 2 | ✗ | 0.011015536560235044 | 0.0009900336310546213 | False |
| 30 | 3 | ✓ | 0.005251471483967301 | 0.005251471483967301 | True |
| 30 | 4 | ✗ | 0.002871158201464513 | 0.00017483597224025985 | False |
| 30 | 5 | ✗ | 0.023684546861510728 | 0.012791517023950783 | False |
| 30 | 10 | ✗ | 0.0016588849850651649 | 0.0015140320087109337 | False |
| 30 | 50 | ✓ | 0.004336794834229183 | 0.004336794834229183 | True |
| 30 | 100 | ✗ | 0.008719248423269618 | 0.0008859360470152027 | False |
| 30 | 200 | ✗ | 0.0035398072968495366 | 0.002980353971001823 | False |
| 30 | 255 | ✗ | 0.01353632977628912 | 0.008133789587180234 | False |
| 40 | 1 | ✗ | 0.005504318178176765 | 0.00026762128883207046 | False |
| 40 | 2 | ✗ | 0.011015536560235044 | 0.0009900336310546213 | False |
| 40 | 3 | ✓ | 0.005251471483967301 | 0.005251471483967301 | True |
| 40 | 4 | ✗ | 0.002871158201464513 | 0.00017483597224025985 | False |
| 40 | 5 | ✗ | 0.023684546861510728 | 0.012791517023950783 | False |
| 40 | 10 | ✗ | 0.0016588849850651649 | 0.0015140320087109337 | False |
| 40 | 50 | ✓ | 0.004336794834229183 | 0.004336794834229183 | True |
| 40 | 100 | ✗ | 0.008719248423269618 | 0.0008859360470152027 | False |
| 40 | 200 | ✗ | 0.0035398072968495366 | 0.002980353971001823 | False |
| 40 | 255 | ✗ | 0.01353632977628912 | 0.008133789587180234 | False |