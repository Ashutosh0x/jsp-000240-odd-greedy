"""Empirical search and verification engine for Erdős Problem #282 / JSP-000240.

Investigates Stein's Odd Greedy Egyptian Fraction Algorithm:
Given x = a / b with 0 < a < b and b odd:
At step k, select the smallest odd integer d_k > d_{k-1} such that 1/d_k <= x_k.
Update x_{k+1} = x_k - 1/d_k.
Check if x reaches 0 in finitely many steps.
"""

import math
from fractions import Fraction
import sys


def next_odd_denominator(rem: Fraction, min_d: int = 1) -> int:
    """Find the smallest odd integer d >= min_d such that 1/d <= rem."""
    # 1/d <= rem  <=>  d >= rem.denominator / rem.numerator
    # ceil(b / a) = (b + a - 1) // a
    a, b = rem.numerator, rem.denominator
    cand = (b + a - 1) // a
    # Must be at least min_d
    cand = max(cand, min_d)
    # Must be odd
    if cand % 2 == 0:
        cand += 1
    return cand


def odd_greedy_expansion(a: int, b: int, max_steps: int = 500):
    """Compute the odd greedy Egyptian fraction expansion of a / b."""
    assert b % 2 == 1, "Initial denominator must be odd"
    assert 0 < a < b, "Fraction must be strictly between 0 and 1"

    rem = Fraction(a, b)
    denominators = []
    min_d = 3  # First odd denominator must be at least 3 since a < b

    step = 0
    max_num = a
    while rem > 0 and step < max_steps:
        d = next_odd_denominator(rem, min_d)
        denominators.append(d)
        rem = rem - Fraction(1, d)
        max_num = max(max_num, rem.numerator)
        min_d = d + 2  # Denominators must strictly increase: next odd is at least d + 2
        step += 1

    return {
        "initial": (a, b),
        "terminated": (rem == 0),
        "steps": len(denominators),
        "max_numerator": max_num,
        "max_denominator_bits": denominators[-1].bit_length() if denominators else 0,
        "denominators": denominators[:10],  # first 10
        "total_denominators": len(denominators)
    }


def run_survey(max_b: int = 199):
    """Run an exhaustive survey over all irreducible a/b with b odd <= max_b."""
    total_tested = 0
    max_steps_seen = 0
    hardest_fraction = None
    max_spike_num = 0
    hardest_spike = None

    for b in range(3, max_b + 1, 2):
        for a in range(1, b):
            if math.gcd(a, b) != 1:
                continue
            total_tested += 1
            res = odd_greedy_expansion(a, b, max_steps=1000)
            if not res["terminated"]:
                print(f"[POTENTIAL COUNTEREXAMPLE / EXPLOSION] {a}/{b} did not terminate in 1000 steps!")
                return res
            if res["steps"] > max_steps_seen:
                max_steps_seen = res["steps"]
                hardest_fraction = (a, b)
            if res["max_numerator"] > max_spike_num:
                max_spike_num = res["max_numerator"]
                hardest_spike = (a, b)

    print(f"=== SURVEY COMPLETE: b <= {max_b} ===")
    print(f"Total irreducible odd-denominator fractions tested: {total_tested}")
    print(f"All terminated successfully: True")
    print(f"Maximum steps observed: {max_steps_seen} for fraction {hardest_fraction[0]}/{hardest_fraction[1]}")
    print(f"Maximum intermediate numerator spike: {max_spike_num} for fraction {hardest_spike[0]}/{hardest_spike[1]}")
    
    # Detail hardest fraction
    hardest_res = odd_greedy_expansion(hardest_fraction[0], hardest_fraction[1])
    print(f"Denominators for {hardest_fraction[0]}/{hardest_fraction[1]}: {hardest_res['denominators']} (total {hardest_res['steps']} steps)")
    print(f"Max denominator bit length: {hardest_res['max_denominator_bits']} bits")


if __name__ == "__main__":
    limit = int(sys.argv[1]) if len(sys.argv) > 1 else 101
    run_survey(limit)
