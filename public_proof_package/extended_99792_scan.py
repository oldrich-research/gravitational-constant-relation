import csv
import fractions
import json
from decimal import Decimal, getcontext


getcontext().prec = 50


def run_scan():
    print("WARNING: extended_99792_scan.py is a legacy extended scan and NOT the canonical 22,680-candidate publication prior.")

    with open("constants.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    consts = data["constants"]
    alpha_inv = Decimal(consts["alpha_inv"]["value"])
    alpha = Decimal("1") / alpha_inv
    h = Decimal(consts["h"]["value"])
    c = Decimal(consts["c"]["value"])
    pi_dec = Decimal("3.14159265358979323846264338327950288419716939937510")
    hbar = h / (Decimal("2") * pi_dec)
    me = Decimal(consts["me"]["value"])
    G_obs = Decimal(consts["G_obs"]["value"])
    G_err = Decimal(consts["G_obs"]["uncertainty"])

    rats = set()
    for d in range(1, 10):
        for n in range(1, 50):
            r = fractions.Fraction(n, d)
            if fractions.Fraction(1, 3) <= r <= fractions.Fraction(5, 1):
                rats.add(r)

    A_list = sorted(list(rats), key=lambda x: (x.denominator, x.numerator))
    n_list = list(range(5, 41))
    k_list = [fractions.Fraction(i, 2) for i in range(21)]

    scale = (hbar * c) / (me ** 2)
    results = []

    for A in A_list:
        A_dec = Decimal(A.numerator) / Decimal(A.denominator)
        for n in n_list:
            for k in k_list:
                k_dec = Decimal(k.numerator) / Decimal(k.denominator)
                G_pred = A_dec * scale * (alpha ** Decimal(n)) * (-k_dec * alpha).exp()
                sigma = abs(G_pred - G_obs) / G_err
                if sigma <= Decimal("1.0"):
                    results.append(
                        {
                            "A": f"{A.numerator}/{A.denominator}",
                            "n": n,
                            "k": f"{k.numerator}/{k.denominator}" if k.denominator != 1 else str(k.numerator),
                            "G_pred": float(G_pred),
                            "sigma": float(sigma),
                        }
                    )

    results.sort(key=lambda row: row["sigma"])

    with open("extended_top_candidates.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["A", "n", "k", "G_pred", "sigma"])
        writer.writeheader()
        writer.writerows(results)

    print(f"Legacy extended scan complete. Candidate count={len(A_list) * len(n_list) * len(k_list)}")


if __name__ == "__main__":
    run_scan()
