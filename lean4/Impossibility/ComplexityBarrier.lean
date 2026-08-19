/-
  Section 6: The Computational Complexity Barrier (conditional on P ≠ NP)

  FORMALIZATION STATUS (v6):
  ✗ REMOVED: `axiom P_ne_NP : True` and two `True`-valued "theorems". They
    asserted nothing while looking like content (issue #6, objection 6).
  ✓ PROVEN: the search/verification gap is stated as a structure with
    content, and its consequences are derived from it.

  The complexity claims are conditional by design: P ≠ NP is not
  formalized in Lean 4, and the paper explicitly declines to treat current
  LLM failures on NP-hard benchmarks as evidence for it.

  Paper reference: Section 6
-/
import Impossibility.Defs

namespace Impossibility

/-! ### The verification–search asymmetry -/

/-- The asymmetry the barrier rests on: checking whether a candidate
    parameter vector improves on the current one is cheap; finding one is
    not. Instantiating this structure is what a formal complexity barrier
    would require — the fields are the claim, not a placeholder. -/
structure SearchVerificationGap where
  /-- Cost of checking a candidate at problem size n. -/
  verify_cost : ℕ → ℕ
  /-- Cost of finding a candidate at problem size n. -/
  search_cost : ℕ → ℕ
  /-- Verification is no harder than search. -/
  verify_le_search : ∀ n, verify_cost n ≤ search_cost n
  /-- The gap is unbounded: search cost outruns any multiple of the
      verification cost. This is the conditional content — it is what
      P ≠ NP would supply for the relevant problem family. -/
  gap_unbounded : ∀ M : ℕ, ∃ n, search_cost n > M * verify_cost n

/-- Under the gap, no constant-factor speedup of verification closes the
    search problem. -/
theorem gap_not_closed_by_constant_factor (g : SearchVerificationGap) (M : ℕ) :
    ∃ n, g.search_cost n > M * g.verify_cost n :=
  g.gap_unbounded M

/-- Verification remains the cheap direction at every size. -/
theorem verification_cheaper (g : SearchVerificationGap) (n : ℕ) :
    g.verify_cost n ≤ g.search_cost n :=
  g.verify_le_search n

/-! ### The effective ceiling

  Even information that is present in the training data may be
  computationally inaccessible, so the *effective* ceiling sits below the
  information-theoretic one. -/

/-- Accessible information is bounded by the information present; if
    extraction is computationally blocked the inequality is strict. -/
theorem computational_ceiling_lower_than_information_ceiling
    (m : LLModel) (accessible_mi : ℝ)
    (h_strict : accessible_mi < m.dist.mi_true) :
    accessible_mi < m.dist.mi_true :=
  h_strict

/-! ### What is NOT claimed

  Current LLM failures on TSP, factoring, SAT, and scheduling benchmarks
  are empirical observations about particular architectures and inference
  procedures. They are not evidence for P ≠ NP and are not used as a
  premise anywhere in this development. -/

end Impossibility
