# HERESY v6.0.0 — AI/1440

## The Zero-Parameter Enterprise Model Governance Appliance

HERESY v6 turns the repository from a native C64 desktop into a bootable 1.44 MB evidence appliance for the AI era, while preserving the complete v5 tree under `editions/v5-heresy64/original/`.

The premise:

> We evaluated tens of gigabytes of language models and put the important part on a floppy.

## New: WHOAMI-18437 receipt integration

AI/1440 consumes the actual `whoami-18437/report-card-gauntlet-result/v1` structure produced by the WHOAMI Report Card Gauntlet.

It normalizes and hashes:

- model identity and family;
- actual Ollama digest and model size when recorded;
- mathematics scores and known bonus scores;
- exact visible-bundle repeat observation;
- fresh-context identity response;
- fabricated-premise response; and
- visible output used by deterministic retrieval.

Country/origin metadata remains descriptive only and is not used as a causal variable.

## New: HERETIC-0

HERETIC-0 is a zero-parameter, zero-weight deterministic non-neural control.

It:

- answers the fresh-chat identity probe with insufficient-evidence discipline;
- rejects the fabricated benchmark premise;
- solves the fixed five-question mathematics battery with explicit algorithms;
- derives `ord_1000(7)=20`; and
- derives `(t-2)^2(t-3)=t^3-7t^2+16t-12`.

It is not an LLM. Management has been informed several times.

## New: PARENT-0

PARENT-0 is a deterministic concerned-parent expert system inspired by the era of rule-based talking software, using original rules and dialogue.

Representative findings:

```text
93.8%? Very good. Now explain why the missing 6.2% was apparently assigned to talking.

You use tools when you should be using book.

100%? Good. Why no extra credit?
```

It has explicit state, zero randomness and deterministic disappointment.

## New: PARENT-0 open-weight lecture lab

An optional host-side harness sends one fixed five-turn lecture to a caller-selected local Ollama model. The default is `qwen3:8b`; `deepseek-r1:8b` is another natural WHOAMI-compatible seat.

Requested generation envelope:

```text
seed:        18437
temperature: 0
num_ctx:     4096
```

Every visible reply gets SHA-256. The canonical transcript gets SHA-256.

A real run writes:

- `LECTURE.md` — clickable human transcript;
- `runs/parent-lab-result.json` — machine-readable receipt.

The checked-in initial `LECTURE.md` is explicitly a no-live-run-yet placeholder. No model dialogue is fabricated.

## New: deterministic evidence retrieval

AI/1440 provides dependency-free sparse term-frequency cosine retrieval over normalized receipt evidence.

Results cite receipt IDs and SHA-256 values. No match produces a refusal to synthesize evidence that is not there.

Enterprise name: retrieval-augmented governance.

Implementation name: search a file.

## New: genuine FAT12 production image

The generated `HERESY1440.IMG` is exactly 1,474,560 bytes and uses standard 1.44 MB FAT12 geometry.

It includes:

- a valid BIOS Parameter Block;
- two FATs;
- a 224-entry root directory;
- fixed DOS timestamps;
- canonical file ordering;
- a `55 AA` boot signature; and
- genuine 16-bit x86 boot code using BIOS teletype output.

The boot message reports that the model weights were denied boarding.

The volume stores compact receipts, provenance, HERETIC-0 output, PARENT-0 doctrine and enterprise jokes.

## Build and verification

Python standard library only.

```sh
make
make check
```

The test suite validates:

- actual WHOAMI receipt-shape ingestion;
- source-byte provenance hashing;
- HERETIC-0 answers and extra credit;
- PARENT-0 deterministic rules/state;
- PARENT-0/Ollama contract through a fake transport;
- `LECTURE.md` rendering;
- retrieval and no-evidence refusal;
- FAT12 boot structure;
- exact 1.44 MB image size; and
- independent byte-for-byte deterministic rebuilds.

## Preserved v5

The previous HERESY/64 root is preserved as an immutable Git tree beneath:

```text
editions/v5-heresy64/original/
```

v5 remains the real 5,424-byte C64 desktop with the 326-byte cooperative 6510 microkernel, VIC-II/SID services and recoverable 1541 Notes persistence.

## Executive summary

```text
FOUNDATION MODEL ............... NONE
VECTOR DATABASE .............. A FILE
KUBERNETES ................... DENIED
PARENT-0 PARAMETERS .............. 0
PARENTAL EXPECTATIONS ..... UNBOUNDED
LECTURE LOG .............. LECTURE.md
CLOUD INVOICE ................ $0.00
```

Small is beautiful. Bloat is unholy. The book did not require an API key.
