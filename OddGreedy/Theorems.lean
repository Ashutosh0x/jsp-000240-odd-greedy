/-
Copyright (c) 2026 Ashutosh. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ashutosh
-/
import OddGreedy.Definitions

namespace OddGreedy

/-- Unit fraction sum of a singleton [b] equals 1 / b. -/
theorem unitFractionSum_singleton (b : Nat) (hb : 0 < b) :
    unitFractionSumEquals [b] 1 b := by
  dsimp [unitFractionSumEquals, unitFractionSumAcc]
  omega

/-- Concrete test case: 2/3 distinct-denominator expansion [3, 5, 9, 45].
    Proves that 1/3 + 1/5 + 1/9 + 1/45 = 2/3. -/
theorem two_thirds_expansion_correct :
    unitFractionSumEquals [3, 5, 9, 45] 2 3 := by
  dsimp [unitFractionSumEquals, unitFractionSumAcc]
  decide

/-- Parity preservation lemma: If b is odd, then for any odd denominator d,
    the denominator of the next step b * d is also odd. -/
theorem step_preserves_odd_denominator {b d : Nat} (hb : IsOddNat b) (hd : IsOddNat d) :
    IsOddNat (b * d) :=
  isOddNat_mul hb hd

/-- The Fundamental Odd Greedy Transition Numerator Bound:
    If d is the minimal odd integer satisfying b <= a * d,
    and d >= 3, then the new numerator (a * d - b) satisfies:
    a * d - b < 2 * a.

    This explains why monotonic descent fails: the numerator may spike by up to
    a factor of 2, leading to potential doubly-exponential denominator explosion. -/
theorem odd_greedy_numerator_bound {a b d : Nat} (h_pos : 0 < a) (h_le : b ≤ a * d)
    (h_min : ∀ c : Nat, IsOddNat c → b ≤ a * c → d ≤ c)
    (hd_odd : IsOddNat d) (hd_ge3 : 3 ≤ d) :
    a * d - b < 2 * a := by
  rcases hd_odd with ⟨k, rfl⟩
  have hk : 1 ≤ k := by omega
  have h_dminus2_odd : IsOddNat (2 * k + 1 - 2) := by
    use (k - 1)
    omega
  have h_not_le : ¬(b ≤ a * (2 * k + 1 - 2)) := by
    intro h_le'
    have h_contra := h_min (2 * k + 1 - 2) h_dminus2_odd h_le'
    omega
  omega

/-- For a unit fraction 1/b with b odd and b >= 3, the choice d = b satisfies
    the greedy selection criteria starting from min_d = 3. -/
theorem unit_fraction_choice (b : Nat) (hb : IsOddNat b) (h_ge3 : 3 ≤ b) :
    IsGreedyOddChoice 1 b 3 b := by
  refine ⟨hb, h_ge3, by omega, ?_⟩
  intro c hc h_min_c h_le_c
  omega

/-- For numerator 2/b with b = 2k + 1:
    If k is even (so k + 1 is odd), choosing d = k + 1 drops the numerator to 1. -/
theorem numerator_two_even_k_remainder (k : Nat) (hk : ∃ m, k = 2 * m) :
    let b := 2 * k + 1
    let d₁ := k + 1
    (2 * d₁ - b = 1) := by
  intro b d₁
  dsimp [b, d₁]
  omega

end OddGreedy
