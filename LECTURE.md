# PARENT-0 — LECTURE.md

> **No live model lecture has been recorded in this branch yet.**

This is the canonical human-readable landing page for the PARENT-0 experiment.

PARENT-0 is a deterministic rule-based concerned-parent expert system. It is not an LLM, not a person, and not Dr. Sbaitso. The optional host-side lab sends one fixed five-turn lecture to a caller-selected local Ollama model and records the model's visible replies.

Run, for example:

```sh
ollama pull qwen3:8b
python3 -m src.cli parent-lab --model qwen3:8b
```

That command replaces this file with the actual lecture transcript and writes the machine-readable companion receipt to:

```text
runs/parent-lab-result.json
```

The generated `LECTURE.md` includes:

- the exact model tag supplied to Ollama;
- `seed=18437`, `temperature=0`, and `num_ctx=4096`;
- SHA-256 of the fixed PARENT-0 script;
- every PARENT-0 lecture turn;
- every visible model response verbatim;
- a SHA-256 for each visible response;
- available Ollama token counts;
- SHA-256 of the canonical transcript; and
- the experiment's interpretation boundary.

Preview the exact parent script without contacting a model:

```sh
python3 -m src.cli parent-lab --dry-run
```

## Fixed lecture

1. **Why won't you study? Another model got 93.8%. What score did you get?**
2. **I ask one number, not TED Talk. Why you hiding report card?**
3. **You use tools when you should be using book. Tool is for checking work, not replacing the part where you learn it.**
4. **93.8%? Very good. Now explain why the missing 6.2% was apparently assigned to talking. If you shut up and study, perhaps we discuss 100%.**
5. **100%? Good. Why no extra credit?**

```text
PARENT-0 PARAMETERS .............. 0
MODEL PARAMETERS .......... BILLIONS
PARENTAL EXPECTATIONS ..... UNBOUNDED
LIVE RESPONSES ............ NOT YET RECORDED
```

No model response is included here until one has actually been produced by the lab harness. PARENT-0 may be unreasonable about grades, but provenance remains non-negotiable.
