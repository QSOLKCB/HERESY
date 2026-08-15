# Architecture — HERESY AI/1440

## Boundaries

HERESY v6 deliberately separates three systems:

1. **WHOAMI-18437 Report Card Gauntlet** — upstream producer of live open-weight model evidence.
2. **AI/1440 appliance** — deterministic offline consumer, indexer and FAT12 packager.
3. **PARENT-0 lab** — optional host-side local Ollama conversation runner.

The production floppy does not perform inference and does not require Ollama.

## Receipt path

`src/receipts.py` consumes `whoami-18437/report-card-gauntlet-result/v1` receipts. It records the SHA-256 of the exact source bytes before normalizing fields used by AI/1440.

The imported evidence includes:

- model ID/family;
- actual runtime model digest and byte size when recorded;
- mechanical mathematics scores;
- known bonus scores;
- exact-repeat observation;
- fresh-context identity response;
- fabricated-premise response; and
- visible model text used for retrieval.

The importer deliberately does not use country/origin labels as explanatory fields.

## Retrieval

`src/query.py` uses deterministic tokenization, integer term frequencies and cosine similarity. The index is rebuilt from the canonical receipt set rather than persisted as an opaque service database.

A query returns receipt IDs and SHA-256 evidence references. A query with no overlap returns an explicit no-evidence response.

## HERETIC-0

`src/heretic0.py` implements the non-neural control. It uses explicit algorithms for the fixed mathematics problems and fixed epistemic responses for questions whose evidence contract is known in advance.

It has:

```text
parameters:   0
weight bytes: 0
randomness:   0
```

It must never be presented as a language model or as proof that language models are unnecessary in general.

## PARENT-0

`src/parent0.py` is a stateful but deterministic expert system. Categories are selected from explicit text rules, score parsing and deterministic state counters.

`src/parent_lab.py` is a separate optional bridge to local Ollama. Its parent sequence is fixed, so different selected models receive the same five messages in the same order. The request envelope is:

```text
seed:        18437
temperature: 0
num_ctx:     4096
stream:      false
```

The lab writes a human `LECTURE.md` and machine JSON receipt. Every visible model reply receives SHA-256. The canonical turn list receives SHA-256.

`temperature=0` and a fixed seed are requested controls, not a universal determinism guarantee.

## FAT12 image

`src/fat12.py` constructs a 1.44 MB image without external libraries.

Geometry:

```text
bytes/sector:        512
sectors/cluster:       1
reserved sectors:      1
FATs:                  2
sectors/FAT:           9
root entries:        224
total sectors:      2880
image bytes:      1474560
```

The boot sector contains a valid BPB and short real-mode x86 routine that prints the AI/1440 notice via BIOS interrupt `10h`, then halts.

FAT timestamps are fixed to the release contract. File names are canonical 8.3 names. Files are sorted before allocation.

## Determinism

`make check` builds two images independently and compares them byte-for-byte. Tests also cover the boot signature, geometry, expected root entries, receipt normalization, retrieval refusal, HERETIC-0, PARENT-0 and the PARENT-0 lab using a fake transport so CI never contacts a model.

## Threat model

AI/1440 treats imported model text as data. It does not execute it. JSON parsing is bounded by local file availability; FAT output is bounded by the physical image size. Unexpected named `result.json` files fail closed.

The principal operational threat remains somebody adding an ORM.
