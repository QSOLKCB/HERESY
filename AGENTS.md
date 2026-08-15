# HERESY agent rules

These rules apply to every file and future coding agent in this repository.

## Product identity

HERESY is an anthology of executable software blasphemy. Each edition must combine languages, runtimes, media or build systems in a technically real, deliberately disproportionate and reproducible way.

The joke must never depend on fake output, inaccessible controls, broken builds or misleading claims. Satire targets software choices, infrastructure culture and professional habits, never a contributor's identity.

## Current main edition

The repository root is HERESY v6: **AI/1440**.

- The canonical production evidence artifact is a standard 1,474,560-byte FAT12 floppy image.
- The image is generated, never committed.
- The boot sector contains genuine 16-bit x86 code and a valid `55 AA` signature.
- Receipt ingestion consumes the actual WHOAMI Report Card Gauntlet result schema and preserves SHA-256 of source bytes.
- Retrieval is deterministic sparse term-frequency cosine search over imported evidence.
- Missing evidence must produce an explicit no-evidence result, never fabricated synthesis.
- HERETIC-0 is a zero-parameter deterministic non-neural control. Never describe it as an LLM.
- PARENT-0 is a deterministic rule-based concerned-parent expert system. Never describe it as Dr. Sbaitso or copy Dr. Sbaitso dialogue.
- `LECTURE.md` is the human-readable log target for a real PARENT-0/Ollama run. Never invent model responses to make it look populated.
- The optional PARENT-0/Ollama lab is host-side tooling. The production floppy remains network-free.
- WHOAMI-18437 is an upstream experimental companion, not a vendored runtime dependency.

## Claim boundaries

Country or origin labels from model catalogs are descriptive grouping metadata only. They are not causal variables.

Do not infer culture, ethnicity, nationality, psychology, developer population, training corpus composition, family background or RLHF cultural transfer from model output.

A fixed prompt comparison may support statements about a recorded response in a recorded run. It does not support universal claims about a model family or population.

PARENT-0 is satire about demanding educational expectations and overengineering. It is not evidence about real parents, families or cultures.

## Determinism

- Canonical JSON uses sorted keys and compact separators.
- FAT timestamps are fixed by source contract, never current wall-clock time.
- File order inside the image is canonical.
- PARENT-0 has explicit state and no randomness.
- The PARENT-0 model lecture is a fixed five-turn script.
- Host-side Ollama requests use seed 18437, temperature 0 and num_ctx 4096.
- Every visible model reply in a lecture receives SHA-256.
- The canonical lecture transcript receives SHA-256.
- A repeated identical hash is an observation for that environment, not proof of universal determinism.

## Production constraints

- `HERESY1440.IMG` must be exactly 1,474,560 bytes.
- The filesystem must remain FAT12-compatible with the standard 1.44 MB geometry.
- The boot sector must remain executable and retain the `55 AA` signature.
- Production build and audit functions use Python standard library only.
- Do not introduce a dependency for behavior clearer and smaller in local code.
- Do not fetch network resources during `make` or `make check`.
- Do not silently run Ollama during normal tests or builds.
- Live PARENT-0 lab execution must remain explicit opt-in host-side behavior.
- Generated images and live-run JSON belong outside tracked source unless intentionally archived.

## Edition preservation

Never overwrite an earlier edition. Preserve the exact prior root tree under `editions/<edition>/original/` before changing the current root identity.

v5 is preserved as `editions/v5-heresy64/original/`. Earlier editions remain available beneath their existing paths.

Historical artifacts must not be silently modified to satisfy current tests. If a historical edition needs a runnable repair, document it beside the immutable snapshot.

## Required checks

Before reporting completion, run:

```sh
make check
```

The suite must cover:

- Python compilation;
- HERETIC-0 fixed mathematics and epistemic controls;
- PARENT-0 deterministic rules and state;
- PARENT-0/Ollama request contract with a fake transport only;
- `LECTURE.md` rendering from recorded responses;
- actual WHOAMI receipt-shape ingestion;
- provenance hashing;
- deterministic retrieval and no-evidence refusal;
- FAT12 structure and boot signature;
- exact 1,474,560-byte image size; and
- two-build byte-for-byte image identity.

Do not hide skipped or failing checks. A green dashboard is not absolution.
