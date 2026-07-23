# HERESY v3.0.0 — Cloud-Native Microservices on an EBCDIC Punch Card

[![CI: Passed (Industry Failed)](https://img.shields.io/badge/CI-passed_(industry_failed)-red.svg)](https://github.com/QSOLKCB/HERESY/actions)
[![Runtime: REST/1959](https://img.shields.io/badge/runtime-REST%2F1959-black.svg)](#)
[![Budget: 360 KB](https://img.shields.io/badge/budget-360_KB-yellow.svg)](#)
[![Containers: Absolutely Not](https://img.shields.io/badge/containers-absolutely_not-darkgreen.svg)](#)

> **“I routed the cloud-native microservice through an EBCDIC punch card
> because JSON lacked institutional trauma.”**

HERESY v3 is an offline browser application in which every “serverless” REST
request is:

1. authorised by a bounded **JCL** job;
2. packed into a strict **COBOL `DATA DIVISION`** record;
3. placed in columns 1–72 of an **80-column punched card**;
4. sequenced in columns 73–80 and encoded as **EBCDIC code page 037**;
5. routed by a **FORTRAN computed `GOTO`**; and
6. treated by **Ada** as a probable inertial-guidance emergency.

All of this occurs to return one small JSON object that could have been written
directly in six lines.

```text
Browser edge-ish form
  -> JCL change-control ritual
     -> shuffled 80-column card deck
        -> EBCDIC code-page-037 round trip
           -> COBOL fixed-width record
              -> FORTRAN computed GOTO
                 -> Ada defense-grade panic
                    -> one REST response, manually retyped
```

The production build must fit within **368,640 bytes**, the formatted capacity
of a 360 KB 5¼-inch floppy. The previous 1.44 MB allowance was judged an
unacceptable lifestyle upgrade.

## Run v3

```sh
git clone https://github.com/QSOLKCB/HERESY.git
cd HERESY
npm ci
npm run dev
```

Complete verification:

```sh
npm run check
```

That command validates physical source columns, executes deterministic pipeline
tests, builds the offline application and enforces the 360 KB gate.

## The offence is real

This is not a terminal animation pretending to be a mainframe.

- `programs/HERESY3.jcl` is parsed for the job, program and card allocations.
- `programs/mainframe.cob` supplies the actual `PIC` field order and widths.
- The COBOL fields must total exactly 72 columns.
- The request occupies one real 80-character record with an eight-digit
  sequence field.
- That record round-trips through an explicit EBCDIC code-page-037 codec.
- The deck deliberately arrives in sequence 30, 20, 10 and is physically
  sortable back into 10, 20, 30.
- `programs/router.f` supplies the route names, computed-`GOTO` labels and
  response text.
- `programs/failsafe.adb` supplies the required recovery-string length and
  determines whether ordinary exceptions become missile incidents.
- The on-screen punch pattern is derived from the exact executed card.

The project does **not** claim to contain z/OS, a complete COBOL compiler, a
FORTRAN compiler or an Ada runtime. It implements strict, bounded interpreters
for the committed source fragments needed by this specific artwork. The satire
is absurd; the execution claims are deliberately boring and precise.

## Modern platform capabilities

| Industry term | HERESY v3 implementation |
|---|---|
| Serverless | Finance owns the server |
| Edge compute | Desk nearest the fire exit |
| Autoscaling | Doris gets another chair |
| Service mesh | Shoebox with dividers |
| Observability | Brenda watches the green light |
| Immutable infrastructure | You cannot unpunch a hole |
| Blockchain | Cards stacked in chronological order |
| Machine learning | Operator learns the machine |
| CI/CD | Card Intake / Card Disposal |
| Zero trust | Lowercase rejected on sight |
| Eventual consistency | Ledgers agree after the Q4 audit |
| AI coding assistant | Laminated flowchart; accuracy improved |

The system contains zero containers, makes zero network requests after build
and has a 0 ms cold start. Its warm start has taken approximately 67 years.

## Controlled failure

Press **CAUSE CONTROLLED ABEND** to submit an unapproved change ticket.

COBOL rejects the record, Ada assumes missile involvement and the interface
locks behind an exact 80-character override kept in a sealed envelope beside
the printer. No missile system is present. Procedure does not permit this fact
to influence procedure.

## Column governance

COBOL and FORTRAN source is limited to 72 columns. JCL and Ada receive a lavish
80. The card linter fails the build if code escapes its physical allocation:

```text
CARD DECK REJECTED
router.f:12: 76 columns; 4 characters are hanging into the future
Prettier has been reassigned to Payroll.
```

It does not silently truncate production code. Even software satire should not
make the repository genuinely useless.

## Files

```text
programs/HERESY3.jcl         bounded job-control source
programs/mainframe.cob       72-column COBOL request schema
programs/router.f            FORTRAN computed-GOTO API gateway
programs/failsafe.adb        Ada-derived fault policy
src/mainframe.js             card, EBCDIC and execution kernel
src/main.js                  accessible offline interface
src/style.css                asset-free mainframe/card presentation
scripts/punch-card-linter.mjs
scripts/selftest.mjs         deterministic execution and failure tests
scripts/verify-size.mjs      360 KB production gate
editions/                    preserved earlier offences
```

## Editions

### v3.0.0 — Cloud-Native Microservices on an EBCDIC Punch Card

The repository root. JCL → punch card → EBCDIC → COBOL → FORTRAN → Ada → JSON.

### v2.0.0 — React inside BASIC inside React

Preserved at
[`editions/v2-react-in-basic-in-react/`](editions/v2-react-in-basic-in-react/).
Commodore BASIC V2-style `DATA` bytes reconstruct the specification rendered by
an inner React component.

### v1.0.0 — C inside Rust inside C

Preserved at [`editions/v1-c-in-rust-in-c/`](editions/v1-c-in-rust-in-c/).
Rust compiles C that generates and compiles more C because a normal executable
lacked recursive shame.

## Licence

MIT licensed. Historical attribution and citation metadata remain with each
preserved edition.

> A 300 MB coffee app is no longer software. It is a hostage negotiation with
> a progress bar.
