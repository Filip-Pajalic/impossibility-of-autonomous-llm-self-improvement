import Lake
open Lake DSL

package impossibility where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

@[default_target]
lean_lib Impossibility where
  srcDir := "Impossibility"

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.16.0"
