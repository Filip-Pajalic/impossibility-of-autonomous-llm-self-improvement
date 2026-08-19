/-
  Theorem 2.1: Self-Generated Data Cannot Increase Information
  (Information-Theoretic Ceiling)

  FORMALIZATION STATUS (v6):
  ✓ PROVEN: `info_ceiling` — by induction from the channel data-processing
            field introduced in `Defs.lean`. No `sorry`.
  ✓ PROVEN: `search_bounded_by_ceiling` — inference-time search is a
            channel with no external input.
  ✓ PROVEN: `accuracy_ceiling_of_info_ceiling` — the Fano-type link that
            converts an information ceiling into an *accuracy* ceiling,
            which is what the AGI criterion actually talks about
            (issue #6, objection 2).
  ✓ PROVEN: `StepLoss.after_lt` — strict decrease holds exactly when the
            step fails to be a sufficient statistic, which is the correct
            criterion (the v4 criterion, "model ≠ truth", does not imply it).
  ⊘ ASSUMED: the data processing inequality itself, carried as the `dpi`
            field of `TrainingChannel`. It is no longer a free-floating
            axiom whose hypothesis was its own conclusion.

  Paper reference: Section 2
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Impossibility.Defs

namespace Impossibility

/-! ### Theorem 2.1

  The self-improvement loop forms the Markov chain

    Θ → D_train → θ_0 → p_{θ_0} → D_0^self → θ_1 → ⋯ → θ_k

  where Θ is the ground-truth random variable of the Bayesian joint
  (Section 2.1 of the paper). Each arrow is a `TrainingChannel`, and each
  channel carries the data-processing property as a field, so the ceiling
  follows by induction rather than by assumption at the sequence level. -/

/-- One step of the loop cannot increase information about ground truth. -/
theorem mi_step_le (seq : SelfImprovementSeq) (k : ℕ) :
    (seq.model (k + 1)).dist.mi_true ≤ (seq.model k).dist.mi_true := by
  rw [seq.dist_succ k]
  exact (seq.channel k).dpi _

/-- **Information ceiling (PROVEN).**

    I(p_{θ_k}; Θ) ≤ I(p_{θ_0}; Θ) for every k. -/
theorem info_ceiling (seq : SelfImprovementSeq) :
    ∀ k, (seq.model k).dist.mi_true ≤ (seq.model 0).dist.mi_true := by
  intro k
  induction k with
  | zero => exact le_refl _
  | succ n ih => exact le_trans (mi_step_le seq n) ih

/-- The sequence of informations is monotonically non-increasing. -/
theorem info_antitone (seq : SelfImprovementSeq) {m n : ℕ} (h : m ≤ n) :
    (seq.model n).dist.mi_true ≤ (seq.model m).dist.mi_true := by
  induction n with
  | zero =>
    have : m = 0 := Nat.le_zero.mp h
    rw [this]
  | succ p ih =>
    rcases Nat.lt_or_ge m (p + 1) with hlt | hge
    · exact le_trans (mi_step_le seq p) (ih (Nat.lt_succ_iff.mp hlt))
    · have : m = p + 1 := le_antisymm h hge
      rw [this]

/-- Inference-time search (beam search, tree search, chain-of-thought
    sampling) is a channel applied to the model's own distribution with no
    external input, so it cannot exceed the ceiling either. -/
theorem search_bounded_by_ceiling (search : TrainingChannel) (d : SeqDist) :
    (search.apply d).mi_true ≤ d.mi_true :=
  search.dpi d

/-! ### The information → accuracy link (Fano)

  The ceiling bounds mutual information; the AGI criterion is a statement
  about *success probability*. Fano's inequality supplies the missing
  link: with the ground truth uniform over M ≥ 2 candidate hypotheses, any
  answering rule that is a function of θ_k has success probability at most
  (I(θ_k; Θ) + log 2) / log M.

  We take the Fano bound for the given model as a hypothesis (it is a
  standard consequence of the joint fixed in Section 2.1) and prove that
  the information ceiling transports it to a ceiling on accuracy that no
  amount of autonomous iteration can raise. -/

/-- **Information ceiling ⟹ accuracy ceiling (PROVEN).** -/
theorem accuracy_ceiling_of_info_ceiling
    (M : ℕ) (hM : 2 ≤ M) (acc mi mi₀ : ℝ)
    (h_fano : acc ≤ (mi + Real.log 2) / Real.log M)
    (h_ceiling : mi ≤ mi₀) :
    acc ≤ (mi₀ + Real.log 2) / Real.log M := by
  have hM1 : (1 : ℝ) < (M : ℝ) := by
    have : (1 : ℕ) < M := lt_of_lt_of_le Nat.one_lt_two hM
    exact_mod_cast this
  have hlog : 0 < Real.log (M : ℝ) := Real.log_pos hM1
  refine le_trans h_fano ?_
  gcongr

/-- **Consequence for the AGI criterion.** If the accuracy ceiling implied
    by the initial information budget is below the AGI success threshold
    1 − ε, no autonomous iterate attains the threshold. -/
theorem agi_accuracy_unreachable
    (M : ℕ) (hM : 2 ≤ M) (acc mi mi₀ ε : ℝ)
    (h_fano : acc ≤ (mi + Real.log 2) / Real.log M)
    (h_ceiling : mi ≤ mi₀)
    (h_gap : (mi₀ + Real.log 2) / Real.log M < 1 - ε) :
    acc < 1 - ε :=
  lt_of_le_of_lt (accuracy_ceiling_of_info_ceiling M hM acc mi mi₀ h_fano h_ceiling) h_gap

/-! ### Strict decrease (v6)

  The v4 manuscript attached strictness to the wrong condition ("strict
  whenever p_θ ≠ p_true"), which does not follow: a bijective
  reparameterization differs from ground truth and destroys nothing. The
  correct condition is exact. For the Markov chain Θ → θ_k → θ_{k+1},

    I(Θ; θ_k) − I(Θ; θ_{k+1}) = I(Θ; θ_k | θ_{k+1}),

  so the decrease is strict iff θ_{k+1} fails to be a sufficient statistic
  for Θ relative to θ_k. Proposition 2.4 of the paper shows finite-sample
  self-distillation meets that condition: sampling misses the tail below
  1/N with probability bounded below, so the update cannot separate
  hypotheses that differ only there.

  We record the identity as a structure (the conditional information is a
  real number here, as everywhere in this development) and derive both the
  non-strict and strict conclusions from it. -/

/-- One step of the loop, carrying the exact information-loss decomposition
    `after = before − residual`, where the residual is the conditional
    information `I(Θ; θ_k | θ_{k+1})` that the update discards. -/
structure StepLoss where
  /-- I(Θ; θ_k) -/
  before : ℝ
  /-- I(Θ; θ_{k+1}) -/
  after : ℝ
  /-- I(Θ; θ_k | θ_{k+1}) -/
  residual : ℝ
  /-- Chain-rule identity for the Markov chain Θ → θ_k → θ_{k+1}. -/
  identity : after = before - residual
  /-- Conditional mutual information is non-negative. -/
  residual_nonneg : 0 ≤ residual

namespace StepLoss

/-- The non-strict ceiling, recovered from the identity. -/
theorem after_le (s : StepLoss) : s.after ≤ s.before := by
  rw [s.identity]
  linarith [s.residual_nonneg]

/-- **Strict decrease (PROVEN) exactly when the step is not sufficient.**
    `residual > 0` says the old model retained information about ground
    truth that the new one lost. -/
theorem after_lt (s : StepLoss) (h : 0 < s.residual) : s.after < s.before := by
  rw [s.identity]
  linarith

/-- Conversely, no loss means no strict decrease: the step was sufficient. -/
theorem sufficient_iff (s : StepLoss) : s.after = s.before ↔ s.residual = 0 := by
  constructor
  · intro h; rw [s.identity] at h; linarith
  · intro h; rw [s.identity, h]; ring

end StepLoss

end Impossibility
