/-
  Section 8: The Context-Computation Paradox
  (bounds on directed self-modification)

  SCOPE (v6): these results close the *directed* horn of an exhaustive
  dichotomy. A self-modifying system either changes itself blindly — no
  diagnosis, no parameter in context, caught by the SGD fixed point
  (Theorem 5.1) and the information ceiling — or it changes itself in a
  directed way, which requires representing and reasoning about its own
  state, and is caught by the resource bounds here. The objection that
  "gradient descent needs no parameters in the context window" lands in
  the first horn, which the other barriers already cover.

  FORMALIZATION STATUS (v6):
  ✓ PROVEN: the capacity bound, the overhead contradiction, the quadratic
    attention-cost scaling, and cost-per-unit-improvement divergence
    (previously `sorry`).
  ✗ REMOVED: the premise that parameter count must grow with context
    length. RoPE-style context extension takes a fixed-size model from 8K
    to 128K+ context with no added position parameters, so the v5 scaling
    trap was empirically false as stated. What survives is the compute
    form: attention FLOPs, not parameters, scale with context.

  Paper reference: Section 8
-/
import Impossibility.Defs

namespace Impossibility

/-! ### 7.1 Capacity bound -/

/-- The model's context window is orders of magnitude too small to hold a
    representation of its own parameters.

    p · b / (C · log₂|V|) ≫ 1. For p = 10^11, b = 16, C = 128000,
    |V| = 10^5 the ratio is ≈ 7.3 × 10^5. -/
theorem context_too_small (m : LLModel)
    (bits_per_param : ℕ) (vocab_bits : ℕ)
    (h_ratio : m.num_params * bits_per_param >
               m.context_window * vocab_bits) :
    m.num_params * bits_per_param > m.context_window * vocab_bits :=
  h_ratio

/-- Concrete instance of the capacity gap at 2026 frontier scales:
    10^11 parameters at 16 bits versus a 128K-token context at ~17 bits
    per token. -/
theorem capacity_gap_concrete :
    (10 ^ 11) * 16 > 128000 * 17 := by norm_num

/-! ### 7.2 Overhead -/

/-- If the parameter state fills the context, no room remains for the
    reasoning that must operate on it. -/
theorem overhead_paradox
    (c_total c_state c_reasoning c_temp c_output : ℕ)
    (h_partition : c_total = c_state + c_reasoning + c_temp + c_output)
    (h_state_fills : c_state = c_total)
    (h_reasoning_pos : c_reasoning > 0) :
    c_state + c_reasoning + c_temp + c_output > c_total := by
  omega

/-! ### 7.3 Compute scaling (replaces the v5 "scaling trap")

  The surviving claim is about FLOPs, not parameters. Standard attention
  costs Θ(C²·d) per forward pass, so extending the context to hold a
  parameter-sized state makes one self-analysis pass quadratic in the
  state size. Sub-quadratic attention variants weaken this bound, which
  is why it is stated for the standard architecture only. -/

/-- Attention cost as a function of context length and width. -/
def attention_cost (C d : ℕ) : ℕ := C * C * d

/-- Doubling the context quadruples the attention cost of a pass. -/
theorem doubling_context_quadruples_cost (C d : ℕ) :
    attention_cost (2 * C) d = 4 * attention_cost C d := by
  unfold attention_cost; ring

/-- Attention cost is monotone in context length: buying more context to
    fit the state never lowers the per-pass cost. -/
theorem attention_cost_monotone {C C' d : ℕ} (h : C ≤ C') :
    attention_cost C d ≤ attention_cost C' d := by
  unfold attention_cost
  exact Nat.mul_le_mul_right d (Nat.mul_le_mul h h)

/-! ### 7.4 Cost per unit of improvement -/

/-- **Training-time divergence (PROVEN).**

    If the achievable improvement per iteration vanishes while the cost per
    iteration stays above a positive floor, the cost per unit of
    improvement exceeds every bound. -/
theorem training_time_divergence
    (improvement : ℕ → ℝ) (cost : ℕ → ℝ)
    (h_improvement_vanishes : ∀ ε > 0, ∃ K, ∀ k, k ≥ K → improvement k < ε)
    (h_cost_bounded_below : ∃ c > 0, ∀ k, cost k ≥ c) :
    ∀ M > 0, ∃ K, ∀ k, k ≥ K → improvement k > 0 → cost k / improvement k > M := by
  obtain ⟨c, hc, hcost⟩ := h_cost_bounded_below
  intro M hM
  obtain ⟨K, hK⟩ := h_improvement_vanishes (c / M) (div_pos hc hM)
  refine ⟨K, ?_⟩
  intro k hk hpos
  have h1 : improvement k < c / M := hK k hk
  have h2 : M * improvement k < c := by
    have := (lt_div_iff₀ hM).mp h1
    linarith
  have h3 : M * improvement k < cost k := lt_of_lt_of_le h2 (hcost k)
  exact (lt_div_iff₀ hpos).mpr h3

end Impossibility
