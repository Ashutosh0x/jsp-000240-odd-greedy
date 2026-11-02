/-
Copyright (c) 2026 Ashutosh. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ashutosh
-/
import OddGreedy.Basic

namespace OddGreedy

/-- Recursive exact calculation of a sum of unit fractions from a list of denominators,
    represented as a pair (numerator, denominator) of natural numbers.
    Sum([]) = 0 / 1
    Sum(d :: ds) = 1/d + Sum(ds) = (den_ds + num_ds * d) / (d * den_ds) -/
def unitFractionSumAcc : List Nat → Nat × Nat
  | [] => (0, 1)
  | d :: ds =>
    let (n, den) := unitFractionSumAcc ds
    (den + n * d, d * den)

/-- A list of denominators `dens` represents an exact Egyptian fraction decomposition of `a / b`
    if its unit fraction sum equals `a / b` in cross-multiplied natural arithmetic:
    num * b = a * den. -/
def unitFractionSumEquals (dens : List Nat) (a b : Nat) : Prop :=
  let (n, d) := unitFractionSumAcc dens
  n * b = a * d

/-- The greedy denominator selection criterion:
    `d` is the smallest odd integer >= `min_d` satisfying `1/d <= a/b` (i.e. `b <= a * d`). -/
def IsGreedyOddChoice (a b min_d d : Nat) : Prop :=
  IsOddNat d ∧
  min_d ≤ d ∧
  b ≤ a * d ∧
  ∀ (c : Nat), IsOddNat c → min_d ≤ c → b ≤ a * c → d ≤ c

/-- The state of Stein's odd greedy algorithm:
    - `rem_num`: remaining numerator (0 when terminated)
    - `rem_den`: remaining denominator (always odd)
    - `last_den`: last chosen odd denominator (strict monotonicity requires next d > last_den)
    - `steps`: history of chosen odd denominators
-/
structure ExpansionState where
  rem_num : Nat
  rem_den : Nat
  last_den : Nat
  steps : List Nat
  h_den_odd : IsOddNat rem_den

/-- Initial state for a rational fraction `a / b`. -/
def initialState (f : OddFraction) : ExpansionState :=
  { rem_num := f.num,
    rem_den := f.den,
    last_den := 1,  -- next denominator must be at least 3
    steps := [],
    h_den_odd := f.h_odd }

/-- Single deterministic transition of the distinct-denominator odd greedy algorithm.
    If the remainder is already 0, the state is terminal.
    Otherwise, choose the unique minimal odd `d >= last_den + 2` with `rem_den <= rem_num * d`.
-/
def nextState (s : ExpansionState) (d : Nat) (hd : IsGreedyOddChoice s.rem_num s.rem_den (s.last_den + 2) d) : ExpansionState :=
  { rem_num := s.rem_num * d - s.rem_den,
    rem_den := s.rem_den * d,
    last_den := d,
    steps := s.steps ++ [d],
    h_den_odd := isOddNat_mul s.h_den_odd hd.1 }

/-- Inductive reachability of an expansion state from an initial fraction
    under the deterministic odd greedy algorithm. -/
inductive Reachable : ExpansionState → Prop where
  | init (f : OddFraction) : Reachable (initialState f)
  | step (s : ExpansionState) (d : Nat)
         (hd : IsGreedyOddChoice s.rem_num s.rem_den (s.last_den + 2) d)
         (hs : Reachable s) (h_pos : 0 < s.rem_num) :
         Reachable (nextState s d hd)

/-- Mathematically Faithful Statement of Erdős Problem #282 / Stein's Odd Greedy Conjecture:
    Does the deterministic distinct-denominator odd greedy algorithm
    terminate at remainder 0 in finitely many steps for every eligible rational starting value? -/
def ErdosProblem282Conjecture : Prop :=
  ∀ (f : OddFraction),
    ∃ (s : ExpansionState),
      Reachable s ∧ s.rem_num = 0 ∧ unitFractionSumEquals s.steps f.num f.den

/-- Weak existential Egyptian fraction representation (Breusch 1954):
    Every fraction with odd denominator has SOME finite odd Egyptian fraction representation.
    (This is already a known theorem; Stein's conjecture is strictly stronger because it requires
    the greedy algorithm specifically to terminate). -/
def WeakOddEgyptianRepresentationExists (f : OddFraction) : Prop :=
  ∃ (dens : List Nat),
    (∀ d ∈ dens, IsOddNat d) ∧
    dens.Pairwise (· < ·) ∧
    unitFractionSumEquals dens f.num f.den

end OddGreedy
