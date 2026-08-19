/-
  Theorem 9.1: Error Dynamics Without External Correction

  FORMALIZATION STATUS (v6) — this file was restructured in response to
  issue #6, objection 4:
  ✓ PROVEN: `error_nondecreasing` — the defensible *universal* claim:
    without an independent corrector the error never improves.
  ✓ PROVEN: `error_grows_linearly` and `error_diverges` — divergence, but
    only in the replacement regime and only under an explicit positive
    lower bound on undetected degradation.
  ✓ PROVEN: `stagnation_at_fixed_point` — at the SGD fixed point of
    Theorem 5.1 the error is constant. This is why `degradation_pos` was
    weakened to `degradation_nonneg`: the old structure assumed away the
    fixed-point regime, putting Theorems 5.1 and 9.1 in contradiction.
  ✓ PROVEN: `accumulation_no_divergence` — in the data-accumulation regime
    (Gerstgrasser et al., arXiv:2404.01413) the error is bounded, so
    divergence is regime-specific rather than universal.

  Paper reference: Section 9
-/
import Impossibility.Defs

namespace Impossibility

/-! ### Error model

  ε_{k+1} = ε_k − Δ_k + δ_k + Σ_{j=0}^{k} α_{k,j} · δ_j

  - Δ_k ≥ 0: intended improvement
  - δ_k ≥ 0: undetected degradation
  - α_{k,j} ≥ 0: error propagation through self-generated data
-/

/-- The error recurrence of the paper's Theorem 9.1. -/
structure ErrorModel where
  /-- Error at step k -/
  error : ℕ → ℝ
  /-- Intended improvement at step k -/
  improvement : ℕ → ℝ
  improvement_nonneg : ∀ k, improvement k ≥ 0
  /-- Undetected degradation at step k. Non-negative, NOT assumed positive:
      strict positivity is the hypothesis of the divergence regime. -/
  degradation : ℕ → ℝ
  degradation_nonneg : ∀ k, degradation k ≥ 0
  /-- Error propagation coefficients -/
  propagation : ℕ → ℕ → ℝ
  propagation_nonneg : ∀ k j, propagation k j ≥ 0
  /-- Recurrence relation -/
  recurrence : ∀ k, error (k + 1) =
    error k - improvement k + degradation k +
    Finset.sum (Finset.range (k + 1)) (fun j => propagation k j * degradation j)

namespace ErrorModel

variable (em : ErrorModel)

/-- The propagation term is non-negative. -/
theorem propagation_sum_nonneg (k : ℕ) :
    0 ≤ Finset.sum (Finset.range (k + 1)) (fun j => em.propagation k j * em.degradation j) :=
  Finset.sum_nonneg fun j _ => mul_nonneg (em.propagation_nonneg k j) (em.degradation_nonneg j)

/-- **The universal claim (PROVEN): no improvement.**

    Whenever undetected degradation is at least as large as the intended
    improvement — the situation the paper argues for, since the corrector
    and the corrupted system are the same stochastic process — the error
    is non-decreasing. This, not divergence, is what the main theorem
    needs: AGI requires the error to fall. -/
theorem error_nondecreasing (h : ∀ k, em.improvement k ≤ em.degradation k) :
    ∀ k, em.error k ≤ em.error (k + 1) := by
  intro k
  have hs := em.propagation_sum_nonneg k
  have hk := h k
  rw [em.recurrence k]
  linarith

/-- **Stagnation at the SGD fixed point (PROVEN).**

    At an exact fixed point of the self-training map there is nothing to
    gain and nothing undetected to lose: the error is constant. Theorem
    5.1 and Theorem 9.1 therefore describe different regimes, and the
    universal reading of the divergence claim is unavailable. -/
theorem stagnation_at_fixed_point
    (h_impr : ∀ k, em.improvement k = 0) (h_deg : ∀ k, em.degradation k = 0) :
    ∀ k, em.error (k + 1) = em.error k := by
  intro k
  have hsum : Finset.sum (Finset.range (k + 1))
      (fun j => em.propagation k j * em.degradation j) = 0 := by
    refine Finset.sum_eq_zero ?_
    intro j _
    rw [h_deg j, mul_zero]
  rw [em.recurrence k, h_impr k, h_deg k, hsum]
  ring

/-- **Linear growth in the replacement regime (PROVEN).**

    If undetected degradation stays above δ > 0 while intended improvement
    has fallen below δ/2, the error grows at least linearly from that
    point on. -/
theorem error_grows_linearly (δ : ℝ) (_hδ : 0 < δ)
    (h_deg : ∀ k, em.degradation k ≥ δ) (K : ℕ)
    (h_small : ∀ k, k ≥ K → em.improvement k ≤ δ / 2) :
    ∀ n : ℕ, em.error (K + n) ≥ em.error K + n * (δ / 2) := by
  intro n
  induction n with
  | zero => simp
  | succ m ih =>
    have hK : K + m ≥ K := Nat.le_add_right K m
    have hs := em.propagation_sum_nonneg (K + m)
    have h1 := h_small (K + m) hK
    have h2 := h_deg (K + m)
    have hrec := em.recurrence (K + m)
    have hstep : em.error (K + m + 1) ≥ em.error (K + m) + δ / 2 := by
      rw [hrec]; linarith
    have hcast : ((m : ℝ) + 1) * (δ / 2) = (m : ℝ) * (δ / 2) + δ / 2 := by ring
    have : em.error (K + (m + 1)) ≥ em.error K + ((m : ℝ) + 1) * (δ / 2) := by
      have heq : K + (m + 1) = K + m + 1 := by omega
      rw [heq, hcast]
      linarith
    simpa using this

/-- **Divergence in the replacement regime (PROVEN).**

    Under a positive floor on undetected degradation and vanishing
    intended improvement, the error exceeds every bound. -/
theorem error_diverges
    (h_improvement_vanishes : ∀ ε > 0, ∃ K, ∀ k, k ≥ K → em.improvement k < ε)
    (h_degradation_lower : ∃ δ_min > 0, ∀ k, em.degradation k ≥ δ_min) :
    ∀ M : ℝ, ∃ K, ∀ k, k ≥ K → em.error k > M := by
  obtain ⟨δ, hδ, h_deg⟩ := h_degradation_lower
  intro M
  obtain ⟨K₀, hK₀⟩ := h_improvement_vanishes (δ / 2) (by linarith)
  have h_small : ∀ k, k ≥ K₀ → em.improvement k ≤ δ / 2 := fun k hk => le_of_lt (hK₀ k hk)
  have hgrow := em.error_grows_linearly δ hδ h_deg K₀ h_small
  obtain ⟨n, hn⟩ := exists_nat_gt ((M - em.error K₀) / (δ / 2))
  refine ⟨K₀ + n, ?_⟩
  intro k hk
  have hkm : ∃ m : ℕ, k = K₀ + m ∧ n ≤ m := by
    refine ⟨k - K₀, ?_, ?_⟩ <;> omega
  obtain ⟨m, hkeq, hnm⟩ := hkm
  have hbound := hgrow m
  have hmn : (n : ℝ) ≤ (m : ℝ) := by exact_mod_cast hnm
  have hhalf : 0 < δ / 2 := by linarith
  have hMn : M - em.error K₀ < (n : ℝ) * (δ / 2) := by
    have := (div_lt_iff₀ hhalf).mp hn
    linarith
  have : em.error K₀ + (m : ℝ) * (δ / 2) > M := by
    have hmono : (n : ℝ) * (δ / 2) ≤ (m : ℝ) * (δ / 2) :=
      mul_le_mul_of_nonneg_right hmn (le_of_lt hhalf)
    linarith
  rw [hkeq]
  linarith

end ErrorModel

/-! ### The accumulation regime

  Gerstgrasser et al. (arXiv:2404.01413) prove that when synthetic data
  *accumulate* alongside the original data instead of replacing it, the
  test error has a finite upper bound independent of the iteration count.
  Definition 1.9 does not by itself exclude this regime: a model that
  memorizes part of its training corpus and samples at low temperature
  partially recreates accumulation while still only ever "sampling from
  p_{θ_k}". -/

/-- A self-training process in the accumulation regime: error stays below
    a fixed bound forever. -/
structure AccumulationRegime where
  error : ℕ → ℝ
  bound : ℝ
  bounded : ∀ k, error k ≤ bound

/-- **Divergence is not universal (PROVEN).** In the accumulation regime
    the error does not exceed every bound, so the divergence conclusion
    cannot be asserted of every autonomous process — only of the
    replacement regime with a positive degradation floor. -/
theorem accumulation_no_divergence (ar : AccumulationRegime) :
    ¬ (∀ M : ℝ, ∃ K, ∀ k, k ≥ K → ar.error k > M) := by
  intro h
  obtain ⟨K, hK⟩ := h ar.bound
  have h1 := hK K le_rfl
  have h2 := ar.bounded K
  linarith

/-- The correction mechanism is the corrupted system. An AI-built
    corrector inherits correlated errors; only a corrector whose errors
    are independent of the model's — and which carries information about
    ground truth — breaks the cycle (Section 11.7 of the paper). This is
    recorded as a modelling remark, not a theorem. -/
theorem correlated_corrector_insufficient
    (sig : ExternalSignal) (h : ¬ sig.Grounded) : sig.mi_true = 0 := by
  unfold ExternalSignal.Grounded at h
  have := sig.mi_true_nonneg
  linarith [not_lt.mp h]

end Impossibility
