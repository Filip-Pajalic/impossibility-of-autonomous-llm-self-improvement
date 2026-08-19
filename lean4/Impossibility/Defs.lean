/-
  Core definitions corresponding to Section 1 of the paper.

  These define the mathematical objects: vocabulary, model, training
  channels, autonomous self-improvement, external grounding, and AGI.

  v6 CHANGES (Claude Fable 5 review, issue #6):
  * `SeqDist.support_size` is now `eff_support`: the size of the
    ε-effective support, not the literal support. A softmax layer gives
    every sequence strictly positive probability, so literal support
    inclusion is trivially an equality and carries no content
    (objection 3).
  * Self-improvement steps now carry a `SelfDistillationChannel`, so the
    distribution at step k+1 is *determined* by the distribution at step
    k. Previously `SelfImprovementSeq` constrained nothing across steps,
    which made `barriers_hold` refutable rather than merely unproven
    (objection 6).
  * `has_human_influence` is no longer `False`. Steps carry a list of
    external signals; grounding is "positive mutual information with
    ground truth" and human design is a flag on top of that. The former
    axiom `autonomous_no_human_influence` is now a theorem (objection 7).
-/
import Mathlib.MeasureTheory.Measure.MeasureSpace
import Mathlib.Probability.ProbabilityMassFunction.Basic
import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Order.Filter.Basic

open MeasureTheory ENNReal

namespace Impossibility

/-! ### Vocabulary and token space -/

/-- A finite vocabulary of tokens. -/
structure Vocabulary where
  size : ℕ
  size_pos : 0 < size

/-- A sequence of tokens (finite prefix). -/
abbrev TokenSeq (V : Vocabulary) := Fin V.size → ℕ

/-! ### Probability distributions over sequences -/

/-- Abstract type for a probability distribution over token sequences.
    In the paper this is p_θ(x_t | x_{<t}) factorized autoregressively.

    `mi_true` is mutual information with ground truth *in the Bayesian
    joint of Section 2.1 of the paper*: ground truth is a random variable
    Θ drawn from a prior over hypotheses, not a fixed distribution. With a
    fixed ground truth this quantity would be identically 0. -/
structure SeqDist where
  /-- Shannon entropy H(p) -/
  entropy : ℝ
  entropy_nonneg : 0 ≤ entropy
  /-- Mutual information with ground truth I(p; Θ) in the Bayesian joint -/
  mi_true : ℝ
  mi_true_nonneg : 0 ≤ mi_true
  /-- Size of the ε-effective support: the cardinality of the smallest set
      carrying probability mass ≥ 1 − ε. NOT the literal support, which is
      everything for a softmax model. -/
  eff_support : ℕ

/-! ### Model and training (Definitions 1.3–1.5) -/

/-- An autoregressive language model parameterized by θ ∈ ℝ^p.
    We abstract away the transformer architecture and focus on the
    induced distribution. -/
structure LLModel where
  /-- Number of parameters -/
  num_params : ℕ
  num_params_pos : 0 < num_params
  /-- Context window size -/
  context_window : ℕ
  context_window_pos : 0 < context_window
  /-- The probability distribution induced by the model -/
  dist : SeqDist
  /-- Fisher information matrix rank (effective dimensionality) -/
  fisher_rank : ℕ

/-! ### Training channels

  A training channel is the stochastic kernel "sample from the input
  distribution, fit a new model to those samples". Making the loop a
  kernel rather than an unconstrained sequence is Priority-1 item 1 of
  `docs/verification_plan.md`. -/

/-- A training channel: the map on distributions induced by generating
    data from the input distribution and fitting a model to it. -/
structure TrainingChannel where
  /-- The induced map on distributions. -/
  apply : SeqDist → SeqDist
  /-- **Bridge assumption (data processing inequality).** The output of the
      channel is a function of samples from the input distribution, so it
      carries no more information about ground truth than the input does.
      This is the one information-theoretic assumption the conditional
      core rests on; see `docs/verification_plan.md` Priority 1 item 2. -/
  dpi : ∀ d : SeqDist, (apply d).mi_true ≤ d.mi_true

/-- A self-distillation channel: a training channel realized by drawing
    `num_samples` samples with no filtering, smoothing, or external data.

    The two extra fields are the *finite-sample assumptions* of Theorem
    3.1 in the paper, stated over the ε-effective support so that they are
    not vacuous for softmax models. -/
structure SelfDistillationChannel extends TrainingChannel where
  /-- Number of self-generated samples used at this step. -/
  num_samples : ℕ
  num_samples_pos : 0 < num_samples
  /-- Effective support of the fitted model is capped by the sample budget
      and does not exceed the teacher's effective support. -/
  eff_support_le : ∀ d : SeqDist,
    (apply d).eff_support ≤ min d.eff_support num_samples
  /-- Unfiltered, unsmoothed empirical fitting does not raise entropy. -/
  entropy_contract : ∀ d : SeqDist, (apply d).entropy ≤ d.entropy

/-! ### External grounding and human influence (Definitions 1.6–1.7)

  The paper's v6 framing: what every formal argument actually needs is
  *external* signal, with human design as the dominant special case
  (issue #6, objection 7). -/

/-- A signal fed into a self-improvement step from outside the model. -/
structure ExternalSignal where
  /-- Mutual information between the signal and ground truth. -/
  mi_true : ℝ
  mi_true_nonneg : 0 ≤ mi_true
  /-- Whether the signal was designed or produced by humans (reward
      functions, filters, verifiers, tools, curricula). -/
  human_designed : Bool

/-- A signal is *grounded* when it carries positive information about
    ground truth. White noise is a signal with `mi_true = 0`: independent
    of the model's errors, but not grounded (Section 11.8). -/
def ExternalSignal.Grounded (s : ExternalSignal) : Prop := 0 < s.mi_true

/-! ### Autonomous self-improvement (Definition 1.9) -/

/-- A self-improvement step: θ_{k+1} = A(θ_k, D_k^self), where D_k^self is
    sampled from p_{θ_k}. The channel field records that the new
    distribution is *determined by* the old one plus the training map. -/
structure SelfImprovementStep where
  /-- Model before the step -/
  model_before : LLModel
  /-- Model after the step -/
  model_after : LLModel
  /-- The self-distillation channel applied at this step -/
  channel : SelfDistillationChannel
  /-- Signals available to the step (empty, or ungrounded, when autonomous) -/
  signals : List ExternalSignal
  /-- The dynamics: the new distribution is the channel applied to the old -/
  step_dist : model_after.dist = channel.apply model_before.dist

/-- A step is *autonomous* when no signal it uses is grounded. -/
def SelfImprovementStep.Autonomous (s : SelfImprovementStep) : Prop :=
  ∀ sig ∈ s.signals, ¬ sig.Grounded

/-- A step involves *human influence* when it uses a grounded signal of
    human origin: curated data, reward functions, filters, verifiers,
    tools, or human-designed schedules. -/
def SelfImprovementStep.HasHumanInfluence (s : SelfImprovementStep) : Prop :=
  ∃ sig ∈ s.signals, sig.Grounded ∧ sig.human_designed = true

/-- Human influence is a special case of external grounding. -/
theorem human_influence_is_grounded (s : SelfImprovementStep)
    (h : s.HasHumanInfluence) : ∃ sig ∈ s.signals, sig.Grounded := by
  obtain ⟨sig, hmem, hg, _⟩ := h
  exact ⟨sig, hmem, hg⟩

/-- **Formerly an axiom.** In the autonomous setting no step has human
    influence — now a one-line consequence of the definitions rather than
    a postulate. -/
theorem autonomous_no_human_influence (s : SelfImprovementStep)
    (h : s.Autonomous) : ¬ s.HasHumanInfluence := by
  intro hHI
  obtain ⟨sig, hmem, hg⟩ := human_influence_is_grounded s hHI
  exact h sig hmem hg

/-- An autonomous self-improvement sequence {θ_k}_{k=0}^∞. Every step is
    generated by a self-distillation channel, so the distribution at step
    k + 1 is determined by the distribution at step k. -/
structure SelfImprovementSeq where
  /-- The model at step k -/
  model : ℕ → LLModel
  /-- The step taken at index k -/
  step : ℕ → SelfImprovementStep
  /-- Steps are chained to the model sequence -/
  step_before : ∀ k, (step k).model_before = model k
  step_after : ∀ k, (step k).model_after = model (k + 1)
  /-- No step uses a grounded external signal -/
  autonomous : ∀ k, (step k).Autonomous

namespace SelfImprovementSeq

variable (seq : SelfImprovementSeq)

/-- The channel applied at step k. -/
def channel (k : ℕ) : SelfDistillationChannel := (seq.step k).channel

/-- **The loop dynamics.** The distribution at step k + 1 is the channel
    of step k applied to the distribution at step k. -/
theorem dist_succ (k : ℕ) :
    (seq.model (k + 1)).dist = (seq.channel k).apply (seq.model k).dist := by
  have hb := seq.step_before k
  have ha := seq.step_after k
  have h := (seq.step k).step_dist
  rw [hb] at h
  rw [ha] at h
  exact h

/-- No step of an autonomous sequence involves human influence. -/
theorem no_human_influence (k : ℕ) : ¬ (seq.step k).HasHumanInfluence :=
  autonomous_no_human_influence _ (seq.autonomous k)

end SelfImprovementSeq

/-! ### AGI (Definition 1.12)

  The paper's v6 AGI criterion is relativized to a fixed, model-independent
  task family with resource bounds. The unrestricted "matches every
  computable function" criterion is unsatisfiable by diagonalization
  (Proposition 1.10 of the paper), which would make the main theorem
  vacuously true of every sequence, human-guided ones included. -/

/-- The ground truth distribution over the fixed task family. -/
structure GroundTruth where
  dist : SeqDist
  /-- Ground truth has maximal information about itself -/
  self_info : dist.mi_true = dist.entropy

/-- AGI requirement, relativized to the fixed family carried by `gt`:
    the model's information about ground truth is within ε of complete. -/
def achieves_AGI (m : LLModel) (gt : GroundTruth) (ε : ℝ) : Prop :=
  ε > 0 → m.dist.mi_true ≥ gt.dist.entropy - ε

/-- The sequence converges to AGI if for all ε > 0, eventually
    the model achieves AGI. -/
def converges_to_AGI (seq : SelfImprovementSeq) (gt : GroundTruth) : Prop :=
  ∀ ε > 0, ∃ K, ∀ k, k ≥ K → achieves_AGI (seq.model k) gt ε

/-- **Nontriviality of the relativized target.** The AGI criterion is
    satisfiable in principle: a model whose distribution already carries
    the ground-truth information meets it for every ε > 0. The main
    theorem is therefore about *reachability by an autonomous loop*, not
    about an empty target. -/
theorem agi_target_nonempty (gt : GroundTruth) (m : LLModel)
    (h : m.dist.mi_true = gt.dist.entropy) : ∀ ε, achieves_AGI m gt ε := by
  intro ε hε
  rw [h]
  linarith

end Impossibility
