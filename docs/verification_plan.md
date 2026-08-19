# Verification Plan

This document tracks the work needed to turn the manuscript into a defensible formal argument. The goal is not to preserve every current claim; it is to make each claim precise enough that it can either be proved, weakened, or removed.

## Status as of v6 (2026-08-19)

The Claude Fable 5 review (issue #6) is addressed in this revision. What changed:

- **Blocking item resolved.** The AGI definition is repaired. Proposition 1.10 of the manuscript now *proves* that the unrestricted criterion is unsatisfiable by diagonalization (upgrading the v4 worry to a fact), Definition 1.12 is relativized to a fixed, model-independent task family with resource bounds, and Proposition 1.13 proves the relativized target is occupiable. Remaining: extend nontriviality to infinite families where a lookup table is unavailable.
- **The conditional core is machine-checked.** `lake build` passes with **no `sorry` anywhere in the project**. `Impossibility/Audit.lean` prints the axiom dependencies: the information ceiling, the accuracy link, the collapse results, the error results, `barriers_hold`, and the main theorem depend only on `propext`, `Classical.choice`, and `Quot.sound` — no project-local axioms, no `sorryAx`.
- **`barriers_hold` is no longer refutable.** `SelfImprovementSeq` now carries a `SelfDistillationChannel` per step, so the distribution at step k+1 is determined by the one at step k. The barriers are derived from the dynamics rather than asserted.
- **The Bayesian joint is defined** (Definition 2.1 of the manuscript), the DPI strictness claim is withdrawn, and a Fano-type lemma converts the information ceiling into an accuracy ceiling.
- **Support contraction is stated over ε-effective support**, with a total-variation transfer lemma; the softmax objection no longer applies.
- **Error divergence is demoted to non-improvement** as the universal claim, with divergence confined to the replacement regime and the accumulation regime treated explicitly (both formalized).
- **The context-window results are rescoped** to in-context self-modification, and the parameter-grows-with-context premise is withdrawn.
- **"Human influence" is reformulated as "external grounding"**, with human design as the dominant special case; the deduction and embodiment boundary cases are conceded in the manuscript rather than defined away.
- **Contentless placeholders are gone.** The two Gödel axioms whose content was `True`, the tautological `data_processing_inequality` axiom, `P_ne_NP : True`, the `True`-valued barrier fields, and the Kolmogorov placeholder that made its own theorem false have all been replaced by proven statements or by named axioms that assert something.
- **Evidence base extended in both directions** (manuscript Section 12): 23 new verified references, including results in tension with the claims (accumulation, verification-guided training, DGM, SEAL, Absolute Zero, R-Zero, Self-Harness, ProRL, and 2026 self-correction work), plus pre-registered falsification criteria.

What is still open is listed below, with resolved items marked.

## Acceptance Standard

A claim is considered verified only when one of the following is true:

- It is proved in Lean without `sorry`, placeholder `True`, or an axiom introduced only for this project.
- It is stated as an explicit assumption and the paper's conclusion is phrased conditionally on that assumption.
- It is marked as empirical evidence rather than a theorem, with reproducible source data or a clearly cited external result.

## Priority 1: Formal Core

1. **Definitions**
   - Replace abstract fields such as `SeqDist.entropy` and `SeqDist.mi_true` with definitions grounded in existing probability or information-theory libraries where feasible. **Still open** — these remain real-valued fields; the manuscript now specifies the joint they are computed in, but Lean does not construct it.
   - ~~Define the autonomous loop as a stochastic kernel or Markov process.~~ **Done (v6):** `TrainingChannel` / `SelfDistillationChannel`, with the step dynamics as a field of `SelfImprovementSeq`. **Still open:** the channel acts on abstract `SeqDist` records rather than on measures.
   - ~~Make "human influence" a real predicate instead of `False`.~~ **Done (v6).** Steps carry `ExternalSignal`s; grounding is positive mutual information with ground truth; human influence is grounding of human origin; `autonomous_no_human_influence` is now a theorem, not an axiom.
   - ~~Reformulate "human influence" as "external grounding".~~ **Done (v6):** Definition 1.6 (grounding) and Definition 1.7 (human influence as grounding of human origin), with Section 11.5 conceding the deduction and embodiment boundary cases. **Still open:** the quantitative target — capability gain per bit of grounded signal — is stated as a conjecture (Section 11.5), not proved.
   - ~~**Blocking:** repair the AGI definition.~~ **Done (v6).** Proposition 1.10 proves the unrestricted criterion unsatisfiable; Definition 1.12 is relativized to a fixed family with resource bounds; Proposition 1.13 proves nontriviality for finite families. **Still open:** nontriviality for infinite families under resource bounds, where the lookup-table witness is unavailable.
   - ~~Constrain the Lean dynamics.~~ **Done (v6).** Each step carries a `SelfDistillationChannel` and `barriers_hold` is proved from it.

2. **Information Ceiling**
   - Formalize the Markov chain assumptions required for the data processing inequality. **Partially done (v6):** the chain is specified in the manuscript (Definition 2.1) and the conditional-independence step is stated explicitly; it is not yet constructed as a measure-theoretic object in Lean.
   - ~~Define the Bayesian joint.~~ **Done (v6)** in the manuscript (Definition 2.1). **Still open** in Lean: the joint is described, not constructed.
   - ~~Drop or prove the strictness claim.~~ **Dropped (v6)**, with the reason recorded in Remark 2.3.
   - ~~Add a Fano-type link lemma.~~ **Done (v6):** Lemma 2.5 and Corollary 2.6 in the manuscript; `accuracy_ceiling_of_info_ceiling` in Lean.
   - ~~Replace the tautological `data_processing_inequality` axiom.~~ **Done (v6):** it is gone; DPI is carried as the `dpi` field of `TrainingChannel`. **Still open:** derive that field from a measure-theoretic model of sampling and training rather than assuming it.
   - ~~Prove `info_ceiling`.~~ **Done (v6)**, by induction over the channel steps.

3. **Main Theorem**
   - ~~Refactor `ImpossibilityBarriers` so every field has content.~~ **Done (v6).** The pattern-completion and complexity barriers were removed from the structure rather than represented by `True`; both are tracked below.
   - ~~Prove the main theorem from the information-ceiling barrier.~~ **Done (v6).**
   - ~~State the excluded degenerate case.~~ **Done (v6):** it is the hypothesis `h_not_already_agi`.

## Priority 2: Mathematical Barriers

4. **Distributional Collapse**
   - ~~Restate support contraction over ε-effective support.~~ **Done (v6):** Definition 3.1, Lemma 3.2 (total-variation transfer), Theorem 3.3.
   - ~~Prove effective-support contraction.~~ **Done (v6)** from the sample-budget assumption, in both the manuscript and Lean.
   - ~~Treat entropy contraction carefully.~~ **Done (v6):** it is stated as a consequence of the finite-sample regime, not unconditionally.
   - **Still open:** derive the `eff_support_le` and `entropy_contract` channel fields from a sampling model instead of assuming them, and quantify the contraction rate as a function of the sample budget.

5. **SGD Fixed Point**
   - ~~Prove that the teacher distribution is a minimizer of the population objective.~~ **Done (v6):** `teacher_is_minimizer`, for any non-negative divergence vanishing on the diagonal.
   - ~~Separate the population result from finite-sample SGD dynamics.~~ **Done (v6):** the population result is proved; Fisher-rank contraction is now carried as an explicit hypothesis instead of a `sorry`.
   - **Still open:** instantiate the divergence as KL over a constructed probability model rather than an abstract functional.

6. **Error Divergence**
   - ~~Prove the recurrence theorem under explicit assumptions.~~ **Done (v6):** `error_nondecreasing`, `error_grows_linearly`, `error_diverges`, all proved.
   - ~~Check whether the recurrence implies divergence or only monotone degradation.~~ **Done (v6):** non-improvement is universal; divergence needs a positive degradation floor.
   - ~~Reconcile with the SGD fixed point.~~ **Done (v6):** `degradation_pos` weakened to `degradation_nonneg`; `stagnation_at_fixed_point` proved; Remark 9.3 states the resolution (stagnation with drift).
   - ~~Address the data-accumulation regime.~~ **Done (v6):** Section 9.1 of the manuscript, and `AccumulationRegime` / `accumulation_no_divergence` in Lean.
   - **Still open:** characterize precisely how much memorized training data must survive in `D_k^self` before the loop counts as accumulation rather than replacement.

7. **Context and Training-Time Claims**
   - ~~Restate the context-window theorems as bounds on in-context self-modification.~~ **Done (v6):** the section is retitled and opens with a scope remark.
   - ~~Drop the parameter-grows-with-context premise.~~ **Done (v6):** withdrawn in Remark 8.5; the surviving claim is the compute form (quadratic attention), stated as architecture-specific.
   - ~~Prove the cost-per-improvement divergence.~~ **Done (v6):** `training_time_divergence` is proved (it was `sorry` in v5).
   - **Still open:** the section is a cost argument, not an impossibility result, and should probably be demoted to an appendix.

## Priority 3: Claims to Weaken or Isolate

8. **Gödel and Verification**
   - ~~Keep the Rice's theorem component as the formal core.~~ **Done** (unchanged since v4; proved from Mathlib).
   - ~~State Gödel components as background or conditional assumptions.~~ **Improved (v6):** Gödel I is replaced by a *proved* computability form (`sound_prover_incomplete`: a sound computable prover for an undecidable property is incomplete). Gödel II remains a bridge axiom, but now over a `FormalSystem` interface and with real content — it asserts that the consistency sentence is unprovable, where v5 asserted `True`.
   - ~~Correct the `verification_regress` docstring.~~ **Done (v6):** the unused chain argument is removed and the "by induction" claim is corrected to what the proof does — one application of Rice, uniform over levels.
   - **Still open:** upgrade to Lean v4.28+ and import FormalizedFormalLogic to discharge the Gödel II axiom.
   - The human-brain quantum asymmetry remains explicitly empirical/philosophical background, outside the proof path.

9. **Pattern Completion**
   - ~~Replace the placeholder Kolmogorov complexity definition.~~ **Partially done (v6):** the placeholder `def` returning 0 (which made the barrier statement false and left it `sorry`-ed) is replaced by an abstract constant plus a named unboundedness axiom. **Still open:** a real formalization; until then this barrier is not in the Lean barrier structure.
   - ~~Separate finite-context transformer limitations from claims about all stochastic autoregressive systems.~~ **Partially done (v6):** `transformer_configurations_finite` proves the |V|^C configuration bound and its docstring restricts the claim to the fixed-context, fixed-precision setting.
   - **Still open:** avoid relying on "pattern completion" as an undefined technical category.

10. **Complexity Barrier**
    - ~~State the P != NP dependency conditionally.~~ **Done (v6):** `axiom P_ne_NP : True` is deleted; the barrier is expressed as a `SearchVerificationGap` structure whose fields are the claim.
    - ~~Do not present current LLM failures as evidence for P != NP.~~ **Done:** stated in the manuscript (Remark 7.2) and in the Lean file's closing note.
    - **Still open:** cite and formalize the exact NP-hardness variant for the training problem.

## Priority 4: Empirical Evidence

11. **Evidence Audit**
    - ~~Verify every bibliography entry, arXiv ID, DOI, venue, and year.~~ **Done for the v6 additions:** all 23 new entries were checked against arXiv listings (title, author list, submission date, venue) before citation. **Still open:** re-verify the pre-v5 entries on the same standard.
    - ~~Classify evidence.~~ **Done (v6):** Section 12 classifies each result as theoretical, benchmark, or mechanistic, and time-indexes it by architecture generation.
    - ~~Do not use empirical evidence as a substitute for a theorem.~~ **Done (v6):** Section 12.2 lists results in tension with the claims, 12.3 audits the grounding source of every strong self-improvement system, and 12.5 states pre-registered falsification criteria.
    - **Still open:** the 2023-era props (self-correction failure, reversal curse, compositional collapse) are attenuated in verifier-trained models; Section 12.4 time-indexes them, but they should eventually be replaced with measurements on current architectures.

12. **Reproducibility**
    - Add a TeX environment definition or package list.
    - Regenerate the compiled PDF whenever the manuscript source changes, and verify that the PDF title/abstract match the proof-program status in the source.
    - Add CI jobs for `lake build` and LaTeX compilation.
    - ~~Add a check for `sorry`, placeholder `True`, or project-local axioms.~~ **Partially done (v6):** `Impossibility/Audit.lean` prints the axiom dependencies of every load-bearing result on each build. **Still open:** wire it into CI so a regression fails the build rather than printing a note.

## Suggested Milestones

1. **M1: Honest Build Artifact**
   - README and paper state the work-in-progress status.
   - `lake build` passes.
   - LaTeX build instructions are reproducible.

2. **M2: Conditional Core Theorem** — **reached in v6.**
   - Main theorem is proved in Lean from the channel model of the loop.
   - All assumptions are named and documented; the axiom audit is automated in `Impossibility/Audit.lean`.

3. **M3: Information-Theoretic Proof** — **partially reached in v6.**
   - `info_ceiling` has no `sorry`, and the accuracy link is proved.
   - Still open: the data-processing property is a channel field rather than a theorem over a constructed probability model.

4. **M4: Collapse and Fixed-Point Results** — **reached in v6** (weakened and proved under stated assumptions; the assumptions themselves are still channel fields).

5. **M5: Evidence and Scope Cleanup**
   - Speculative or nonessential claims are moved out of the main proof path.
   - The manuscript distinguishes theorem, assumption, conjecture, and empirical corroboration consistently.
