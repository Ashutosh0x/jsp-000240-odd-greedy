/-
Copyright (c) 2026 Ashutosh. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ashutosh
-/

namespace OddGreedy

/-- An integer is odd if it can be represented as `2 * k + 1` for some integer `k`. -/
def IsOddInt (n : Int) : Prop :=
  ∃ k : Int, n = 2 * k + 1

/-- A natural number is odd if it can be represented as `2 * k + 1` for some natural number `k`. -/
def IsOddNat (n : Nat) : Prop :=
  ∃ k : Nat, n = 2 * k + 1

/-- Parity preservation under product of odd natural numbers. -/
theorem isOddNat_mul {a b : Nat} (ha : IsOddNat a) (hb : IsOddNat b) : IsOddNat (a * b) := by
  rcases ha with ⟨ka, rfl⟩
  rcases hb with ⟨kb, rfl⟩
  use (2 * ka * kb + ka + kb)
  omega

/-- Parity preservation under product of odd integers. -/
theorem isOddInt_mul {a b : Int} (ha : IsOddInt a) (hb : IsOddInt b) : IsOddInt (a * b) := by
  rcases ha with ⟨ka, rfl⟩
  rcases hb with ⟨kb, rfl⟩
  use (2 * ka * kb + ka + kb)
  ring

/-- An eligible fraction for Stein's odd greedy algorithm:
    A rational pair (a, b) with 0 < a < b and b is odd. -/
structure OddFraction where
  num : Nat
  den : Nat
  h_pos : 0 < num
  h_lt  : num < den
  h_odd : IsOddNat den

end OddGreedy
