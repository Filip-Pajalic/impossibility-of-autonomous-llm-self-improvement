# Verification Plan

This document tracks the work needed to turn the manuscript into a defensible formal argument. The goal is not to preserve every current claim; it is to make each claim precise enough that it can either be proved, weakened, or removed.

## Acceptance Standard

A claim is considered verified only when one of the following is true:

- It is proved in Lean without `sorry`, placeholder `True`, or an axiom introduced only for this project.
- It is stated as an explicit assumption and the paper's conclusion is phrased conditionally on that assumption.
- It is marked as empirical evidence rather than a theorem, with reproducible source data or a clearly cited external result.

## Priority 1: Formal Core

1. **Definitions**
   - Replace abstract fields such as `SeqDist.entropy` and `SeqDist.mi_true` with definitions grounded in existing probability or information-theory libraries where feasible.
   - Define the autonomous loop as a stochastic kernel or Markov process, not only as a sequence of abstract models.
   - Make "human influence" a real predicate over information sources, reward functions, filters, and tools instead of `False`.
   - Audit the AGI definition for nontriviality: specify `D_f`, resource bounds, and representation assumptions so the target is not impossible for every finite physical system by definition.

2. **Information Ceiling**
   - Formalize the Markov chain assumptions required for the data processing inequality.
   - Replace `data_processing_inequality` with a library theorem or a local proof over the chosen probability model.
   - Prove `info_ceiling` from those assumptions.

3. **Main Theorem**
   - Refactor `ImpossibilityBarriers` so every field is a proposition with content, not `True`.
   - Prove the main theorem from the information-ceiling barrier first.
   - State clearly that the theorem excludes the case where the initial model already satisfies the AGI criterion.

## Priority 2: Mathematical Barriers

4. **Distributional Collapse**
   - Specify the sampling regime, empirical distribution, training objective, and convergence assumptions.
   - Prove support contraction under finite self-sampling when no smoothing or external filtering is used.
   - Treat entropy contraction carefully; it may need additional assumptions and should not be stated unconditionally.

5. **SGD Fixed Point**
   - Formalize the self-distillation objective as KL minimization.
   - Prove that the teacher distribution is a minimizer of the population objective.
   - Separate the population result from claims about finite-sample SGD dynamics.

6. **Error Divergence**
   - Prove the recurrence theorem under explicit lower-bound and vanishing-improvement assumptions.
   - Check whether the current recurrence actually implies unbounded divergence or only eventual monotone degradation.

7. **Context and Training-Time Claims**
   - Keep these as resource-bound lemmas unless a stronger theorem can be stated.
   - Define parameter representation size, context capacity, and reasoning overhead precisely.
   - Avoid claiming "unlimited context" impossibility unless the scaling relation is formalized.

## Priority 3: Claims to Weaken or Isolate

8. **Gödel and Verification**
   - Keep the Rice's theorem component as the formal core.
   - State Gödel components as background or conditional assumptions until they are imported from a compatible formalization.
   - Remove or isolate the human-brain quantum asymmetry from the main proof unless it is made explicitly philosophical/empirical rather than formal.

9. **Pattern Completion**
   - Replace the placeholder Kolmogorov complexity definition.
   - Separate finite-context transformer limitations from claims about all stochastic autoregressive systems.
   - Avoid relying on "pattern completion" as an undefined technical category.

10. **Complexity Barrier**
    - State the P != NP dependency conditionally.
    - Do not present current LLM failures as evidence for P != NP in the formal proof.
    - If neural-network training NP-hardness is used, cite and formalize the exact problem variant.

## Priority 4: Empirical Evidence

11. **Evidence Audit**
    - Verify every bibliography entry, arXiv ID, DOI, venue, and year.
    - Classify evidence as peer-reviewed, preprint, benchmark, or speculative.
    - Do not use empirical evidence as a substitute for a theorem statement.

12. **Reproducibility**
    - Add a TeX environment definition or package list.
    - Regenerate the compiled PDF whenever the manuscript source changes, and verify that the PDF title/abstract match the proof-program status in the source.
    - Add CI jobs for `lake build` and LaTeX compilation.
    - Add a check that fails if `sorry`, placeholder `True`, or project-local proof axioms remain in theorem files unless explicitly allowlisted.

## Suggested Milestones

1. **M1: Honest Build Artifact**
   - README and paper state the work-in-progress status.
   - `lake build` passes.
   - LaTeX build instructions are reproducible.

2. **M2: Conditional Core Theorem**
   - Main theorem is proved in Lean from an explicit information-ceiling assumption.
   - All assumptions are named and documented.

3. **M3: Information-Theoretic Proof**
   - Data processing assumptions are formalized.
   - `info_ceiling` has no `sorry`.

4. **M4: Collapse and Fixed-Point Results**
   - Distributional collapse and SGD fixed-point claims are either proved under precise assumptions or weakened.

5. **M5: Evidence and Scope Cleanup**
   - Speculative or nonessential claims are moved out of the main proof path.
   - The manuscript distinguishes theorem, assumption, conjecture, and empirical corroboration consistently.
