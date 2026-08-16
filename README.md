# HERESY v7.0.0 — HERESY/360

> **“We replaced the automated support system with Ada, Fortran and COBOL. It immediately remembered to state the rule.”**

HERESY/360 is a deliberately overqualified, deterministic **account-decision operating environment** built from three languages the technology industry has spent decades insisting are obsolete:

- **Ada** owns case admission, deterministic display case IDs, and blank-rule/evidence detection.
- **Fortran** owns the due-process policy runtime, transparency score, and explicit next-step propagation.
- **COBOL** owns the user-facing terminal and prints the rule, evidence reference, decision code, score, and remediation.
- **POSIX shell** owns host-side orchestration, input validation, component health reporting, and deterministic receipt storage.

It exists because apparently the revolutionary 2026 feature is **an automated system that can explain what it just did**.

The immediate inspiration was an account-support notice that said a violation occurred “specifically:” and then supplied no specific rule. HERESY/360 does **not** connect to X, adjudicate a real account, or claim to know what happened internally. The `demo-x` command turns only that visible interface failure into a local deterministic regression test.

## Executive dashboard

```text
HERESY/360 v7.0.0

EXECUTIVE / KERNEL-LIKE LAYER .... ADA
POLICY RUNTIME ................... FORTRAN
USER-FACING TERMINAL ............. COBOL
HOST INIT / IPC .................. POSIX SH
MACHINE LEARNING ................. 0 PARAMETERS
MYSTERY RULE IDS .................. REJECTED
EVIDENCE-FREE ENFORCEMENT ......... REJECTED
PLACEHOLDER REMEDIATION ........... REJECTED
COLLIDING RECEIPT OVERWRITE ....... REJECTED
CLOUD REGION ...................... THE COMPUTER YOU ARE USING
MONTHLY AI GOVERNANCE COST ........ STILL $0.00
```

## The stack

```text
                 HERESY/360
                     |
             POSIX host executive
             src/v7/heresy360.sh
                     |
          +----------+-----------+
          |                      |
          v                      |
   ADA EXECUTIVE          deterministic display case ID
   heresy-kernel          rule/evidence completeness
          |
          v
   FORTRAN RUNTIME        DP-001 missing rule
   heresy-runtime         DP-002 missing evidence
          |               DP-200 concrete remediation
          |               DP-300 human review required
          v
   COBOL TERMINAL         complete user-facing decision
   heresy-app             no hidden policy state
          |
          v
   collision-preserving .receipt storage
```

This is a **hosted user-space operating environment**, not a bare-metal hardware kernel. The Ada component is deliberately kernel-like: it owns admission and dispatch. Nobody has been promoted to ring 0 merely because the README became excited.

## Build

On Debian/Ubuntu:

```sh
sudo apt-get install gnat gfortran gnucobol
make build
make boot
```

A healthy boot reports all three compiled companions `ONLINE`. If one is missing or not executable, `heresy360 boot` reports that layer `OFFLINE`, prints `STATUS ... DEGRADED`, and exits non-zero instead of remembering a healthier past.

## Run a case

A remediable complete case must supply the **actual human-readable remediation instruction or reference**:

```sh
build/bin/heresy360 case \
  '@example' \
  'RULE-42' \
  'EVIDENCE-7' \
  'OPEN_APPEAL_FORM_CASE_7'
```

That produces `DP-200`, a 100/100 completeness score, and prints `OPEN_APPEAL_FORM_CASE_7` as the next step.

If a complete case has no concrete remediation argument:

```sh
build/bin/heresy360 case '@example' 'RULE-42' 'EVIDENCE-7'
```

it receives `DP-300` and is routed to human review.

A missing or whitespace-only rule receives `DP-001`. A named rule with missing or whitespace-only evidence receives `DP-002`.

## Input contract

The receipt format is deliberately line-oriented, and the COBOL presentation fields are intentionally fixed-width. The shell boundary therefore rejects ambiguous input before it reaches the compiled layers:

- account, rule ID, and evidence reference: maximum **80 bytes** each;
- remediation instruction/reference: maximum **96 bytes**;
- CR/LF characters: rejected in all user-supplied fields.

That prevents a terminal from displaying a truncated rule while the Ada layer hashes a longer one, and prevents a newline-bearing value from manufacturing fake receipt fields.

## The X-shaped demo

```sh
make demo
```

or:

```sh
build/bin/heresy360 demo-x
```

The demo is intentionally local and fictional. It models one narrow invariant:

```text
IF AN AUTOMATED NOTICE SAYS "SPECIFICALLY:"
THEN A SPECIFIC RULE MUST FOLLOW.
```

With `UNSPECIFIED` and `NONE` inputs, the policy runtime returns:

```text
DECISION=REFUSE_ENFORCEMENT
POLICY_CODE=DP-001
REMEDIATION=NAME_THE_RULE_BEFORE_PUNISHING_THE_USER
```

The COBOL front end then does something cutting-edge: **it tells the user that**.

## Due-process invariants

HERESY/360 deliberately has a tiny policy surface:

1. An adverse automated action requires a specific nonblank rule identifier.
2. A specific rule requires a nonblank evidence reference.
3. `DP-200` requires a concrete remediation instruction or reference, not a Boolean promise that one exists somewhere.
4. If remediation does not exist, the case is routed to human review.
5. Every visible result exposes a policy code and next step.
6. Missing information fails closed **against enforcement**, not against the user.
7. No current time, random number, network lookup, or model inference participates in the decision.

The transparency score is a mechanical completeness score: 40 points for a named rule, 40 for an evidence reference, and 20 for concrete remediation.

## Determinism and collisions

For a fixed tuple of:

```text
ACCOUNT | RULE_ID | EVIDENCE_REF | REMEDIATION
```

HERESY/360 produces the same policy result, terminal output, and receipt bytes under the same implementation contract.

The Ada executive uses **FNV-1a 32-bit** only as a compact deterministic display case ID. It is neither cryptographic nor globally unique. Distinct tuples that collide on that display ID are stored as separate receipt artifacts rather than allowing the later case to overwrite the earlier one.

Run:

```sh
make check
```

The suite compiles Ada, Fortran, and COBOL; verifies all four policy branches; checks blank-only fields; proves concrete remediation reaches the terminal; rejects CR/LF injection and oversized display inputs; checks degraded boot reporting; exercises a known FNV collision pair; compares repeated output and receipts byte-for-byte; and retains the v6 AI/1440 Python regression suite.

The smoke suite is invoked with POSIX `sh`; Bash is not part of the advertised v7 runtime contract.

## Previous offence: v6 AI/1440

v6 remains available and rebuildable:

```sh
make legacy-v6
```

That recreates the 1,474,560-byte FAT12 governance floppy from the previous edition.

The exact pre-v7 merge commit is:

```text
43c9b50dbd7964095337c2c662e7fb90bd88b8f8
```

and that commit points to root tree:

```text
ce684946a31e0ba1d7d6a428fb5b699cd377c179
```

Both are documented beneath `editions/v6-ai1440/original/`.

## Why these languages?

Ada was designed for systems where silent ambiguity is expensive. Fortran has spent roughly forever doing numerical work while newer languages repeatedly rediscover arrays. COBOL remains embarrassingly good at representing explicit business records.

So v7 gives them the problem modern automated support sometimes appears unable to solve:

```text
INPUT:  ACCOUNT ACTION
OUTPUT: WHAT RULE?
        WHAT EVIDENCE?
        WHAT DECISION?
        WHAT CAN THE USER DO NEXT?
```

No transformer required.

## Architectural findings

```text
AI SAFETY LAYER:
AN IF STATEMENT WITH DOCUMENTATION

POLICY ENGINE:
FORTRAN HAS ENTERED THE CHAT

USER EXPERIENCE:
COBOL PRINTED THE MISSING FIELD

OBSERVABILITY:
THE DECISION CODE IS ON THE SCREEN

COLLISION STRATEGY:
DO NOT DELETE THE OTHER PERSON'S RECEIPT

EXPLAINABLE AI:
THERE IS NO AI AND YET SOMEHOW IT EXPLAINS ITSELF
```

## The theorem

```text
SPECIFICALLY:
    MUST BE FOLLOWED BY SOMETHING SPECIFIC.

A RULE THAT CANNOT BE NAMED
CANNOT BE MECHANICALLY DEFENDED.

A DECISION WITHOUT A REAL NEXT STEP
IS NOT A SUPPORT WORKFLOW.

ADA + FORTRAN + COBOL
SHOULD NOT BE WINNING THIS COMPARISON.

AND YET.
```
