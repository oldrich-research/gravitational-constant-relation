import argparse
import csv
import json
from decimal import Decimal
from pathlib import Path

from canonical_bounded_prior import (
    A_MENU,
    K_VALUES,
    N_VALUES,
    canonical_candidate_sha256,
    evaluate_candidate,
    fraction_label,
)


HERE = Path(__file__).resolve().parent
BENCHMARKS = json.loads((HERE / "benchmarks.json").read_text(encoding="utf-8"))


def parse_args():
    parser = argparse.ArgumentParser(description="Run the canonical 22,680-candidate bounded prior scan.")
    parser.add_argument(
        "--benchmark",
        choices=sorted(BENCHMARKS),
        default="codata2022",
        help="Observed G benchmark used for sigma ranking.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=5,
        help="How many nearest-neighbor rows to write to the output table. Default matches the bundled proof-package CSV hashes.",
    )
    parser.add_argument(
        "--output",
        default="",
        help="Optional output CSV path. Defaults to top_candidates.csv or nist_top_candidates.csv.",
    )
    return parser.parse_args()


def benchmark_values(name):
    meta = BENCHMARKS[name]
    return meta, Decimal(meta["G_obs"]), Decimal(meta["G_err"])


def default_output_name(name):
    if name == "codata2022":
        return "top_candidates.csv"
    return f"{name}_top_candidates.csv"


def ranked_rows(benchmark_name):
    meta, g_obs, g_err = benchmark_values(benchmark_name)
    rows = []

    for A in A_MENU:
        for n in N_VALUES:
            for k in K_VALUES:
                G_pred, _ = evaluate_candidate(A, n, k)
                sigma = abs(G_pred - g_obs) / g_err
                residual_ppm = ((G_pred / g_obs) - Decimal("1")) * Decimal("1e6")
                rows.append(
                    {
                        "A": fraction_label(A),
                        "n": n,
                        "k": fraction_label(k),
                        "G_pred": f"{G_pred:.18E}",
                        "residual_ppm": f"{residual_ppm:.12f}",
                        "sigma": f"{sigma:.12f}",
                    }
                )

    rows.sort(key=lambda row: (Decimal(row["sigma"]), abs(Decimal(row["residual_ppm"]))))
    for idx, row in enumerate(rows, start=1):
        row["rank"] = idx
        row["benchmark"] = benchmark_name
        row["benchmark_label"] = meta["label"]
    return rows


def write_rows(path, rows):
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["rank", "benchmark", "benchmark_label", "A", "n", "k", "G_pred", "residual_ppm", "sigma"],
        )
        writer.writeheader()
        writer.writerows(rows)


def main():
    args = parse_args()
    rows = ranked_rows(args.benchmark)
    out_name = args.output or default_output_name(args.benchmark)
    out_path = Path(out_name)
    if not out_path.is_absolute():
        out_path = HERE / out_path

    write_rows(out_path, rows[: args.limit])

    meta, _, _ = benchmark_values(args.benchmark)
    total = len(A_MENU) * len(N_VALUES) * len(K_VALUES)
    print("Canonical bounded prior scan complete.")
    print(f"Benchmark: {meta['label']}")
    print(f"Candidate-list sha256: {canonical_candidate_sha256()}")
    print(f"Total combinations: {total}")
    print(f"Output table: {out_path.name}")
    print(
        "Top candidate: "
        f"A={rows[0]['A']}, n={rows[0]['n']}, k={rows[0]['k']}, "
        f"residual_ppm={rows[0]['residual_ppm']}, sigma={rows[0]['sigma']}"
    )
    if args.benchmark == "codata2022":
        codata_sigma = rows[0]["sigma"]
        _, nist_obs, nist_err = benchmark_values("nist2026")
        g_pred = Decimal(rows[0]["G_pred"])
        nist_sigma = abs(g_pred - nist_obs) / nist_err
        print(f"Cross-check: canonical sigma vs CODATA 2022 = {codata_sigma}")
        print(f"Cross-check: canonical sigma vs NIST 2026 = {nist_sigma:.12f}")


if __name__ == "__main__":
    main()
