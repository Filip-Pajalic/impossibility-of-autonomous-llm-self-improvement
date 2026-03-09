# Contributing

## Submitting an LLM Review

1. Feed `paper/llm_self_improvement_proof.pdf` to any LLM.
2. Use the following prompt (or similar):

```
Read this paper carefully. It claims to prove that autonomous LLM 
self-improvement to AGI is impossible within the stochastic autoregressive 
framework. Your task:

1. Identify the single weakest theorem and explain precisely why it fails.
2. Provide a concrete counterexample: a specific mechanism by which an 
   autoregressive LLM could autonomously self-improve to AGI without any 
   form of human influence (as defined in Definition 1.4 of the paper).
3. For each objection you raise, check whether it is already addressed 
   in the paper's Response sections. If it is, explain why the Response 
   is insufficient.
4. If no refutation is possible, state that clearly.
```

3. Open an issue with:
   - **Model name and version** (e.g., GPT-5, Claude Opus 4.5, Gemini 2.5 Ultra)
   - **Date of review**
   - **Verdict**: Accepted / Rejected / Partially Accepted
   - **Key objections** (summarized)
   - **Full transcript** (attached or linked)

4. If the objection is novel (not already addressed in the paper), open a PR with suggested revisions to the paper.

## Submitting a Human Review

Same as above. Mathematicians, computer scientists, and decision theorists are especially welcome. Please indicate your background.

## Revising the Paper

If you want to propose changes to the proof:

1. Edit `paper/llm_self_improvement_proof.tex`
2. Build with: `pdflatex llm_self_improvement_proof.tex` (run 3x for refs)
3. Open a PR with a clear description of what changed and why

## Ground Rules

- Objections must engage with the actual mathematical claims, not the framing or rhetoric.
- "But what about tool use / RL / environment interaction" is addressed in the paper (see Definition 1.4 and the Response sections). If you raise this, explain specifically why the paper's treatment is insufficient.
- "Scale will fix it" is addressed by Theorems 7.1-7.4. Same rule applies.
- Objections that restate points already addressed in the paper without explaining why the response fails will be closed.
