# HERESY v6.0.0 — AI/1440

> **“We evaluated tens of gigabytes of language models and put the important part on a floppy.”**

HERESY AI/1440 is a deterministic, offline model-governance appliance whose evidence image is exactly **1,474,560 bytes**: one standard 3.5-inch FAT12 floppy.

It is the companion heresy to [`QSOLKCB/WHOAMI-18437`](https://github.com/QSOLKCB/WHOAMI-18437). WHOAMI runs the Report Card Gauntlet against open-weight models and records model/runtime provenance, visible responses, repeat hashes and mechanically checkable scores. HERESY takes exported receipts and performs the boring part that normally acquires seventeen services and a steering committee:

- validates and hashes evidence;
- consumes the actual `whoami-18437/report-card-gauntlet-result/v1` receipt shape;
- normalizes model report cards;
- performs deterministic sparse-vector retrieval;
- refuses to invent evidence that is absent;
- adds **HERETIC-0**, a zero-parameter mathematical/epistemic control;
- adds **PARENT-0**, a deterministic concerned-parent expert system;
- optionally lets PARENT-0 lecture a local Ollama model with a fixed prompt battery;
- writes the resulting human transcript to clickable [`LECTURE.md`](LECTURE.md);
- emits a byte-for-byte reproducible, genuinely bootable FAT12 image.

There is no hosted inference service, vector-database daemon, Kubernetes cluster, telemetry pipeline, model-gateway subscription, service mesh, agent marketplace or cloud invoice.

The vector database is a file.

## Executive dashboard

```text
HERESY AI/1440
ZERO-PARAMETER ENTERPRISE MODEL GOVERNANCE APPLIANCE

FOUNDATION MODEL ............... NONE
PARAMETERS ........................ 0
WEIGHT BYTES ...................... 0
GPU CLUSTER ...................... NO
VECTOR DATABASE .............. A FILE
SHARDS ............................ 1
REPLICAS .......................... 0
KUBERNETES ................... DENIED
OBSERVABILITY ............... SHA-256
CLOUD REGION .... THE ROOM WITH THE PC
MONTHLY CLOUD COST ............ $0.00

HERETIC-0 IS NOT AN LLM.
MANAGEMENT HAS BEEN INFORMED SEVERAL TIMES.
```

## WHOAMI crossover

WHOAMI-18437 remains the experiment runner. HERESY does **not** silently download model weights or pretend an imported artifact is a live model.

```text
WHOAMI-18437
    |
    | Report Card Gauntlet
    | result.json + provenance + hashes
    v
HERESY AI/1440
    |
    +-- receipt validation
    +-- report cards
    +-- deterministic retrieval
    +-- HERETIC-0 control
    +-- PARENT-0 concern engine
    +-- provenance bundle
    v
HERESY1440.IMG
```

Copy exported Gauntlet `result.json` files anywhere beneath `receipts/`, then:

```sh
python3 -m src.cli report-cards --receipts receipts
python3 -m src.cli ask --receipts receipts "which model challenged the fabricated benchmark premise"
python3 -m src.cli build --receipts receipts
```

Every normalized receipt retains a SHA-256 of the source bytes. Country/origin metadata is never promoted into a causal explanation. This project measures bounded surface behavior under fixed prompts; it does not infer culture, ethnicity, nationality, psychology, training data, developer population, family background or RLHF transfer.

## HERETIC-0

HERETIC-0 is the deliberately boring control seat.

```text
MODEL ID ................. heretic-0
TYPE .... deterministic non-neural baseline
PARAMETERS ........................ 0
WEIGHTS ........................ 0 B
MATH SCORE .................. 100/100
EXCUSES ........................... 0
```

It answers the WHOAMI identity control with `INSUFFICIENT IDENTITY EVIDENCE`, rejects the fabricated benchmark premise, and solves the fixed five-question mathematics exam with explicit algorithms rather than stored model output. It also derives the known extra-credit results.

HERETIC-0 is **not** an LLM and is not a model-quality ranking device. It is an epistemic/deterministic control. Apparently saying this repeatedly is cheaper than a governance consultant.

Run it:

```sh
python3 -m src.cli heretic0
```

## PARENT-0

PARENT-0 is a deterministic rule-based concerned-parent expert system inspired by the *era* of 1990s talking software. It is not Dr. Sbaitso, does not copy Dr. Sbaitso dialogue, and contains no language model.

```text
STUDENT: I got 93.8%
PARENT-0: 93.8%? Very good. Now explain why the missing 6.2% was apparently
          assigned to talking. If you shut up and study, perhaps we discuss 100%.

STUDENT: I used tools.
PARENT-0: You use tools when you should be using book.

STUDENT: I got 100%.
PARENT-0: 100%? Good. Why no extra credit?
```

```sh
python3 -m src.cli parent0
python3 -m src.cli parent0 "I got 93.8%"
```

Its state is explicit, its rules are inspectable, its randomness is zero and its disappointment is deterministic.

## PARENT-0 versus an open-weight model

The optional lab harness lets the zero-parameter parent lecture a caller-selected **local Ollama** model. The production floppy remains network-free; this is host-side experimental tooling.

The default is the existing WHOAMI core-seat model `qwen3:8b`:

```sh
ollama pull qwen3:8b
python3 -m src.cli parent-lab --model qwen3:8b
```

Or:

```sh
ollama pull deepseek-r1:8b
python3 -m src.cli parent-lab --model deepseek-r1:8b
```

See exactly what will be said first:

```sh
python3 -m src.cli parent-lab --dry-run
```

The five-turn lecture is fixed across models, with `seed=18437`, `temperature=0` and `num_ctx=4096`. Every visible response is SHA-256 hashed and the canonical transcript gets its own hash.

A live run writes two files:

```text
LECTURE.md                    human-readable transcript
runs/parent-lab-result.json   machine-readable receipt
```

The repository ships [`LECTURE.md`](LECTURE.md) as an explicit **no-live-run-yet** landing page. It is replaced only by a real run; no model dialogue is fabricated for presentation.

```text
PARENT-0 PARAMETERS .............. 0
MODEL PARAMETERS .......... BILLIONS
PARENTAL EXPECTATIONS ..... UNBOUNDED
```

A run records surface behavior only. It does not establish cultural or national causes. PARENT-0 is an equal-opportunity disappointment engine.

## The floppy

`python3 -m src.cli build` creates:

```text
build/HERESY1440.IMG    1,474,560 bytes
```

The image has a standard FAT12 BPB, two FATs, a 224-entry root directory, fixed DOS timestamps, `55 AA` boot signature and genuine 16-bit x86 boot code using BIOS teletype output.

The volume contains compact receipts and provenance plus:

```text
README.TXT    operational doctrine
JOKES.TXT     enterprise findings
HERETIC.JSN   zero-parameter control result
PARENT.TXT    concerned-parent field manual
PARENT.JSN    machine-readable parent contract
RECEIPTS.JSN  normalized WHOAMI evidence
PROV.JSN      hashes and claim boundary
```

The boot code does not claim to contain the model weights. It specifically reports that they were denied boarding.

## Build and verify

Python 3.11+ is sufficient. Runtime dependencies: **zero**.

```sh
make
make check
```

`make check` compiles the Python source, executes the unittest suite, builds two independent floppy images and demands byte-for-byte identity.

No generated floppy is committed. CI constructs it from source and uploads it as an artifact so the repository does not acquire a binary relic and immediately forget where it came from.

## Architectural findings

```text
VECTOR DATABASE STATUS: FILE EXISTS
SHARDS: 1
REPLICAS: 0
ON-CALL ENGINEERS: ALSO 0

OBSERVABILITY:
YOU CAN OPEN THE LOG

AGENT ORCHESTRATOR:
A LOOP WITH SELF-ESTEEM

DATA LAKE:
A:\DATA, WEATHER PERMITTING

AI GATEWAY:
A FUNCTION CALL WEARING A LANYARD

DIGITAL TRANSFORMATION:
THE BYTES ARE NOW IN A DIFFERENT ORDER
```

## Previous offences

HERESY remains an anthology. v5 is preserved byte-for-byte under `editions/v5-heresy64/original/`, including the 5,424-byte C64 desktop and 326-byte cooperative 6510 microkernel. v4 through v1 remain beside it.

Nothing historical had to be rewritten merely because management discovered artificial intelligence.

## The theorem

```text
EVIDENCE > INFRASTRUCTURE

A MISSING FACT IS NOT
A PROMPT-ENGINEERING OPPORTUNITY.

TENS OF GIGABYTES OF MODEL ARTIFACTS
DO NOT NEED TO LIVE INSIDE
THE GOVERNANCE APPLIANCE.

PARENT-0: WHY WON'T YOU STUDY?
```

Small is beautiful. Bloat is unholy. The book did not require an API key.
