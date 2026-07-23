# HERESY agent rules

These rules apply to every file and future coding agent in this repository.

## Product identity

HERESY is an anthology of executable software blasphemy. Each edition must
combine languages, runtimes, media or build systems in a technically real,
deliberately disproportionate and reproducible way.

The joke must never depend on fake output, inaccessible controls, broken builds
or misleading claims.

## Current main edition

The repository root is HERESY v3: Cloud-Native Microservices on an EBCDIC
Punched Card.

- A bounded JCL parser approves the bundled job.
- A COBOL `DATA DIVISION` defines the exact 72-column request record.
- Columns 73–80 carry an eight-digit punched-card sequence.
- The complete 80-column record round-trips through EBCDIC code page 037.
- A shuffled three-card deck is sorted by its physical sequence columns.
- A FORTRAN-style computed `GOTO` table determines the API response.
- An Ada-derived policy turns faults into an 80-character recovery ceremony.
- The browser interface visualises the same card that the pipeline executes.

Every source layer must materially affect the result. Decorative terminal output
is not an implementation.

## Non-negotiable constraints

- Production `dist/` must not exceed 368,640 bytes: one 360 KB 5¼-inch floppy.
- The built application must work offline.
- No telemetry, analytics, cloud service, CDN, external font or remote asset.
- Preserve semantic HTML, keyboard access, focus visibility and reduced-motion
  compatibility.
- No arbitrary user-supplied JCL, COBOL, FORTRAN, Ada or JavaScript execution.
- Bound all parsers by fixed bundled source, fixed grammar and finite work.
- Request cards must be exactly 80 characters.
- COBOL data fields must total exactly 72 characters.
- Card sequence fields must occupy columns 73 through 80.
- EBCDIC conversion must reject characters outside the deliberately supported
  code-page-037 subset rather than guess.
- Do not add a dependency for behaviour clearer and smaller in local code.
- Pin direct dependencies, commit the lockfile and use `npm ci` in verification.
- Every new edition must retain reproducible checks proving the stunt executes.

## Edition preservation

Never overwrite an earlier edition. Preserve the exact historical files beneath
`editions/<edition>/original/`, including source, build instructions,
attribution and citation metadata.

If historical defects must be repaired for current execution, keep a separately
documented runnable repair beside the immutable snapshot. Never silently rewrite
the archival copy.

- v2 React-inside-BASIC-inside-React lives under
  `editions/v2-react-in-basic-in-react/`.
- v1 C-inside-Rust-inside-C lives under `editions/v1-c-in-rust-in-c/`.

## Required checks

Before reporting completion, run:

```sh
npm ci
npm run check
```

For the preserved v2 edition also run:

```sh
cd editions/v2-react-in-basic-in-react/original
npm ci
npm run check
```

For the preserved v1 edition also run:

```sh
cd editions/v1-c-in-rust-in-c
cargo run -q
./target/heresy_c/heresy_exe
```

Do not hide failing checks. CI may pass while sanity fails; the build itself may
not.
