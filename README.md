# HERESY v7.2.0 — HERESY/360: GitHub PR Response Edition

> **“We asked Fortran to prepare a public-relations response. It answered every question without accidentally answering the question.”**

HERESY/360 is a deliberately overqualified deterministic software-art stack built from **Ada, Fortran, COBOL and POSIX shell**.

The sequence so far:

- **v7.0** replaced vague automated support with a due-process machine that has to name the rule, evidence and next step.
- **v7.1** preserved a maintainer-supplied GitHub status-page snapshot from 17 August 2026 and replayed it through Ada, Fortran and COBOL without inventing root cause.
- **v7.2** asks what the fictional public-relations response to that evidence might sound like, then makes **Fortran** conduct the interview.

The result is the **Public Relations Response Simulator**: an original Australian deadpan two-person public-affairs satire driven by the canonical v7.1 machine projection.

It is explicitly **not** a real GitHub statement, not a real spokesperson transcript, and not an ABC or Clarke & Dawe transcript. The requested premise uses only the broad structural device associated with classic Australian two-person interview satire; every line of dialogue here is original.

## Executive dashboard

```text
HERESY/360 v7.2.0

EXECUTIVE / KERNEL-LIKE LAYER .... ADA
POLICY RUNTIME ................... FORTRAN
USER-FACING TERMINAL ............. COBOL
HOST INIT / IPC .................. POSIX SH
ENTERPRISE RELIABILITY ........... ADA/FORTRAN/COBOL
PUBLIC RELATIONS ................. FORTRAN
MACHINE LEARNING ................. 0 PARAMETERS
MYSTERY RULE IDS .................. REJECTED
EVIDENCE-FREE ENFORCEMENT ......... REJECTED
STATUS-PAGE ROOT CAUSE ............ NOT INVENTED
ACTUAL GITHUB PR RESPONSE ........ NOT CLAIMED
MONTHLY AI GOVERNANCE COST ........ STILL $0.00
```

## v7.2 — Public Relations Response Simulator

Build and issue the fictional statement:

```sh
make pr-response
```

or:

```sh
build/bin/heresy360 pr-response
```

The Fortran core can also be invoked directly:

```sh
build/bin/heresy-pr-response \
  specimens/enterprise-reliability/github-2026-08-17/incident.tsv
```

Before the dialogue begins, the program prints its evidence and claim boundary:

```text
SOURCE_KIND=maintainer_supplied_status_page_snapshot
SOURCE_DATE=2026-08-17
OBSERVED_WEB_API_ERROR_RATE_PERCENT=20
OBSERVED_RAW_DOWNLOAD_ERROR_RATE_PERCENT=50
OBSERVED_PACKAGES_STATUS=NORMAL
ROOT_CAUSE_INFERRED=0
ACTUAL_GITHUB_RESPONSE_CLAIMED=0
```

Then public relations is permitted to become helpful.

Representative exchange:

```text
INTERVIEWER: So a download was, statistically, a coin toss?
PUBLIC_RELATIONS: That is a very binary description of a cloud service.

INTERVIEWER: Was the platform healthy?
PUBLIC_RELATIONS: Some services were operating normally.
INTERVIEWER: That was not the question.
PUBLIC_RELATIONS: It was adjacent to the question.

INTERVIEWER: What caused the incident?
PUBLIC_RELATIONS: The supplied snapshot does not establish root cause.
INTERVIEWER: Finally, a precise answer.
PUBLIC_RELATIONS: We can workshop it.
```

And, because Codex accidentally invented evidence-backed comedy engineering during v7.1:

```text
PUNCHLINE_REQUIRES_SUPPORTED_PRECONDITION
```

The 50% coin-toss joke is emitted only when the parsed raw/archive rate is exactly 50. The Packages-normal joke is emitted only when `PACKAGES_STATUS=NORMAL`. Unsupported jokes are withheld rather than upgraded into facts by enthusiasm.

The response ends with:

```text
HERESY-E-PR: STATEMENT COMPLETE; NOTHING FURTHER HAS BEEN CLARIFIED.
```

See [`docs/PUBLIC-RELATIONS.md`](docs/PUBLIC-RELATIONS.md).

## v7.1 — Enterprise Reliability Emulator

v7.1 preserves the supplied historical snapshot beneath:

```text
specimens/enterprise-reliability/github-2026-08-17/
├── incident.txt
├── incident.tsv
└── SHA256SUMS
```

Run the deterministic replay with:

```sh
make incident
```

or:

```sh
build/bin/heresy360 github-incident
```

The module separates evidence from interpretation:

```text
STATUS_SNAPSHOT != ROOT_CAUSE
STATUS_PAGE_EUPHEMISM != OBSERVED_FAILURE_RATE
UPTIME_BADGE != CURRENT_REALITY
ONE_NORMAL_SERVICE != HEALTHY_PLATFORM
SATIRE != INCIDENT_FORENSICS
```

At the canonical 50% raw/archive error observation, the reliability runtime emits:

```text
STATISTICALLY_SPEAKING_THIS_IS_A_COIN
```

If Packages is recorded as normal, the COBOL terminal is allowed to observe:

```text
PACKAGES NORMAL: ONE EMPLOYEE HAS REPORTED FOR WORK.
```

If a debug fixture says otherwise, the punchline is withheld on factual grounds.

See [`docs/ENTERPRISE-RELIABILITY.md`](docs/ENTERPRISE-RELIABILITY.md).

## v7.0 — Due-process machine

The original HERESY/360 stack remains intact:

```text
              POSIX orchestration
                      |
                      v
                ADA EXECUTIVE
          admission + display case ID
                      |
                      v
               FORTRAN POLICY
       DP-001 / DP-002 / DP-200 / DP-300
                      |
                      v
                COBOL TERMINAL
        rule + evidence + decision + next step
                      |
                      v
       deterministic receipt storage
```

The tiny policy surface is intentional:

1. An adverse automated action requires a specific rule identifier.
2. The rule requires an evidence reference.
3. `DP-200` requires a concrete remediation instruction or reference.
4. If no concrete remediation exists, route to human review.
5. Every result exposes its policy code and next step.
6. Missing information fails closed **against enforcement**, not against the user.

Run the local fictional support demo with:

```sh
make demo
```

The program does not connect to or adjudicate any real platform account.

## Build

On Debian/Ubuntu:

```sh
sudo apt-get install gnat gfortran gnucobol
make build
make boot
```

A healthy v7.2 boot now includes:

```text
ADA EXECUTIVE ............. ONLINE
FORTRAN POLICY RUNTIME .... ONLINE
COBOL DECISION TERMINAL ... ONLINE
ADA RELIABILITY GATE ...... ONLINE
FORTRAN RELIABILITY ....... ONLINE
COBOL STATUS TERMINAL ..... ONLINE
POSIX INCIDENT REPLAY ..... ONLINE
FORTRAN PUBLIC RELATIONS .. ONLINE
NETWORK ................... NOT REQUIRED
STATUS PAGE ROOT CAUSE .... NOT INVENTED
ACTUAL PR RESPONSE ........ NOT CLAIMED
STATUS .................... READY
```

## Determinism

HERESY does not use model inference to decide what it meant after the fact.

For fixed inputs and the same implementation contract:

- v7 case decisions and receipts are byte-for-byte deterministic;
- v7.1 incident replay is byte-for-byte deterministic;
- v7.2 fictional PR response is byte-for-byte deterministic;
- no current timestamp, random number or live network lookup participates in those outputs.

The v7.2 Fortran parser also rejects duplicate required fields, malformed records, missing metadata and percentages outside `0..100`.

## Checks

Run:

```sh
make check
```

The suite compiles the Ada, Fortran and COBOL components; exercises the due-process branches and input hardening; preserves colliding receipt IDs; validates the v7.1 SHA-256-bound incident projection and deterministic replay; verifies the v7.2 factual-attribution headers, conditional jokes and malformed-specimen rejection; and retains the preserved v6 AI/1440 Python regression suite.

The GitHub Actions names remain an important part of the scientific method:

```text
CI Passed (Mainframe Still Disappointed)
Enterprise Reliability (Cloud Still Concerned)
Public Relations (Nothing Further to Add)
```

Feature-branch pushes no longer intentionally run the same workflow twice: `push` is restricted to `main`, while pull requests use `pull_request` checks.

## Previous offences

v6 AI/1440 remains rebuildable:

```sh
make legacy-v6
```

That recreates the 1,474,560-byte FAT12 governance floppy. The exact pre-v7 source is preserved beneath `editions/v6-ai1440/original/`.

v5 HERESY/64 and earlier editions remain beneath `editions/` and are not silently rewritten to satisfy current tests.

## Architectural findings

```text
AI SAFETY LAYER:
AN IF STATEMENT WITH DOCUMENTATION

POLICY ENGINE:
FORTRAN HAS ENTERED THE CHAT

USER EXPERIENCE:
COBOL PRINTED THE MISSING FIELD

ENTERPRISE RELIABILITY:
FORTRAN HAS IDENTIFIED THE COIN

STATUS PAGE:
COBOL HAS READ IT CAREFULLY

PUBLIC RELATIONS:
FORTRAN HAS ANSWERED A NEARBY QUESTION

FACT CHECKING:
THE PUNCHLINE HAS A PRECONDITION

EXPLAINABLE AI:
THERE IS NO AI AND YET SOMEHOW IT EXPLAINS ITSELF
```

## The theorem

```text
SPECIFICALLY:
    MUST BE FOLLOWED BY SOMETHING SPECIFIC.

A STATUS SNAPSHOT
IS NOT A ROOT-CAUSE ANALYSIS.

FIFTY PERCENT ERROR RATE
IS NOT A GENTLE BREEZE.

A FICTIONAL PR RESPONSE
IS NOT AN ACTUAL PR RESPONSE.

A PUNCHLINE WITHOUT EVIDENCE
IS JUST A BUG WITH TIMING.

ADA + FORTRAN + COBOL
SHOULD NOT BE WINNING THIS COMPARISON.

AND YET.
```
