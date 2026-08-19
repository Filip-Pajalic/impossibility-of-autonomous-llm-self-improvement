/-
  Theorem 5.1: Self-Training Converges to a Trivial Fixed Point
  (The SGD Fixed-Point Trap)

  FORMALIZATION STATUS (v6):
  ✓ PROVEN: self-training never increases information about ground truth
    (same channel argument as the information ceiling).
  ✓ PROVEN: the teacher distribution is a fixed point of the population
    self-distillation objective, stated over an abstract KL functional.
  ⊘ CONDITIONAL: Fisher-rank contraction is carried as an explicit
    hypothesis; the abstract model has no Fisher geometry to derive it
    from, and pretending otherwise would be a placeholder.

  Paper reference: Section 5
-/
import Impossibility.Defs
import Impossibility.InformationCeiling

namespace Impossibility

/-! ### Theorem 5.1 -/

/-- **Self-training does not increase information (PROVEN).**

    The self-training loss L_k(θ) = H(p_{θ_k}) + KL(p_{θ_k} ‖ p_θ) is
    minimized at p_θ = p_{θ_k}: the model is optimizing to reproduce
    itself. Formalized here as the induced information statement. -/
theorem sgd_fixed_point (seq : SelfImprovementSeq) :
    ∀ k, (seq.model (k + 1)).dist.mi_true ≤ (seq.model k).dist.mi_true :=
  mi_step_le seq

/-- **The teacher is a minimizer of the population objective (PROVEN).**

    For any non-negative divergence `D` that vanishes on the diagonal, the
    objective `θ ↦ H(p_teacher) + D p_teacher p_θ` attains its minimum at
    `p_θ = p_teacher`. This is the exact sense in which "the model is
    trying to become better at being itself". -/
theorem teacher_is_minimizer
    (D : SeqDist → SeqDist → ℝ)
    (h_nonneg : ∀ p q, 0 ≤ D p q)
    (h_diag : ∀ p, D p p = 0)
    (H : SeqDist → ℝ) (teacher : SeqDist) :
    ∀ q, H teacher + D teacher teacher ≤ H teacher + D teacher q := by
  intro q
  have h0 := h_diag teacher
  have h1 := h_nonneg teacher q
  linarith

/-- Fisher-rank contraction, stated conditionally. As the distribution
    concentrates, the gradient subspace shrinks; the abstract model does
    not contain the geometry needed to derive this, so the contraction is
    a hypothesis rather than a theorem. -/
theorem fisher_rank_contraction (seq : SelfImprovementSeq)
    (h_contract : ∀ k, (seq.model (k + 1)).fisher_rank ≤ (seq.model k).fisher_rank) :
    ∀ k, (seq.model (k + 1)).fisher_rank ≤ (seq.model k).fisher_rank :=
  h_contract

/-- Combined statement: information never rises, and (under the stated
    hypothesis) the optimization dimensionality never rises either. -/
theorem self_reinforcement_not_improvement (seq : SelfImprovementSeq)
    (h_contract : ∀ k, (seq.model (k + 1)).fisher_rank ≤ (seq.model k).fisher_rank) :
    (∀ k, (seq.model (k + 1)).dist.mi_true ≤ (seq.model k).dist.mi_true) ∧
    (∀ k, (seq.model (k + 1)).fisher_rank ≤ (seq.model k).fisher_rank) :=
  ⟨sgd_fixed_point seq, h_contract⟩

end Impossibility
