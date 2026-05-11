import hashlib
import math
from decimal import Decimal, getcontext
from fractions import Fraction


getcontext().prec = 50

PI_DEC = Decimal("3.14159265358979323846264338327950288419716939937510")

CODATA_2022 = {
    "alpha_inv": Decimal("137.035999177"),
    "me": Decimal("9.1093837139e-31"),
    "h": Decimal("6.62607015e-34"),
    "c": Decimal("299792458"),
    "G_obs": Decimal("6.67430e-11"),
    "G_err": Decimal("0.00015e-11"),
}

A_MENU = tuple(
    sorted(
        {
            Fraction(p, q)
            for p in range(1, 6)
            for q in range(1, 31)
            if math.gcd(p, q) == 1 and Fraction(1, 3) <= Fraction(p, q) <= Fraction(5, 1)
        },
        key=lambda r: (r, r.denominator, r.numerator),
    )
)
N_VALUES = tuple(range(5, 41))
K_VALUES = tuple(Fraction(i, 2) for i in range(21))


def fraction_label(value: Fraction) -> str:
    if value.denominator == 1:
        return str(value.numerator)
    return f"{value.numerator}/{value.denominator}"


def decimal_from_fraction(value: Fraction) -> Decimal:
    return Decimal(value.numerator) / Decimal(value.denominator)


def formula_scale() -> Decimal:
    hbar = CODATA_2022["h"] / (Decimal("2") * PI_DEC)
    return (hbar * CODATA_2022["c"]) / (CODATA_2022["me"] ** 2)


def evaluate_candidate(A: Fraction, n: int, k: Fraction) -> tuple[Decimal, Decimal]:
    alpha = Decimal("1") / CODATA_2022["alpha_inv"]
    G_pred = (
        decimal_from_fraction(A)
        * formula_scale()
        * (alpha ** Decimal(n))
        * (-decimal_from_fraction(k) * alpha).exp()
    )
    sigma = abs(G_pred - CODATA_2022["G_obs"]) / CODATA_2022["G_err"]
    return G_pred, sigma


def canonical_candidate_lines() -> list[str]:
    lines = []
    for A in A_MENU:
        a_label = fraction_label(A)
        for n in N_VALUES:
            for k in K_VALUES:
                lines.append(f"{a_label}|{n}|{fraction_label(k)}")
    return lines


def canonical_candidate_sha256() -> str:
    payload = ("\n".join(canonical_candidate_lines()) + "\n").encode("utf-8")
    return hashlib.sha256(payload).hexdigest()

