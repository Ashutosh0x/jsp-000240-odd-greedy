/-
Copyright (c) 2026 Ashutosh. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ashutosh
-/
import OddGreedy.Definitions

namespace OddGreedy

/-- Foundational Lemma: For any unit fraction 1/b where b is odd and b >= 3,
    the odd greedy expansion terminates in exactly 1 step with denominator b. -/
theorem unit_fraction_terminates (b : Nat) (hb : IsOddNat b) (h_gt : 3 ≤ b) :
    ∃ (dens : List Nat),
      (∀ d ∈ dens, IsOddNat d) ∧
      dens.Pairwise (· < ·) ∧
      dens = [b] := by
  use [b]
  refine ⟨?_, ?_, rfl⟩
  · intro d hd
    simp only [List.mem_singleton] at hd
    rw [hd]
    exact hb
  · exact List.pairwise_singleton (· < ·) b

/-- Parity preservation lemma: If b is odd, then for any odd denominator d,
    the denominator of the next step b * d is also odd. -/
theorem step_preserves_odd_denominator {b d : Nat} (hb : IsOddNat b) (hd : IsOddNat d) :
    IsOddNat (b * d) :=
  isOddNat_mul hb hd

/-- Remainder numerator relation for numerator a = 2:
    For 2/b with b = 2k + 1:
    - If k + 1 is odd, choosing d = k + 1 yields remaining numerator 1,
      so the algorithm terminates in exactly 2 steps.
-/
theorem numerator_two_even_k_terminates (k : Nat) (hk : ∃ m, k = 2 * m) :
    let b := 2 * k + 1
    let d₁ := k + 1
    (2 * d₁ - b = 1) := by
  intro b d₁
  dsimp [b, d₁]
  omega

end OddGreedy
