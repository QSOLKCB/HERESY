# HERESY v7.1.0 — HERESY/360

> **“We replaced the automated support system with Ada, Fortran and COBOL. It immediately remembered to state the rule. Then the cloud fell over and COBOL read the status page.”**

HERESY/360 is a deliberately overqualified, deterministic **account-decision operating environment** built from three languages the technology industry has spent decades insisting are obsolete:

- **Ada** owns case admission, deterministic display case IDs, blank-rule/evidence detection, and the v7.1 reliability gate.
- **Fortran** owns the due-process policy runtime, transparency score, explicit next-step propagation, and deterministic incident severity classification.
- **COBOL** owns the user-facing decision terminal and the v7.1 enterprise reliability terminal.
- **POSIX shell** owns host-side orchestration, input validation, component health reporting, deterministic receipt storage, and historical incident replay.

It exists because apparently the revolutionary 2026 feature is **an automated system that can explain what it just did**.

The immediate v7.0 inspiration was an account-support notice that said a violation occurred “specifically:” and then supplied no specific rule. HERESY/360 does **not** connect to X, adjudicate a real account, or claim to know what happened internally. The `demo-x` command turns only that visible interface failure into a local deterministic regression test.

v7.1 adds a second piece of enterprise paperwork: a deterministic replay of a maintainer-supplied GitHub status-page snapshot from 17 August 2026. It does not query GitHub live or infer the incident's root cause. It simply notices that an approximate **20% web/API error rate** and **50% raw/archive download error rate** are measurable observations even when the status prose remains admirably calm.

## Executive dashboard

```text
HERESY/360 v7.1.0

EXECUTIVE / KERNEL-LIKE LAYER .... ADA
POLICY RUNTIME ................... FORTRAN
USER-FACING TERMINAL ............. COBOL
HOST INIT / IPC .................. POSIX SH
ENTERPRISE RELIABILITY ........... ALSO ADA/FORTRAN/COBOL
MACHINE LEARNING ................. 0 PARAMETERS
MYSTERY RULE IDS .................. REJECTED
EVIDENCE-FREE ENFORCEMENT ......... REJECTED
PLACEHOLDER REMEDIATION ........... REJECTED
STATUS-PAGE ROOT CAUSE ............ NOT INVENTED
CLOUD REGION ...................... THE COMPUTER YOU ARE USING
MONTHLY AI GOVERNANCE COST ........ STILL $0.00
```

## v7.1 — Enterprise Reliability Emulator

Run:

```sh
make incident
```

or:

```sh
build/bin/heresy360 github-incident
```

The replay consumes only the checked-in historical specimen beneath:

```text
specimens/enterprise-reliability/github-2026-08-17/
```

The source text and deterministic TSV projection are SHA-256 bound. The executable then sends the observed percentages through Ada, Fortran, and COBOL because apparently this is what it takes to say:

```text
STATUS_PAGE_EUPHEMISM != OBSERVED_FAILURE_RATE
UPTIME_BADGE != CURRENT_REALITY
ONE_NORMAL_SERVICE != HEALTHY_PLATFORM
```

At a 50% raw-download error rate, Fortran emits:

```text
STATISTICALLY_SPEAKING_THIS_IS_A_COIN
```

while COBOL records:

```text
PACKAGES NORMAL: ONE EMPLOYEE HAS REPORTED FOR WORK.
```

The module is historical satire, not incident forensics:

```text
STATUS_SNAPSHOT != ROOT_CAUSE
SATIRE != INCIDENT_FORENSICS
```

See `docs/ENTERPRISE-RELIABILITY.md`.

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

        v7.1 SIDE QUEST

   incident.tsv
       |
       v
   ADA RELIABILITY GATE
       |
       v
   FORTRAN SEVERITY RUNTIME
       |
       v
   COBOL STATUS TERMINAL
```

This is a **hosted user-space operating environment**, not a bare-metal hardware kernel. The Ada component is deliberately kernel-like: it owns admission and dispatch. Nobody has been promoted to ring 0 merely because the README became excited.

## Build

On Debian/Ubuntu:

```sh
sudo apt-get install gnat gfortran gnucobol
make build
make boot
```

A healthy boot reports the compiled companions `ONLINE`. If one is missing or not executable, `heresy360 boot` reports that layer `OFFLINE`, prints `STATUS ... DEGRADED`, and exits non-zero instead of remembering a healthier past.

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

The v7.1 incident replay is deterministic for the checked-in `incident.tsv` projection and performs no live status lookup.

Run:

```sh
make check
```

The suite compiles Ada, Fortran, and COBOL; verifies all four policy branches; checks blank-only fields; proves concrete remediation reaches the terminal; rejects CR/LF injection and oversized display inputs; checks degraded boot reporting; exercises a known FNV collision pair; compares repeated output and receipts byte-for-byte; validates the enterprise incident specimen and deterministic replay; and retains the v6 AI/1440 Python regression suite.

The smoke suites are invoked with POSIX `sh`; Bash is not part of the advertised runtime contract.

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

And v7.1 gives them the problem modern cloud infrastructure occasionally makes harder than necessary:

```text
INPUT:  20% WEB/API ERRORS
        50% RAW DOWNLOAD ERRORS

OUTPUT: THIS IS AN INCIDENT
        THIS DOWNLOAD PATH IS A COIN FLIP
        NO, WE DO NOT KNOW THE ROOT CAUSE
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

ENTERPRISE RELIABILITY:
FORTRAN HAS IDENTIFIED THE COIN

STATUS PAGE:
COBOL HAS READ IT CAREFULLY

PACKAGES:
ONE EMPLOYEE HAS REPORTED FOR WORK

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

A STATUS SNAPSHOT
IS NOT A ROOT-CAUSE ANALYSIS.

FIFTY PERCENT ERROR RATE
IS NOT A GENTLE BREEZE.

ADA + FORTRAN + COBOL
SHOULD NOT BE WINNING THIS COMPARISON.

AND YET.
```
