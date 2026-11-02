"""Deterministic empirical search & verification engine for Erdős Problem #282 / JSP-000240.

Stein's Odd Greedy Egyptian Fraction Algorithm:
Given rational x = a / b in (0, 1) with b odd:
At step k:
  d_k = min { d in N : d is odd, d >= min_d, 1/d <= x_k }
  x_{k+1} = x_k - 1/d_k
  min_d = d_k + 2  (Distinct denominator rule)
Terminates when x_k reaches 0.
"""

from fractions import Fraction
import json
import math
import sys
from typing import List, Dict, Any, Tuple


def next_odd_denominator(num: int, den: int, min_d: int = 3) -> int:
    """Find the minimal odd integer d >= min_d such that 1/d <= num/den (den <= num * d)."""
    assert num > 0 and den > 0
    # ceil(den / num) = (den + num - 1) // num
    cand = (den + num - 1) // num
    cand = max(cand, min_d)
    if cand % 2 == 0:
        cand += 1
    return cand


def expand_odd_greedy(a: int, b: int, distinct: bool = True, max_steps: int = 1000) -> Dict[str, Any]:
    """Compute the odd greedy Egyptian fraction expansion of rational a / b.
    
    Returns exact sequence of denominators, step count, and trajectory statistics.
    """
    assert b % 2 == 1, f"Denominator {b} must be odd"
    assert 0 < a < b, f"Fraction {a}/{b} must be in (0, 1)"

    g = math.gcd(a, b)
    cur_num = a // g
    cur_den = b // g

    denominators: List[int] = []
    min_d = 3
    max_num = cur_num
    step = 0

    while cur_num > 0 and step < max_steps:
        d = next_odd_denominator(cur_num, cur_den, min_d)
        denominators.append(d)

        # Exact subtraction: cur_num/cur_den - 1/d = (cur_num * d - cur_den) / (cur_den * d)
        new_num = cur_num * d - cur_den
        new_den = cur_den * d

        if new_num > 0:
            red_g = math.gcd(new_num, new_den)
            cur_num = new_num // red_g
            cur_den = new_den // red_g
            max_num = max(max_num, cur_num)
        else:
            cur_num = 0
            cur_den = 1

        min_d = (d + 2) if distinct else 3
        step += 1

    terminated = (cur_num == 0)

    # Verification cross-check: verify that sum(1/d) equals a/b exactly
    if terminated:
        computed_sum = sum(Fraction(1, d) for d in denominators)
        assert computed_sum == Fraction(a, b), f"Arithmetic mismatch for {a}/{b}"

    return {
        "fraction": f"{a}/{b}",
        "initial": (a, b),
        "distinct": distinct,
        "terminated": terminated,
        "steps": len(denominators),
        "max_numerator": max_num,
        "max_denominator_bits": denominators[-1].bit_length() if denominators else 0,
        "denominators": denominators,
        "total_denominators": len(denominators)
    }


def verify_survey(max_b: int = 101, distinct: bool = True) -> Dict[str, Any]:
    """Exhaustively verify all irreducible fractions a/b with odd b <= max_b."""
    total_tested = 0
    max_steps = 0
    hardest_fraction = None
    max_num_spike = 0
    hardest_num_fraction = None

    for b in range(3, max_b + 1, 2):
        for a in range(1, b):
            if math.gcd(a, b) != 1:
                continue
            total_tested += 1
            res = expand_odd_greedy(a, b, distinct=distinct, max_steps=1000)
            if not res["terminated"]:
                return {"success": False, "failed_at": (a, b)}
            if res["steps"] > max_steps:
                max_steps = res["steps"]
                hardest_fraction = (a, b)
            if res["max_numerator"] > max_num_spike:
                max_num_spike = res["max_numerator"]
                hardest_num_fraction = (a, b)

    return {
        "success": True,
        "max_b": max_b,
        "distinct": distinct,
        "total_tested": total_tested,
        "max_steps": max_steps,
        "hardest_fraction": hardest_fraction,
        "max_numerator_spike": max_num_spike,
        "hardest_numerator_fraction": hardest_num_fraction
    }


if __name__ == "__main__":
    limit = int(sys.argv[1]) if len(sys.argv) > 1 else 101
    print(f"Running survey for odd b <= {limit}...")
    summary = verify_survey(limit)
    print(json.dumps(summary, indent=2))
