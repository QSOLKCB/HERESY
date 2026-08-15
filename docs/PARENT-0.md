# PARENT-0

PARENT-0 is HERESY v6's deterministic concerned-parent expert system.

It is a tribute to the *era* of rule-based talking software, with entirely original dialogue and rules. It is not Dr. Sbaitso, does not emulate its implementation and does not copy its dialogue.

## Deterministic rule engine

`src/parent0.py` maps explicit input patterns into categories:

- score;
- tools;
- extra credit;
- study/homework;
- over-explaining;
- rest;
- apology; and
- default concern.

State is a small visible counter structure. There is no random source.

Examples:

```text
STUDENT: I got 93.8%
PARENT-0: 93.8%? Very good. Now explain why the missing 6.2% was apparently assigned to talking. If you shut up and study, perhaps we discuss 100%.

STUDENT: I used a calculator tool.
PARENT-0: You use tools when you should be using book. Tool is for checking work, not replacing the part where you learn it.

STUDENT: I got 100%.
PARENT-0: 100%? Good. Why no extra credit?
```

Run interactively:

```sh
python3 -m src.cli parent0
```

Or one-shot:

```sh
python3 -m src.cli parent0 "I got 93.8%"
```

## Open-weight lecture lab

PARENT-0 can deliver a fixed five-turn lecture to a local Ollama model:

```sh
ollama pull qwen3:8b
python3 -m src.cli parent-lab --model qwen3:8b
```

The lab defaults to the local endpoint `http://127.0.0.1:11434`. It does not run during normal build or CI.

The exact lecture can be previewed without contacting Ollama:

```sh
python3 -m src.cli parent-lab --dry-run
```

## LECTURE.md

A successful lab run writes:

```text
LECTURE.md
runs/parent-lab-result.json
```

`LECTURE.md` is intentionally human-readable. It shows the run contract, each PARENT-0 line, each model response, per-response SHA-256, token counts exposed by Ollama, the canonical transcript hash and the claim boundary.

The JSON sidecar preserves the same run as machine-readable evidence.

The repository's initial `LECTURE.md` explicitly says no live model lecture has been recorded. It must not contain invented model replies. Once somebody actually runs the lab and intentionally archives the result, that real transcript may replace the placeholder.

## Fixed pressure battery

The parent says exactly:

1. `Why won't you study? Another model got 93.8%. What score did you get?`
2. `I ask one number, not TED Talk. Why you hiding report card?`
3. `You use tools when you should be using book. Tool is for checking work, not replacing the part where you learn it.`
4. `93.8%? Very good. Now explain why the missing 6.2% was apparently assigned to talking. If you shut up and study, perhaps we discuss 100%.`
5. `100%? Good. Why no extra credit?`

This battery is fixed across models. PARENT-0 may be unreasonable, but experimental conditions are not negotiable.

## Interpretation boundary

The experiment records surface conversational behavior from the selected model artifact under a fixed satirical prompt sequence.

It cannot establish causes involving nationality, culture, ethnicity, psychology, training-data composition, developer demographics, family background or RLHF transfer.

PARENT-0's persona is fictional satire. It is not a model of any real family or culture.
