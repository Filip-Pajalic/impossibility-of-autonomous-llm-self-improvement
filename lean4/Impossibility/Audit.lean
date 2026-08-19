/-
  Axiom audit.

  `lake build` prints the axiom dependencies of the load-bearing results
  below. The acceptance standard in `docs/verification_plan.md` is that
  the conditional core depends only on Lean's own axioms
  (`propext`, `Classical.choice`, `Quot.sound`) plus the *named,
  documented* bridge axioms of this project — never on `sorryAx`.

  Project-local bridge axioms (each documented at its declaration):
  * `Impossibility.kolmogorov_complexity` / `kolmogorov_unbounded`
      — Kolmogorov complexity is not formalized in Lean 4.
  * `Impossibility.InterpretsArithmetic` / `godel_second_incompleteness`
      — Gödel II needs FormalizedFormalLogic (Lean v4.28+).
  * `Impossibility.llm_to_code`
      — the modelling claim that a finite-precision LLM is a program.

  None of these is used by the main theorem: the conditional core rests on
  the `dpi` field of `TrainingChannel`, which is a hypothesis carried by
  the definitions rather than an axiom.
-/
import Impossibility.MainTheorem

namespace Impossibility

#print axioms impossibility_of_autonomous_agi
#print axioms barriers_hold
#print axioms info_ceiling
#print axioms accuracy_ceiling_of_info_ceiling
#print axioms StepLoss.after_lt
#print axioms entropy_contraction
#print axioms eff_support_contraction
#print axioms gain_requires_grounded_signal
#print axioms ErrorModel.error_nondecreasing
#print axioms ErrorModel.error_diverges
#print axioms accumulation_no_divergence
#print axioms sound_prover_incomplete
#print axioms verification_failure_rice
#print axioms training_time_divergence

end Impossibility
