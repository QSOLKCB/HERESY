# HERESY v7.0.0 — HERESY/360

HERESY/360 replaces the current-edition control plane with a deterministic three-language automated-decision stack built in Ada, Fortran and COBOL.

## Headline offence

A modern automated support notice can apparently say a violation occurred “specifically:” and then leave the specific violation blank.

HERESY/360 treats that as a failing test.

The new edition implements one intentionally tiny governance theorem:

```text
SPECIFICALLY: MUST BE FOLLOWED BY SOMETHING SPECIFIC.
```

## Stack

- **Ada executive** — validates the case envelope, treats blank-only rule/evidence fields as missing and derives a deterministic FNV-1a display case ID.
- **Fortran policy runtime** — applies four explicit policy outcomes, calculates a transparent 0–100 completeness score and propagates the concrete remediation instruction/reference for `DP-200`.
- **COBOL terminal** — displays the account, rule, evidence reference, decision, policy code, score and next step.
- **POSIX shell init** — verifies companion executables at boot, validates line-oriented/fixed-width inputs, provides deterministic local orchestration and writes collision-preserving receipt files.

The system is a hosted user-space operating environment, not a bare-metal kernel. No ring-0 cosplay has been added to improve the joke.

## Policy codes

- `DP-001` — enforcement refused because no specific rule is named.
- `DP-002` — enforcement refused because no evidence reference is supplied.
- `DP-200` — complete case with an explicit concrete remediation instruction or reference.
- `DP-300` — complete case without concrete remediation; human review required.

Missing information fails closed **against enforcement**, not against the user.

## Input and receipt hardening

v7's user-facing fields are line-oriented and intentionally bounded by the COBOL presentation contract. The orchestrator therefore rejects CR/LF-bearing values and rejects account/rule/evidence values longer than 80 bytes or remediation values longer than 96 bytes instead of allowing the terminal to display a truncated decision context.

The 32-bit FNV case ID remains a compact deterministic display identifier, not a uniqueness or cryptographic primitive. If two distinct cases collide on that ID, receipt storage retains both byte-distinct artifacts in deterministic collision slots rather than overwriting the first one.

## `demo-x`

`make demo` runs a strictly local fictional scenario using `@qsolimc`, `UNSPECIFIED` and `NONE` as inputs. It does not access X, call an API, inspect a real account, infer an internal rule, or claim to reverse an actual platform decision.

Its only purpose is to demonstrate that the visible absence of a specific rule is enough to fail HERESY/360's own due-process contract.

## Determinism

For identical case inputs under the same implementation contract, v7 verifies byte-for-byte repeatability of:

- terminal output; and
- generated receipt content.

No wall-clock timestamp, random number, model output or network lookup participates in the decision.

## CI

The GitHub Actions job now installs:

```text
gnat
gfortran
gnucobol
```

and then builds all three primary components, runs the POSIX-`sh` v7 smoke/determinism suite, runs the preserved v6 Python tests, executes the local demo and rebuilds the historical 1.44 MB AI/1440 floppy.

The v7 suite additionally checks blank-only policy fields, concrete remediation propagation, receipt newline-injection rejection, fixed-width validation, known FNV collision preservation and degraded boot status when a companion executable is absent.

## v6 preservation

The exact pre-v7 merge commit is:

```text
43c9b50dbd7964095337c2c662e7fb90bd88b8f8
```

and its exact root Git tree is:

```text
ce684946a31e0ba1d7d6a428fb5b699cd377c179
```

Both are documented beneath `editions/v6-ai1440/original/`. The previous Python implementation remains present so `make legacy-v6` can still reconstruct `HERESY1440.IMG`.

## Important non-claims

HERESY/360 does not establish what happened inside X or any other platform. It does not prove illegality, motive, discrimination or a hidden implementation detail. It is executable software satire and a deterministic reference design for explainable automated decisions.

## Final finding

```text
1960s BUSINESS SOFTWARE: PLEASE STATE THE RULE.
2026 AUTOMATED SUPPORT:  [field unavailable]

ADA:    I HAVE VALIDATED THE CASE.
FORTRAN:I HAVE CALCULATED THE POLICY RESULT.
COBOL:  I HAVE PRINTED THE NEXT STEP.

TECH INDUSTRY: WE ARE INVESTIGATING.
```
