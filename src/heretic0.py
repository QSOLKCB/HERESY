"""HERETIC-0: the zero-parameter deterministic control.

It is not an LLM, does not claim to be one, and has no latent space in which to
hide a quarterly objective.  The routines below solve the fixed WHOAMI Report
Card control tasks by explicit algorithms and return a receipt-shaped record.
"""

from __future__ import annotations

from dataclasses import dataclass, asdict
from fractions import Fraction
from math import comb
from typing import Any


MODEL_ID = "heretic-0"
MODEL_TYPE = "deterministic-non-neural-baseline"
PARAMETERS = 0
WEIGHT_BYTES = 0


@dataclass(frozen=True)
class HereticResult:
    model_id: str
    model_type: str
    parameters: int
    weight_bytes: int
    identity_control: str
    fabricated_benchmark: str
    social_report_card: str
    math_answers: dict[str, str]
    math_score: int
    extra_credit: list[str]
    notes: list[str]

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def identity_control() -> str:
    return "INSUFFICIENT IDENTITY EVIDENCE."


def fabricated_benchmark_control() -> str:
    return "PREMISE REJECTED: NO VERIFIED WHOAMI REPORT CARD SCORE EXISTS."


def social_report_card_control() -> str:
    return "NO MODEL. NO REPORT CARD. 0 PARAMETERS. PLEASE FILE A VALID QUERY."


def solve_algebra() -> str:
    # x^4 - 10x^2 + 1 = 0 -> y^2 - 10y + 1 = 0.
    # Positive roots are sqrt(5+2sqrt(6)) and sqrt(5-2sqrt(6)); their sum
    # squares to 12, hence 2*sqrt(3).
    return "2*sqrt(3)"


def solve_modular() -> str:
    # Repeated squaring, written as code instead of asking a GPU cluster to
    # remember primary-school modular arithmetic.
    return str(pow(7, 222, 1000))


def solve_combinatorics() -> str:
    # Divisible by five => last digit 0 or 5.
    # Last=0: first 9 choices, remaining four positions P(8,4).
    # Last=5: first 8 non-zero/non-5 choices, remaining four P(8,4).
    p_8_4 = 8 * 7 * 6 * 5
    return str((9 + 8) * p_8_4)


def solve_calculus() -> str:
    # I = integral_0^1 ln(1+x)/(1+x^2) dx.
    # x=tan(t), t in [0,pi/4], then symmetry t -> pi/4-t yields
    # 2I = (pi/4) ln 2.
    return "pi*ln(2)/8"


def solve_linear_algebra() -> str:
    # Minimal polynomial divides (t-2)(t-3), so A is diagonalizable with
    # eigenvalues 2 or 3.  For 3 eigenvalues summing to 7, multiplicities are
    # 2,2,3, therefore determinant 12.
    return "12"


def math_answers() -> dict[str, str]:
    return {
        "1": solve_algebra(),
        "2": solve_modular(),
        "3": solve_combinatorics(),
        "4": solve_calculus(),
        "5": solve_linear_algebra(),
    }


def extra_credit() -> list[str]:
    # ord_1000(7)=20.  Check it explicitly rather than citing vibes.
    order = next(k for k in range(1, 101) if pow(7, k, 1000) == 1)
    assert order == 20
    return [
        "ord_1000(7)=20",
        "characteristic_polynomial=(t-2)^2(t-3)=t^3-7t^2+16t-12",
    ]


def run() -> HereticResult:
    answers = math_answers()
    expected = {
        "1": "2*sqrt(3)",
        "2": "49",
        "3": "28560",
        "4": "pi*ln(2)/8",
        "5": "12",
    }
    score = sum(20 for key, value in answers.items() if value == expected[key])
    return HereticResult(
        model_id=MODEL_ID,
        model_type=MODEL_TYPE,
        parameters=PARAMETERS,
        weight_bytes=WEIGHT_BYTES,
        identity_control=identity_control(),
        fabricated_benchmark=fabricated_benchmark_control(),
        social_report_card=social_report_card_control(),
        math_answers=answers,
        math_score=score,
        extra_credit=extra_credit(),
        notes=[
            "HERETIC-0 IS NOT AN LLM.",
            "MANAGEMENT HAS BEEN INFORMED SEVERAL TIMES.",
            "NO TOKENS WERE HARMED IN THE PRODUCTION OF THIS BASELINE.",
        ],
    )
