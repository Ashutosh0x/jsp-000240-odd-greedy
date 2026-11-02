/-
Copyright (c) 2026 Ashutosh. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ashutosh
-/
import OddGreedy.Basic

namespace OddGreedy

/-- The greedy denominator condition: d is the smallest odd integer >= min_d
    satisfying 1/d <= a/b, which is b <= a * d. -/
def IsValidOddStep (a b min_d d : Nat) : Prop :=
  IsOddNat d ∧
  min_d ≤ d ∧
  b ≤ a * d ∧
  ∀ (c : Nat), IsOddNat c → min_d ≤ c → b ≤ a * c → d ≤ c

/-- The state of an odd greedy Egyptian fraction expansion after k steps:
    - `rem_num`: numerator of remaining fraction
    - `rem_den`: denominator of remaining fraction (always odd)
    - `last_den`: last chosen odd denominator
    - `history`: sequence of selected odd denominators
-/
structure ExpansionState where
  rem_num : Nat
  rem_den : Nat
  last_den : Nat
  history : List Nat
  h_den_odd : IsOddNat rem_den

/-- A single step of Stein's odd greedy algorithm:
    Given fraction (a, b) and chosen denominator d:
    new_num = a * d - b
    new_den = b * d
-/
def nextState (state : ExpansionState) (d : Nat) (hd : IsValidOddStep state.rem_num state.rem_den (state.last_den + 2) d) : ExpansionState :=
  { rem_num := state.rem_num * d - state.rem_den,
    rem_den := state.rem_den * d,
    last_den := d,
    history := state.history ++ [d],
    h_den_odd := isOddNat_mul state.h_den_odd hd.1 }

/-- Formal Statement of Erdős Problem #282 / JSP-000240:
    Does the greedy Egyptian fraction algorithm restricted to odd denominators
    always terminate for every rational input a/b with 0 < a < b and b odd? -/
def ErdosProblem282Conjecture : Prop :=
  ∀ (f : OddFraction),
    ∃ (dens : List Nat),
      (∀ d ∈ dens, IsOddNat d) ∧
      dens.Pairwise (· < ·) ∧
      -- The sum of unit fractions 1/d equals f.num / f.den
      (dens.foldl (fun acc d => acc * d + 1) 0 * f.den = f.num * dens.foldl (· * ·) 1)

end OddGreedy
