# Public Proof Package Scope

This addendum fixes the ambiguity that caused the earlier bounded-prior freeze failure on 2026-04-29.

## Current Scope

The executable publication baseline in this directory is now:

- `scan.py`
- `canonical_bounded_prior.py`

That script implements the canonical manuscript-declared bounded prior:

- `A = {p/q : 1 <= p <= 5, 1 <= q <= 30, gcd(p,q)=1, 1/3 <= p/q <= 5}`
- `n in {5, ..., 40}`
- `k in {0, 1/2, ..., 10}`
- total candidates `30 * 36 * 21 = 22,680`
- constants: CODATA 2022
- benchmark modes: `benchmarks.json` (`codata2022`, `nist2026`)

## Historical Lineage

The broader denominator-`<=9` public scan that previously created the prior split is preserved separately as:

- `extended_99792_scan.py`

That legacy surface enumerates all reduced fractions `n/d` with `d <= 9`, `n <= 49`, and `1/3 <= n/d <= 5`, giving `132` prefactors and `99,792` total candidates. It is retained for lineage and comparison only. It is not the bounded publication baseline and should not be cited as evidence for the `22,680` count.

## Citation Rule

Use:

- `scan.py --benchmark codata2022` for the canonical bounded reproduction set
- `scan.py --benchmark nist2026` for the single-experiment comparison mode
- `extended_99792_scan.py` only when explicitly discussing the broader legacy denominator-`<=9` sweep

This split is intentional and preserves alignment across the archived bounded-prior rerun materials.
