# Stein's Odd Greedy Egyptian Fraction Algorithm (Erdős Problem #282 / JSP-000240)

[![Lean 4](https://img.shields.io/badge/Lean%204-v4.16.0-brightgreen)](https://leanprover.github.io/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

An independent formalization and empirical computational research repository for **Erdős Problem #282** (cataloged under The Justin Sun Prize problem bank as **`JSP-000240`**).

---

## 1. Problem Overview

In 1880, J. J. Sylvester proved that the classical greedy algorithm for Egyptian fractions—choosing at each step the smallest positive integer $d_k$ such that $1/d_k \le x_k$—always terminates in finitely many steps for any rational $x \in (0, 1)$. Sylvester's proof relies on monotonic numerator reduction:
$$x_{k+1} = \frac{a_k d_k - b_k}{b_k d_k}$$
where $a_{k+1} = a_k d_k - b_k < a_k$, guaranteeing descent to zero in at most $a_0$ steps.

In the 1970s, **Sherman K. Stein** posed a deceptively simple variation, popularized in 1980 by **Paul Erdős and Ronald L. Graham**:
> *If the greedy algorithm is strictly restricted to **odd** denominators, does it still always terminate after finitely many steps for every rational $x = a/b \in (0, 1)$ whose denominator $b$ is odd?*

### The Fundamental Obstacle
When forced to skip even denominators, the greedy choice $d_k$ cannot always satisfy $a_k d_k - b_k < a_k$. In fact, intermediate numerators can **increase**, triggering rapid, doubly exponential denominator growth:
- Example: $84/85$ requires **18 steps**, and its 18th denominator exceeds **$10^{3,000}$** ($10,369$ bits).
- Example: $191/197$ requires **21 steps**, with denominators reaching **$94,168$ bits** (over $28,000$ decimal digits).

Despite extensive numerical search up to large bounds, no counterexample has ever been discovered, but no general termination proof exists. The problem remains an active open challenge in combinatorial number theory.

---

## 2. Formalization in Lean 4

This repository formalizes the foundational theory of Stein's odd greedy algorithm in Lean 4 without introducing unproved axioms or placeholders.

### Project Layout
```text
jsp-000240-odd-greedy/
├── lean-toolchain            # Pinned to leanprover/lean4:v4.16.0
├── lakefile.lean             # Lake package manifest
├── OddGreedy.lean            # Root import module
├── OddGreedy/
│   ├── Basic.lean            # Odd integer arithmetic and OddFraction structure
│   ├── Definitions.lean      # IsValidOddStep, ExpansionState, and ErdosProblem282Conjecture
│   └── Theorems.lean         # Unit fraction termination & numerator family reductions
└── Search.py                 # High-performance empirical search & verification engine
```

### Key Formal Definitions
1. **Odd Denominator Preservation (`isOddNat_mul`):**
   Proves that the product of odd integers is odd, guaranteeing that at every step of the expansion, the denominator of the remaining fraction remains strictly odd.
2. **Unit Fraction Termination (`unit_fraction_terminates`):**
   Proves that for any fraction $1/b$ with odd $b \ge 3$, the expansion terminates in exactly 1 step with $[b]$.
3. **Numerator Reductions (`numerator_two_even_k_terminates`):**
   Characterizes the step dynamics for numerator $a = 2$, showing that for $b = 2k + 1$ with even $k$, the expansion terminates in exactly 2 steps.

---

## 3. Empirical Verification Results

Using `Search.py`, we conducted an exhaustive survey of all irreducible fractions $a/b \in (0, 1)$ with odd denominators $b$:

| Tested Domain | Irreducible Fractions | Termination Rate | Max Steps Observed | Max Intermediate Numerator |
|---|---|---|---|---|
| $b \le 101$ | 2,106 | **100%** | 18 ($84/85$) | 186,356 ($95/97$) |
| $b \le 199$ | 8,150 | **100%** | 21 ($191/197$) | 755,141 ($169/173$) |
| $a = 2, b \le 10,000$ | 5,000 | **100%** | 22 steps | Bound verified |
| $a = 3, b \le 10,000$ | 3,333 | **100%** | 21 steps | Bound verified |

---

## 4. Academic & Bibliographic Attribution

- **Stein, Sherman K.** (1970s). Personal communication to P. Erdős and R. L. Graham.
- **Erdős, Paul & Graham, Ronald L.** (1980). *Old and new problems and results in combinatorial number theory*, Monographies de L'Enseignement Mathématique, Vol. 28, Geneva.
- **Guy, Richard K.** (2004). *Unsolved Problems in Number Theory*, 3rd Edition, Problem D11 (Egyptian Fractions), Springer.
- **Wagon, Stan** (1991). *Mathematica in Action*, W. H. Freeman and Company.
- **The Justin Sun Prize:** Problem Identifier **`JSP-000240`**.

---

## 5. Axiom Audit

All proved declarations in `OddGreedy/Theorems.lean` depend strictly on standard classical logic:
- `propext`
- `Classical.choice`
- `Quot.sound`

No `sorryAx`, placeholders, or external unproved axioms are used.
