/-
  Theorem 6.1: Separation Between Pattern Completion and General Reasoning
  (The Pattern Completion Barrier)

  FORMALIZATION STATUS (v6):
  ⊘ AXIOM: Kolmogorov complexity. No Lean 4 formalization exists. In v5
    this was a `def` returning 0, which made the barrier statement
    *false* (0 > n fails for every n ≥ 0) and left it `sorry`-ed. It is
    now an abstract constant with the one property the argument uses —
    unboundedness — stated as a named bridge axiom.
  ✓ PROVEN: the finite-configuration bound for a fixed context window.

  Paper reference: Section 6
-/
import Mathlib.Data.Fintype.Pi
import Impossibility.Defs

namespace Impossibility

/-! ### Kolmogorov complexity (abstract)

  K(f) is the length of the shortest program computing f, relative to a
  fixed universal machine. It is not computable, and Mathlib has no
  formalization of it. -/

/-- Kolmogorov complexity relative to a fixed universal machine. -/
axiom kolmogorov_complexity : (ℕ → ℕ) → ℕ

/-- **Bridge axiom: K is unbounded.** For every bound there is a function
    of strictly greater complexity — a counting argument (there are more
    functions than short programs). This is the only property of K the
    barrier uses. -/
axiom kolmogorov_unbounded : ∀ n : ℕ, ∃ f : ℕ → ℕ, kolmogorov_complexity f > n

/-- Upper bound on the complexity extractable from a corpus: you cannot
    extract more description length than the corpus contains. -/
def max_complexity_from_data (training_data_size : ℕ) : ℕ := training_data_size

/-! ### Theorem 6.1 -/

/-- **Pattern completion barrier (from the unboundedness axiom).**

    For any finite corpus there are computable functions whose shortest
    description exceeds anything the corpus can supply, so they cannot be
    reconstructed from patterns in it. -/
theorem pattern_completion_barrier (training_data_size : ℕ) :
    ∃ f : ℕ → ℕ,
      kolmogorov_complexity f > max_complexity_from_data training_data_size :=
  kolmogorov_unbounded _

/-! ### Finite context ⇒ finitely many configurations -/

/-- **PROVEN.** A model with a fixed context window over a finite
    vocabulary has exactly |V|^C distinct context configurations: with
    fixed precision it is a finite-state device, not a Turing machine.
    (This bounds configurations, not the function class reachable with
    external scratch space — the paper states the limitation for the
    fixed-context, fixed-precision setting only.) -/
theorem transformer_configurations_finite (m : LLModel) (V : Vocabulary) :
    Fintype.card (Fin m.context_window → Fin V.size) = V.size ^ m.context_window := by
  simp

end Impossibility
