# HERESY v2.0.0 — React inside BASIC inside React

[![CI: Passed (Sanity Failed)](https://img.shields.io/badge/CI-passed_(sanity_failed)-red.svg)](https://github.com/QSOLKCB/HERESY/actions)
[![Status: Standards Compliant](https://img.shields.io/badge/status-standards_compliant-black.svg)](#)
[![Budget: One Floppy](https://img.shields.io/badge/budget-1.44_MB-yellow.svg)](#)

> **Modern problems require 1982 middleware.**

HERESY is an anthology of executable software blasphemy. The main edition is a real React application containing a bounded Commodore BASIC V2-style interpreter. BASIC reconstructs a component specification from numeric `DATA` statements, and React renders that result as an inner React component.

```text
Outer React host
  -> bounded BASIC V2 runtime
     -> DATA byte payload
        -> inner React component
           -> one avoidable button
```

The middle layer is not a fake terminal animation: BASIC parsing and payload reconstruction determine the component rendered by React.

## Run v2

```sh
git clone https://github.com/QSOLKCB/HERESY.git
cd HERESY
npm ci
npm run dev
```

Production verification:

```sh
npm run check
```

The committed `package-lock.json` fixes the complete npm dependency graph, and CI uses `npm ci` rather than resolving a fresh toolchain on every run.

The production `dist/` directory must remain at or below **1,474,560 bytes**, the capacity of a 1.44 MB high-density floppy disk.

## What the app proves

- React can host an intentionally tiny, deterministic BASIC runtime.
- BASIC `DATA` bytes can reconstruct the specification consumed by another React component.
- The stunt remains semantic, keyboard accessible, responsive and offline after build.
- Architectural profanity is not permission for broken engineering.
- One virtual DOM was apparently insufficient.

## Editions

### v2.0.0 — React inside BASIC inside React

The repo root. A standards-conscious React artwork in which Commodore-style BASIC generates the data that becomes inner React UI. Root citation metadata is maintained in [`CITATION.cff`](CITATION.cff).

### v1.0.0 — C inside Rust inside C

Preserved at [`editions/v1-c-in-rust-in-c/`](editions/v1-c-in-rust-in-c/).

```sh
cd editions/v1-c-in-rust-in-c
cargo run -q
./target/heresy_c/heresy_exe
```

The v1 directory contains both:

- a byte-for-byte DOI-era snapshot under `original/`;
- a separately documented runnable repair used by current CI.

## Safety and determinism

- No arbitrary user program execution.
- No network access is needed by the built application.
- BASIC accepts only the fixed bundled program.
- `DATA` values must be exact bytes from 0 through 255.
- The reconstructed payload is checked before rendering.
- Exact dependency versions and transitive integrity hashes are committed.
- CI runs the self-test, production build, floppy-size gate and both v1 executable paths.

## Files

```text
src/main.jsx                 outer and inner React components
src/basic.js                 bounded BASIC parser and payload
src/style.css                asset-free industrial presentation
package-lock.json            locked complete npm dependency graph
scripts/selftest.mjs         repeatability and identity checks
scripts/verify-size.mjs      1.44 MB build gate
editions/v1-c-in-rust-in-c/  runnable v1 repair and exact historical snapshot
```

## Licence and lineage

MIT licensed. The v1 concept and its Stack Overflow lineage remain documented in the preserved edition and original Zenodo record.

> “I rendered React through BASIC because direct component creation lacked theological depth.”
