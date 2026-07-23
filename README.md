# HERESY v4.0.0 — The Modern Developer Simulator

[![CI: Passed (Industry Failed)](https://img.shields.io/badge/CI-passed_(industry_failed)-red.svg)](https://github.com/QSOLKCB/HERESY/actions)
[![Database: COBOL](https://img.shields.io/badge/database-COBOL-darkgreen.svg)](#the-cobol-database)
[![Dependencies: 0](https://img.shields.io/badge/dependencies-0-yellow.svg)](#run-it)
[![Budget: 128 KiB](https://img.shields.io/badge/budget-128_KiB-black.svg)](#the-size-gate)

> **“I replaced the modern database with a COBOL record file because rows had
> become insufficiently rectangular.”**

HERESY v4 is useful software built as a protest against software bloat. It is a
deterministic architecture-budget simulator: take a tiny product brief, make
seven engineering decisions, and receive an exportable receipt for the
payload, dependencies, cold start, cloud bill, risk, meetings, delivery time,
user value, résumé value and total bloat.

The jokes are pointed, but the tool is serious enough to use in an architecture
workshop. Its custom mode accepts a real project brief and an estimate of the
irreducible payload. It does not declare modern technology immoral. It asks a
more awkward question: **is this technology proportionate to the user's
problem?**

The numbers are opinionated relative weights for comparison, not vendor
quotes, capacity forecasts or financial advice. Determinism makes two designs
comparable; satire makes the conversation harder to avoid.

No framework. No package manager. No build step. No network request. No account.
The database is COBOL.

## Run it

Open [`index.html`](index.html) directly in a browser. That is the complete
installation procedure.

For a local HTTP server:

```sh
make serve
```

Then visit `http://localhost:8000`.

Complete verification:

```sh
make check
```

The check parses the actual COBOL, exercises the simulator and database,
mutates a record to prove corruption is detected, verifies the punched browser
deck, and enforces the complete 128 KiB production budget.

## What it simulates

Every run begins with a deliberately small requirement:

- show whether an office coffee machine works;
- keep one person's task list;
- display one supplied weather reading;
- multiply quantity by price;
- publish opening hours;
- process leave requests for ten employees; or
- model a custom production brief.

You then choose an interface, service topology, data store, deployment model,
observability regime, delivery process and amount of artificial headcount.
Every option maps to a real record in
[`programs/modern-developer.cob`](programs/modern-developer.cob).

```text
Tiny user requirement
  -> seven architecture decisions
     -> COBOL DATA DIVISION scoring records
        -> deterministic budget calculation
           -> fixed-width COBOL RUN-RECORD
              -> checksum, history and export
```

A restrained coffee-status system currently weighs **29 KiB** with no
dependencies. The maximal transformation weighs **163.1 MiB**, carries 1,245
dependencies, and achieves **41,751×** the essential payload. Both figures are
derived from the same COBOL rules and protected by tests.

## The COBOL database

The database is not a novelty label wrapped around JSON.

`RUN-RECORD` in the COBOL `DATA DIVISION` is the database schema. It defines 22
fields and every physical width:

```cobol
       01 RUN-RECORD.
          05 RUN-ID          PIC X(16).
          05 CREATED-UTC     PIC X(20).
          05 SCENARIO        PIC X(12).
          05 SEED-VALUE      PIC 9(10).
          ...
          05 DECISIONS       PIC X(96).
          05 RECORD-VERSION  PIC X(1).
          05 ESSENTIAL-KB    PIC X(9).
          05 BASE-DAYS       PIC X(6).
          05 RESERVED        PIC X(16).
          05 BRIEF-TEXT      PIC X(96).
          05 CHECKSUM        PIC X(8).
```

Each saved simulation becomes exactly one **379-character fixed record**.
Numeric values are left-zero-padded to `PIC 9(...)`; text is right-space-padded
to `PIC X(...)`; overflow is rejected instead of truncated. An eight-character
FNV-1a checksum covers every preceding character.

The versioned scenario fields reclaim spare space from the oversized decision
block, so the record remains 379 characters and existing v1 rows remain
physically readable. New rows preserve custom payload and base-day inputs
exactly. Legacy custom rows report those unknowable values as unavailable
instead of reverse-engineering fictional precision.

The browser's `localStorage` is merely a virtual disk holding newline-separated
fixed records. There is no JSON persistence, SQL, IndexedDB, ORM, migration
framework, database server, connection pool or venture-backed control plane.

The ledger supports:

- append, list, inspect and delete;
- full `.dat` export and import;
- backward-compatible v1 ledger import;
- record-width and checksum validation;
- exact custom-input recall for versioned rows;
- malformed-row quarantine without silent normalisation;
- duplicate `RUN-ID` refusal; and
- corrupted-record quarantine.

This is appropriate for an offline, single-user teaching tool. It is not a
claim that flat files should replace PostgreSQL in concurrent financial
systems. Satire is funniest when the technical boundary is honest.

## The COBOL also runs the simulator

The same source contains 28 `RULE-*` groups. Each rule supplies nine signed
cost fields:

```cobol
       01 RULE-KUBERNETES.
          05 RULE-ID         PIC X(16) VALUE 'KUBERNETES'.
          05 SIZE-KB         PIC S9(7) VALUE +4000.
          05 DEPENDENCIES    PIC S9(7) VALUE +190.
          05 COLD-MS         PIC S9(7) VALUE +1100.
          05 CLOUD-CENTS     PIC S9(9) VALUE +38000.
          05 RISK-POINTS     PIC S9(7) VALUE +35.
          05 MEETINGS        PIC S9(7) VALUE +10.
          05 VALUE-POINTS    PIC S9(7) VALUE +6.
          05 RESUME-POINTS   PIC S9(7) VALUE +50.
          05 SHIP-DAYS       PIC S9(7) VALUE +28.
```

A small bounded parser reads those declarations. The browser executes a
generated, committed copy of the exact COBOL source so it can also work from
`file://` without `fetch`. `node scripts/punch-cobol.js --check` proves the
browser deck has not drifted from the source.

This project does not pretend to ship a COBOL compiler in 19 KiB. It executes
the declared `DATA DIVISION` subset required by the product, validates its
shape, and makes those values materially govern scoring and persistence.

## The size gate

The entire production application must fit in **131,072 bytes**: the amount of
RAM in the original 128K Macintosh. That includes:

- HTML;
- CSS;
- the full punched COBOL source;
- simulator engine;
- fixed-record database; and
- browser interface.

The current application is about **86 KiB**, or 1,097 theoretical punch cards.
Source documentation and tests do not count as production payload. A dependency
cannot hide inside a minifier because there is no dependency and no minifier.

## Useful outputs

- A live consequence budget after every decision.
- A deterministic report reproducible from the same seed.
- Markdown and JSON architecture receipts.
- Print-friendly workshop results.
- Persistent run history.
- Portable, checksummed COBOL `.dat` ledgers.
- A custom mode for real project discussions.

No analytics leave the machine. In fact, nothing leaves the machine unless the
user presses Export.

## Files

```text
index.html                       directly runnable application shell
style.css                        asset-free industrial stationery
programs/modern-developer.cob    scoring rules and database copybook
src/cobol-deck.js                generated browser-readable card deck
src/engine.js                    deterministic architecture calculator
src/cobol-database.js            fixed-record persistence engine
src/app.js                       accessible classic-script interface
scripts/punch-cobol.js           source-to-browser card punch
scripts/selftest.js              execution and corruption tests
scripts/verify-size.js           128 KiB production gate
editions/                        preserved previous offences
```

## Editions

### v4.0.0 — Modern Developer Simulator

The repository root. Useful offline software whose rules and database are
defined by COBOL because modern persistence lacked sufficient beige.

### v3.0.0 — Cloud-Native Microservices on an EBCDIC Punch Card

Preserved byte-for-byte at
[`editions/v3-cloud-native-punch-card/`](editions/v3-cloud-native-punch-card/).
JCL → punch card → EBCDIC → COBOL → FORTRAN → Ada → JSON.

### v2.0.0 — React inside BASIC inside React

Preserved at
[`editions/v2-react-in-basic-in-react/`](editions/v2-react-in-basic-in-react/).
Commodore BASIC V2-style `DATA` bytes reconstruct a React specification.

### v1.0.0 — C inside Rust inside C

Preserved at [`editions/v1-c-in-rust-in-c/`](editions/v1-c-in-rust-in-c/).
Rust compiles C that generates and compiles more C because direct compilation
lacked narrative tension.

## Licence

MIT licensed. Historical attribution and citation metadata remain with each
preserved edition.

> Modern software is not automatically bloated. But if displaying a phone
> number requires service discovery, the phone may be trying to escape.
