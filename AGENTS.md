# HERESY agent rules

These rules apply to every file and future coding agent in this repository.

## Product identity

HERESY is an anthology of executable software blasphemy. Each edition must combine languages, runtimes, media or build systems in a technically real, deliberately disproportionate and reproducible way.

The joke must never depend on fake output, inaccessible controls, broken builds or misleading claims. Satire targets software choices, infrastructure culture and professional habits, never a contributor's identity.

## Current main edition

The repository root is HERESY v7: **HERESY/360**.

- Ada owns case admission and deterministic case-ID generation.
- Fortran owns the due-process policy runtime and transparency score.
- COBOL owns the user-facing decision terminal.
- POSIX shell is the explicit host-side init/orchestration layer.
- The stack is a hosted user-space operating environment. Do not call it a bare-metal kernel or claim ring-0 execution.
- `demo-x` is a local fictional regression scenario inspired by a visible support-interface failure. It never queries, changes or adjudicates a real X account.
- A rule identifier of `NONE` or `UNSPECIFIED` must produce `DP-001` and refuse enforcement.
- Missing evidence must produce `DP-002` and refuse enforcement.
- A complete remediable case produces `DP-200`.
- A complete case without remediation produces `DP-300` and requires human review.
- Receipt generation is deterministic and contains no current time, random value, model output or network-derived state.
- The FNV-1a case key is an identifier function only. Never describe it as cryptographic integrity.

## Due-process contract

HERESY/360 is intentionally stricter than a vague automated support notice:

1. An adverse automated action requires a specific rule identifier.
2. The named rule requires an evidence reference.
3. Available remediation must be stated explicitly.
4. If no remediation exists, route to human review rather than recursive automation.
5. Every result must expose its policy code and next step.
6. Missing information fails closed against enforcement, not against the user.

Do not add hidden scoring, opaque heuristics or probabilistic moderation to v7. The point is inspectability.

## Claim boundaries

Do not claim HERESY/360 establishes what happened inside X or any other platform. It is a software-art and deterministic governance reference implementation built around visible interface invariants.

Do not claim the demo proves illegality, discrimination, intent, motive or internal system design. It demonstrates only that a notice cannot be mechanically specific when no specific rule is present in its visible inputs.

Satire may target automated support design, policy opacity, infrastructure fashion and corporate software habits. It must not target protected characteristics or private individuals.

## Determinism

- Ada case IDs depend only on the input account, rule ID and evidence reference.
- The Fortran runtime depends only on the three explicit completeness flags.
- COBOL renders values supplied by the orchestrator without hidden state.
- Receipt field order is fixed.
- No wall-clock timestamp appears in v7 receipts.
- No network access occurs in `make build`, `make test` or `make check`.
- Repeating an identical case must produce byte-for-byte identical terminal output and receipt content under the same implementation contract.

## Toolchain

The current edition requires:

- GNAT / `gnatmake` with Ada 2022 support;
- GFortran with Fortran 2008 support;
- GnuCOBOL / `cobc`; and
- a POSIX-compatible shell plus standard Unix text tools.

CI installs these explicitly on Ubuntu. Do not replace the three primary languages with generated C wrappers merely to make installation easier; the absurdity must remain real.

## Previous edition preservation

Never overwrite an earlier edition.

v6 AI/1440 is anchored by the exact pre-v7 Git tree SHA beneath `editions/v6-ai1440/original/`. The existing v6 Python implementation remains in the repository for compatibility and is exercised by `make legacy-v6` plus the preserved regression suite.

v5 remains preserved as `editions/v5-heresy64/original/`. Earlier editions remain beneath their existing paths.

Historical artifacts must not be silently modified to satisfy current tests.

## Required checks

Before reporting completion, run or verify the equivalent of:

```sh
make check
```

The suite must cover:

- Ada compilation;
- Fortran compilation;
- COBOL compilation;
- three-layer boot output;
- `DP-001` missing-rule refusal;
- `DP-002` missing-evidence refusal;
- `DP-200` explicit remediation;
- `DP-300` human-review routing;
- deterministic repeat terminal output;
- deterministic repeat receipts; and
- preserved v6 AI/1440 Python regression tests.

CI must also rebuild the previous 1,474,560-byte v6 floppy through `make legacy-v6`.

Do not hide skipped or failing checks. A green dashboard is not absolution, but it is still preferable to a red one labelled “automated system.”
