# Verification and Mathematical Integrity Report: JSP-000240 / Erdős Problem #282

---

**Report Date:** November 2, 2026  
**Repository:** [`Ashutosh0x/jsp-000240-odd-greedy`](https://github.com/Ashutosh0x/jsp-000240-odd-greedy)  
**Target Identifier:** Erdős Problem #282 / The Justin Sun Prize `JSP-000240`  
**Classification:** Research Verification Dossier & Formalization Audit (V2 Release)  
**Status:** **OPEN / UNRESOLVED** (Partial verified theorems, formal invariants, and empirical bounds established; no universal termination proof claimed)

---

## 1. Mathematical Problem Statement & Historical Origin

Originally posed by **Sherman K. Stein** in the 1970s and formulated by **Paul Erdős and Ronald L. Graham** in 1980:

> Let $x = \frac{a}{b} \in (0, 1)$ be a rational number with $b$ odd.
> Define an Egyptian fraction algorithm that repeatedly chooses the smallest odd integer $d_k > d_{k-1}$ such that $\frac{1}{d_k} \le x_k$, and sets $x_{k+1} = x_k - \frac{1}{d_k}$.
> **Does this process always reach exactly zero after finitely many steps?**

### The Crucial Algorithm Distinction: Distinct vs. Repeat-Allowed
- **Distinct-Denominator Greedy (The Canonical Erdős Problem #282):**
  Requires $d_k > d_{k-1}$ at every step.
  For example, for $x = 2/3$:
  $$\frac{2}{3} = \frac{1}{3} + \frac{1}{5} + \frac{1}{9} + \frac{1}{45} \quad (4 \text{ steps})$$
- **Repeat-Allowed Greedy:**
  Allows identical denominators:
  $$\frac{2}{3} = \frac{1}{3} + \frac{1}{3} \quad (2 \text{ steps})$$
Our repository models and enforces the **strict distinct-denominator** formulation.

---

## 2. Formal Invariants & Mechanically Checked Theorems

In `OddGreedy/Theorems.lean`:

| Theorem | Formal Name | Status | Axiom Dependencies |
|---|---|---|---|
| **Odd Parity Preservation** | `step_preserves_odd_denominator` | **Formally Proved** | Standard Classical (`propext`, `Quot.sound`, `Classical.choice`) |
| **Singleton Unit Fraction Sum** | `unitFractionSum_singleton` | **Formally Proved** | Standard Classical |
| **Exact 2/3 Expansion Verification** | `two_thirds_expansion_correct` | **Formally Proved** | Standard Classical (decide) |
| **Transition Numerator Bound** | `odd_greedy_numerator_bound` | **Formally Proved** | Standard Classical |
| **Greedy Choice for Unit Fractions** | `unit_fraction_choice` | **Formally Proved** | Standard Classical |
| **Numerator-Two Step Transition** | `numerator_two_even_k_remainder` | **Formally Proved** | Standard Classical |

### The Transition Bound Insight
In `odd_greedy_numerator_bound`, we proved:
$$\text{If } d = \min \{ c \in \mathbb{N} \mid c \text{ odd}, b \le a \cdot c \}, \quad \text{then } a \cdot d - b < 2a.$$
This bound explains the core theoretical obstruction to Sylvester-style proofs:
Because $a_{k+1} = a_k d_k - b_k$ can equal $2 a_k - 1$ (strictly less than $2a$, but potentially larger than $a$), intermediate numerators can **increase**, precluding monotonic numerator descent.

---

## 3. Computational Survey Reproduction

All calculations run with exact arbitrary-precision integer arithmetic (`Search.py`):

1. **Domain $b \le 101$:**
   - Total irreducible odd fractions tested: **2,106**
   - Termination rate: **100%**
   - Maximum steps: **18 steps** for $84/85$
   - Maximum intermediate numerator spike: **186,356** for $95/97$
   - Max denominator bit length: **10,369 bits**
2. **Domain $b \le 199$:**
   - Total irreducible odd fractions tested: **8,150**
   - Termination rate: **100%**
   - Maximum steps: **21 steps** for $191/197$
   - Maximum intermediate numerator spike: **755,141** for $169/173$
   - Max denominator bit length: **94,168 bits**
3. **Infinite Families Tested:**
   - Numerator $a = 2, b \le 10,000$ (5,000 odd fractions): Max steps **22** (100% termination)
   - Numerator $a = 3, b \le 10,000$ (3,333 odd fractions): Max steps **21** (100% termination)

---

## 4. Formal Statement Fidelity: Stein's Conjecture vs. Breusch's Theorem

In `OddGreedy/Definitions.lean`:
- **Weak Egyptian Representation (`WeakOddEgyptianRepresentationExists`):**
  Asserts that *some* finite list of odd unit fractions sums to $a/b$. This was solved positively by **Robert Breusch in 1954**.
- **Stein's Odd Greedy Conjecture (`ErdosProblem282Conjecture`):**
  Asserts that the **uniquely determined deterministic greedy transition sequence** terminates at remainder zero in finitely many steps.
The repository explicitly distinguishes these two propositions to prevent false claims of solving the problem via existential decompositions.

---

## 5. Explicit Conclusion

- **Is Erdős Problem #282 / JSP-000240 solved?**
  **NO.** The general conjecture remains officially **OPEN**.
- **What has been established?**
  A rigorous Lean 4 formalization of the algorithm's state space, transition bound ($a_{k+1} < 2 a_k$), exact unit fraction sum calculations, parity preservation theorems, and exhaustive empirical verification across all odd denominators through $b \le 199$ and numerator families through $b \le 10,000$.
- **Award Eligibility Status:**
  Ineligible for a full solution prize until a universal termination proof covering all positive rationals with odd denominators is formalized without unproved axioms.
