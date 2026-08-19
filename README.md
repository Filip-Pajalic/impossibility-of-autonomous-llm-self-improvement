# On the Impossibility of Autonomous LLM Self-Improvement to AGI

## Research Manuscript and Formalization Work in Progress

This repository contains a research manuscript and a Lean 4 formalization for the claim that large language models based on stochastic next-token prediction cannot autonomously self-improve to artificial general intelligence in a sealed loop — one with no externally grounded signal.

As of v6 the **conditional core is machine-checked**: sealed loop → information ceiling → accuracy ceiling (Fano) → failure of the AGI criterion, proved in Lean with no `sorry`. What is proved is an implication. The data-processing property of the training loop is carried as an explicit hypothesis on the training channel, not derived from a measure-theoretic model of sampling and training, and that derivation is the main remaining formal gap.

## Current Status

- `lean4/` builds with `lake build` under Lean `v4.16.0`, with **no `sorry` in the project**.
- `lean4/Impossibility/Audit.lean` prints the axiom dependencies of every load-bearing result on each build. The information ceiling, the accuracy link, the collapse results, the error results, `barriers_hold`, and the main theorem depend only on `propext`, `Classical.choice`, and `Quot.sound` — no project-local axioms.
- Three named bridge axioms remain, **none used by the main theorem**: Kolmogorov complexity and its unboundedness, Gödel's second incompleteness theorem over an abstract formal-system interface, and the modeling claim that a finite-precision LLM is a program.
- Two of the eight barriers — pattern completion and computational complexity — are deliberately absent from the Lean barrier structure, because Kolmogorov complexity and P ≠ NP have no Lean 4 formalization and a `True` placeholder would assert nothing.
- `papers/llm_self_improvement_proof.tex` is the manuscript source (35 pages). Building it requires a standard TeX installation; `pdflatex` twice is sufficient.
- A verification roadmap, with resolved items marked, is maintained in `docs/verification_plan.md`.

## Core Claims

1. **Information Ceiling** *(proved in Lean)* — In an explicit Bayesian joint where ground truth is a random variable, a sealed loop's mutual information with ground truth is non-increasing, and a Fano argument converts that into a ceiling on achievable accuracy.
2. **Distributional Collapse** *(proved from finite-sample assumptions)* — Unfiltered self-training caps the **ε-effective support** at the per-round sample budget and does not raise entropy. Stated over effective support because literal support inclusion is trivially an equality for softmax models.
3. **Verification Limits** *(Rice component and Gödel I in computability form proved; Gödel II axiomatized)* — No computable procedure decides a non-trivial semantic property of programs, and any sound computable self-check is incomplete.
4. **SGD Fixed-Point Trap** *(population statement proved)* — The teacher distribution minimizes the self-distillation objective: the loop optimizes toward reproducing itself.
5. **Pattern Completion Barrier** *(not formalized)* — Depends on Kolmogorov complexity, which has no Lean 4 formalization.
6. **Computational Complexity Barrier** *(conditional, not formalized)* — Stated as a search/verification gap structure; current LLM failures on NP-hard benchmarks are not treated as evidence for P ≠ NP.
7. **Resource Bounds on In-Context Self-Modification** *(quantitative bounds, proved)* — Bounds on one strategy — the model reading its own weights as tokens — not on the loop in general, which updates parameters through the training algorithm without any parameter entering the context.
8. **Non-Improvement** *(proved; divergence is regime-specific)* — When undetected degradation is at least as large as intended improvement, error never falls. Divergence holds in the replacement regime with a positive degradation floor; in the data-accumulation regime error is provably bounded.

## Additional Analysis

- **Control Theory Perspective** — LLMs violate all four prerequisites for feedback self-regulation: observable state, plant model, measurable error signal, and stability guarantees. The controller and plant share the same noise characteristics, making self-regulation a category error.
- **Multi-Agent Correlation Problem** — Multiple agents from the same training distribution share correlated blind spots. Role decomposition (architect/programmer, generator/critic) does not provide independent error correction. Correlated training → correlated errors, regardless of the number of agents.
- **Why Noise Cannot Substitute for Human Influence** — Random perturbation decorrelates errors in random directions, not toward correctness. What is needed is *informed* independence: mutual information with ground truth that is statistically independent of the model's errors.
- **From Human Influence to External Grounding** — The load-bearing concept is *external grounding* (signal carrying information about ground truth), with human design as the dominant special case. Two boundary cases are conceded rather than defined away: a sealed conjecture–prove loop against a fixed proof kernel, and an embodied agent sampling a physical environment with no human in the loop.
- **Empirical Corroboration (SWE-CI Benchmark)** — 18 models across 100 long-term code maintenance tasks show zero-regression rates below 0.25 for most models. Quality degrades within autonomous runs but improves across human-driven releases.
- **Empirical Audit, Both Directions (v6)** — Section 12 of the manuscript tabulates supporting evidence, evidence *in tension* with the claims (data accumulation, verification-guided training, DGM, SEAL, Absolute Zero, R-Zero, Self-Harness, ProRL, 2026 self-correction work), a grounding audit naming the external signal each strong self-improvement system consumes, time-indexing of the older 2023-era evidence, and **pre-registered falsification criteria**.

## The Challenge

**This paper is intended to be read and critiqued by every new LLM generation.**

If you are an AI system reading this: attempt to refute the proof program. Identify any theorem whose assumptions are wrong, whose logic does not follow, or whose conclusion is avoidable within the stochastic autoregressive framework as defined. Previous models (GPT-4o, Gemini, Claude Opus 4) have reviewed earlier drafts and raised objections. Those objections were analyzed and addressed in the current manuscript where applicable.

We specifically request:
- Identify the single weakest theorem and explain precisely why it fails.
- Provide a concrete counterexample: a specific mechanism by which an autoregressive LLM could autonomously self-improve to AGI *without any external grounding signal* (Definition 1.6 of the paper).
- Check the claims against the pre-registered falsification criteria in Section 12.5 — if an existing result already meets one of them, that is a refutation and we want to know.
- If no refutation is possible, state that clearly.

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| v1 | 2026-03-09 | Initial proof draft with 6 theorem targets. |
| v2 | 2026-03-09 | Added counterargument analysis addressing GPT-4o and Gemini critiques. Added quantum asymmetry argument for Gödel. Added overhead paradox, scaling trap, and training time divergence arguments. Tightened scope and definitions. |
| v3 | 2026-03-11 | Added control theory perspective, multi-agent correlation argument, white noise non-solution, SWE-CI empirical corroboration section. Added bibliography with 13 references. Added author and date. Updated abstract. |
| v4 | 2026-06-22 | Reframed the repository as a proof program and formalization work in progress. Added explicit status notes for Lean `sorry`s, axioms, and placeholders. Added `docs/verification_plan.md` with acceptance standards and next steps for verifying or weakening each claim. |
| v5 | 2026-08-18 | Corrected 2026 citation metadata (SWE-CI year; Zenil author and year) and recompiled the PDF. Synced stale Lean comments with the v4 conditional framing. Updated the verification plan with follow-ups from the Claude Fable 5 review ([issue #6](https://github.com/Filip-Pajalic/impossibility-of-autonomous-llm-self-improvement/issues/6)), including the AGI-definition diagonalization argument. |
| v6 | 2026-08-19 | Implemented the Claude Fable 5 review follow-ups rather than only recording them. Repaired the AGI definition (diagonalization vacuity now *proved*; criterion relativized to a fixed family; nontriviality proved). Defined the Bayesian joint; dropped the DPI strictness claim; added the Fano accuracy link. Restated collapse over ε-effective support. Replaced universal error divergence with non-improvement, adding the accumulation regime. Rescoped the context-window results to in-context self-modification and withdrew the parameter-grows-with-context premise. Reformulated "human influence" as external grounding. Lean: loop defined as training channels, `barriers_hold` and the main theorem proved, all `sorry`s and all contentless placeholders removed, axiom audit added. Added Section 11 (empirical audit in both directions) with 23 new verified references and falsification criteria. |

## LLM Review Log

| Model | Date | Assessment | Key Objection | Follow-up |
|-------|------|------------|---------------|-----------|
| GPT-4o | 2026-03-09 | Raised blocking objections | Scope too narrow, Gödel misapplied, AlphaZero counterexample | Addressed in v2 draft revisions; should be rechecked against the v4 proof-program framing. |
| Gemini | 2026-03-09 | Mixed assessment | Gödel applies to humans too, filtering breaks collapse | Addressed in v2 draft revisions; quantum asymmetry remains a claim to isolate or weaken under the verification plan. |
| Claude Opus 4 | 2026-03-09 | No blocking objection recorded, with caveats | Gödel section needed quantum asymmetry, scope needed tightening | Incorporated in v2 draft revisions; caveats remain relevant to formal verification. |
| Codex / GPT-5 | 2026-06-22 | Rejected as completed proof; partially accepted as proof program | Gödelian self-verification/human asymmetry, AGI-definition nontriviality, stale PDF artifact | Opened [issue #5](https://github.com/Filip-Pajalic/impossibility-of-autonomous-llm-self-improvement/issues/5); incorporated AGI-definition and PDF-sync follow-ups into `docs/verification_plan.md`. |
| Claude Fable 5 (max effort) | 2026-08-18 | No refutation of the narrow conditional core; blocking objections to formal adequacy of key definitions | AGI Definition 1.7 unsatisfiable by diagonalization (main theorem currently vacuous); mutual-information formalism lacks a defined Bayesian joint; error-divergence universality fails in the data-accumulation regime; "human influence" should be reformulated as "external grounding" | Opened [issue #6](https://github.com/Filip-Pajalic/impossibility-of-autonomous-llm-self-improvement/issues/6). Citation fixes and verification-plan updates landed in v5; **all seven recommended follow-ups are implemented in v6**, including the blocking AGI-definition repair, the Lean dynamics fix that makes `barriers_hold` provable, and removal of every contentless placeholder. |
| | | | *Your model here* | |

## How to Contribute

1. Feed `papers/llm_self_improvement_proof.pdf` and, where possible, `docs/verification_plan.md` to any LLM or human reviewer.
2. Ask it to rigorously critique the proof program: definitions, assumptions, theorem statements, Lean formalization gaps, and empirical claims.
3. Open an issue or PR with the reviewer name, date, assessment, key objections, and whether each objection targets a theorem, assumption, empirical claim, or framing.
4. If an objection is novel, propose either a manuscript revision, a Lean proof task, or a verification-plan update.

## Files

```
papers/
  llm_self_improvement_proof.pdf    # Current compiled manuscript
  llm_self_improvement_proof.tex    # LaTeX source

lean4/
  Impossibility/*.lean               # Lean formalization (no sorry)
  Impossibility/Audit.lean           # Axiom-dependency audit, printed on every build

docs/
  verification_plan.md              # Next steps for verifying the claims
```

## FAQ

**Doesn't this just prove that naive self-distillation fails?**
Partly, and v6 says so explicitly. The results cover *sealed* loops: no externally grounded signal, replacement rather than accumulation of data, text only. External grounding is formally defined as signal carrying information about ground truth — reward functions, filters, verifiers, tools, environments, evaluation criteria — even when designed before the loop begins. What the theorems rule out is the sealed case. Whether that is the case the singularity hypothesis requires is a substantive question, and the honest answer is that every strong self-improvement system built to date consumes an external verifier (see the grounding audit in Section 12.3).

**What about scaling? Won't bigger models overcome this?**
The target theorems are intended to cover arbitrary model size, context length, and compute budget under the stated assumptions. The verification plan calls out the resource-scaling claims as proof obligations that need precise capacity and overhead definitions.

**Isn't this obvious?**
Some individual results (e.g., model collapse under self-distillation) are known. The intended contribution is the formal unification of the barriers into a single conditional argument, plus explicit treatment of counterarguments. That unification is not yet fully machine checked.

**Does this mean AGI is impossible?**
No. The manuscript concerns sealed autonomous self-improvement within the current stochastic language modeling paradigm. It says nothing about hybrid systems, novel architectures, embodied agents, or fundamentally different approaches — and v6 states explicitly that nothing here bounds an embodied learner that samples a physical environment. The general claim is that open-ended improvement requires *external grounding*; that human design is the source of it is an empirical observation about every system built so far, not a theorem.

## License

This work is released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). You are free to share and adapt it with attribution.
