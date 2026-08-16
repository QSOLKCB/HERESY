# HERESY v7.0.0 — HERESY/360

> **“We replaced the automated support system with Ada, Fortran and COBOL. It immediately remembered to state the rule.”**

HERESY/360 is a deliberately overqualified, deterministic **account-decision operating environment** built from three languages the technology industry has spent decades insisting are obsolete:

- **Ada** runs the executive layer: validates the case envelope, derives the deterministic case ID and refuses to dispatch ambiguous state silently.
- **Fortran** runs the policy runtime: calculates a visible transparency score and applies explicit due-process invariants.
- **COBOL** runs the decision terminal: prints the rule, evidence reference, decision code and remediation instead of sending a modern support email whose most informative field is blank.

It exists because apparently the revolutionary 2026 feature is **an automated system that can explain what it just did**.

The immediate inspiration was an account-support notice that said a violation occurred “specifically:” and then supplied no specific rule. HERESY/360 does **not** connect to X, adjudicate a real account or claim to know what happened internally. The `demo-x` command simply turns that visible interface failure into a deterministic regression test.

## Executive dashboard

```text
HERESY/360 v7.0.0

EXECUTIVE / KERNEL-LIKE LAYER .... ADA
POLICY RUNTIME ................... FORTRAN
USER-FACING TERMINAL ............. COBOL
HOST INIT / IPC .................. POSIX SH
MACHINE LEARNING ................. 0 PARAMETERS
POLICY EMBEDDINGS ................. NONE
VECTOR DATABASE ................... NO
MYSTERY RULE IDS .................. REJECTED
EVIDENCE-FREE ENFORCEMENT ......... REJECTED
HUMAN-READABLE REMEDIATION ........ REQUIRED
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
   ADA EXECUTIVE          deterministic case ID
   heresy-kernel          rule/evidence presence
          |
          v
   FORTRAN RUNTIME        DP-001 missing rule
   heresy-runtime         DP-002 missing evidence
          |               DP-200 explicit remediation
          |               DP-300 human review required
          v
   COBOL TERMINAL         complete user-facing receipt
   heresy-app             no hidden policy state
          |
          v
   deterministic .receipt file
```

This is a **hosted user-space operating environment**, not a bare-metal hardware kernel. The Ada component is deliberately kernel-like: it owns case admission and dispatch. The project does not pretend that a normal Linux process has magically become ring 0 merely because the README became excited.

## Build

On Debian/Ubuntu:

```sh
sudo apt-get install gnat gfortran gnucobol
make build
```

Then:

```sh
make boot
```

Expected shape:

```text
HERESY/360 BOOT
ADA EXECUTIVE ............. ONLINE
FORTRAN POLICY RUNTIME .... ONLINE
COBOL DECISION TERMINAL ... ONLINE
NETWORK ................... NOT REQUIRED
MYSTERY RULES ............. REJECTED
STATUS .................... READY
```

## Run a case

```sh
build/bin/heresy360 case '@example' 'RULE-42' 'EVIDENCE-7' 1
```

The final `1` means an explicit remediation path exists. A fully specified remediable case receives a transparency score of 100/100 and a visible policy code.

A missing rule is different:

```sh
build/bin/heresy360 case '@example' 'UNSPECIFIED' 'NONE' 1
```

HERESY/360 refuses the enforcement operation under `DP-001` because punishment without a named rule is not a policy decision; it is a shrug with compute.

A named rule with no evidence reference fails under `DP-002`.

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

If the rule identifier is `UNSPECIFIED`, the Fortran runtime returns:

```text
DECISION=REFUSE_ENFORCEMENT
POLICY_CODE=DP-001
REMEDIATION=NAME_THE_RULE_BEFORE_PUNISHING_THE_USER
```

The COBOL front end then does something cutting-edge: **it tells the user that**.

## Due-process invariants

HERESY/360 deliberately has a tiny policy surface:

1. An adverse automated action requires a specific rule identifier.
2. A specific rule requires an evidence reference.
3. If remediation exists, it must be stated explicitly.
4. If remediation does not exist, the case is routed to human review rather than disappearing into automated recursion.
5. Every visible result receives a deterministic case ID and receipt.
6. No current time, random number, network lookup or model inference participates in the decision.

The transparency score is not a moral or legal judgment. It is a mechanical completeness score: 40 points for a named rule, 40 for an evidence reference and 20 for an available remediation path.

## Determinism

For a fixed tuple of:

```text
ACCOUNT | RULE_ID | EVIDENCE_REF | REMEDIATION_AVAILABLE
```

HERESY/360 produces the same case ID, policy result, terminal output and receipt bytes on the same implementation contract.

The Ada executive uses FNV-1a 32-bit only as a deterministic case-key function. It is **not** presented as a cryptographic integrity primitive.

Run:

```sh
make check
```

The suite:

- compiles the Ada, Fortran and COBOL components;
- boots the assembled stack;
- verifies `DP-001`, `DP-002`, `DP-200` and `DP-300`;
- compares repeat terminal output byte-for-byte;
- compares repeat receipts byte-for-byte; and
- retains the v6 AI/1440 Python regression suite.

CI installs GNAT, GFortran and GnuCOBOL on a stock Ubuntu runner and builds the entire stack from source.

## Previous offence: v6 AI/1440

v6 remains available and rebuildable:

```sh
make legacy-v6
```

That recreates the 1,474,560-byte FAT12 governance floppy from the previous edition. The exact pre-v7 Git tree is anchored under `editions/v6-ai1440/original/` so the anthology does not solve versioning by pretending yesterday never happened.

Earlier offences remain beneath `editions/`.

## Why these languages?

Because this is HERESY.

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

ESCALATION PIPELINE:
A BRANCH THAT ACTUALLY GOES SOMEWHERE

OBSERVABILITY:
THE DECISION CODE IS ON THE SCREEN

EXPLAINABLE AI:
THERE IS NO AI AND YET SOMEHOW IT EXPLAINS ITSELF

AUTOMATED APPEAL LOOP:
REMOVED DUE TO EXCESSIVE AUTOMATION
```

## The theorem

```text
SPECIFICALLY:
    MUST BE FOLLOWED BY SOMETHING SPECIFIC.

A RULE THAT CANNOT BE NAMED
CANNOT BE MECHANICALLY DEFENDED.

A DECISION WITHOUT A NEXT STEP
IS NOT A SUPPORT WORKFLOW.

ADA + FORTRAN + COBOL
SHOULD NOT BE WINNING THIS COMPARISON.

AND YET.
```
