/-
  Theorem 3.3: Entropy and Effective-Support Contraction Under
  Self-Distillation (Distributional Collapse)

  FORMALIZATION STATUS (v6):
  ✓ PROVEN from the channel assumptions: entropy contraction, effective
    support contraction, the sample-budget cap, and the corollary that an
    autonomous loop never reaches a target requiring a larger effective
    support.
  ✓ PROVEN: any mechanism that raises information about ground truth needs
    a grounded external signal (`gain_requires_grounded_signal`) — the
    formal core of the paper's "external grounding" claim.

  NOTE (issue #6, objection 3): the claims are stated over the ε-effective
  support. A softmax output layer assigns strictly positive probability to
  every sequence, so literal support inclusion is trivially an equality
  and carries no content.

  Paper reference: Section 3
-/
import Impossibility.Defs

namespace Impossibility

/-! ### Theorem 3.3 -/

/-- **Entropy contraction (PROVEN from the finite-sample assumption).**

    H(p_{θ_{k+1}}) ≤ H(p_{θ_k}). The content lives in the channel's
    `entropy_contract` field, which encodes the unfiltered, unsmoothed,
    finite-sample regime of the paper's Theorem 3.3. -/
theorem entropy_contraction (seq : SelfImprovementSeq) :
    ∀ k, (seq.model (k + 1)).dist.entropy ≤ (seq.model k).dist.entropy := by
  intro k
  rw [seq.dist_succ k]
  exact (seq.channel k).entropy_contract _

/-- **Effective-support contraction (PROVEN).**

    |S_ε(p_{θ_{k+1}})| ≤ |S_ε(p_{θ_k})|. -/
theorem eff_support_contraction (seq : SelfImprovementSeq) :
    ∀ k, (seq.model (k + 1)).dist.eff_support ≤ (seq.model k).dist.eff_support := by
  intro k
  rw [seq.dist_succ k]
  exact le_trans ((seq.channel k).eff_support_le _) (min_le_left _ _)

/-- The effective support after a step is also capped by that step's
    sample budget: you cannot represent more distinct behaviour than you
    sampled. -/
theorem eff_support_le_samples (seq : SelfImprovementSeq) (k : ℕ) :
    (seq.model (k + 1)).dist.eff_support ≤ (seq.channel k).num_samples := by
  rw [seq.dist_succ k]
  exact le_trans ((seq.channel k).eff_support_le _) (min_le_right _ _)

/-- Effective support is non-increasing along the whole sequence. -/
theorem eff_support_antitone (seq : SelfImprovementSeq) {m n : ℕ} (h : m ≤ n) :
    (seq.model n).dist.eff_support ≤ (seq.model m).dist.eff_support := by
  induction n with
  | zero =>
    have hm : m = 0 := Nat.le_zero.mp h
    rw [hm]
  | succ p ih =>
    rcases Nat.lt_or_ge m (p + 1) with hlt | hge
    · exact le_trans (eff_support_contraction seq p) (ih (Nat.lt_succ_iff.mp hlt))
    · have hm : m = p + 1 := le_antisymm h hge
      rw [hm]

/-- **Corollary (PROVEN).** If the target requires a larger effective
    support than the initial model has, no autonomous iterate reaches it:
    self-training contracts, so the gap never closes. -/
theorem collapse_prevents_agi (seq : SelfImprovementSeq) (gt : GroundTruth)
    (h_agi_needs_support : (seq.model 0).dist.eff_support < gt.dist.eff_support) :
    ∀ k, (seq.model k).dist.eff_support < gt.dist.eff_support := by
  intro k
  exact lt_of_le_of_lt (eff_support_antitone seq (Nat.zero_le k)) h_agi_needs_support

/-! ### Filtering, rewards, verifiers: the grounding requirement -/

/-- A channel that may consult an external signal (a reward model, a
    filter, a verifier, an environment). The bound is the paper's
    inequality I(p^R; Θ) ≤ I(p; Θ) + I(R; Θ). -/
structure GroundedChannel where
  /-- The induced map on distributions. -/
  apply : SeqDist → SeqDist
  /-- The external signal consulted. -/
  signal : ExternalSignal
  /-- Information after filtering is bounded by information before plus
      the information carried by the signal. -/
  bound : ∀ d : SeqDist, (apply d).mi_true ≤ d.mi_true + signal.mi_true

/-- **Any information gain requires a grounded signal (PROVEN).**

    If a mechanism raises mutual information with ground truth, its signal
    must carry positive information about ground truth. White noise
    (`mi_true = 0`) therefore cannot do it, and neither can any purely
    internal rearrangement. Human design is the dominant special case of
    such a signal, not a separate mechanism. -/
theorem gain_requires_grounded_signal (gc : GroundedChannel) (d : SeqDist)
    (h_gain : d.mi_true < (gc.apply d).mi_true) : gc.signal.Grounded := by
  have hb := gc.bound d
  unfold ExternalSignal.Grounded
  linarith

/-- **Contrapositive at the loop level (PROVEN).** An ungrounded training
    channel cannot produce an information gain at any step. -/
theorem no_gain_without_grounding (ch : TrainingChannel) (d : SeqDist) :
    ¬ (d.mi_true < (ch.apply d).mi_true) :=
  not_lt.mpr (ch.dpi d)

end Impossibility
