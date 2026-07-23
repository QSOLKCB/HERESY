# HERESY agent rules

These rules apply to every file and future coding agent in this repository.

## Product identity

HERESY is an anthology of executable software blasphemy. Each edition must
combine languages, runtimes, media or build systems in a technically real,
deliberately disproportionate and reproducible way.

The joke must never depend on fake output, inaccessible controls, broken builds
or misleading claims.

## Current main edition

The repository root is HERESY v4: The Modern Developer Simulator.

- It is a genuinely useful architecture-budget teaching tool.
- It accepts bundled scenarios and a bounded custom production brief.
- Seven engineering choices produce deterministic consequence metrics.
- All 28 choice records and their nine numeric metrics come from
  `programs/modern-developer.cob`.
- The COBOL `RUN-RECORD` is the actual persistence schema.
- Saved runs are 379-character fixed records with FNV-1a checksums.
- The database supports append, list, delete, import and export.
- `localStorage` is only the virtual disk; do not persist JSON.
- The application opens directly from `index.html`.

Every source layer must materially affect the result. Decorative terminal
output is not an implementation.

## Non-negotiable constraints

- Production files must total no more than 131,072 bytes.
- Production has no package manager, framework, build step or dependency.
- Use classic directly loaded scripts. Do not introduce module loading.
- The built application must work offline and from `file://`.
- No telemetry, analytics, cloud service, CDN, external font or remote asset.
- Preserve semantic HTML, keyboard access, focus visibility, print output and
  reduced-motion compatibility.
- Do not use `eval`, `Function` or arbitrary user-supplied code execution.
- Bound custom text and all COBOL parsing by fixed grammar and finite work.
- COBOL source lines must not exceed column 72.
- The committed browser card deck must exactly match the COBOL source.
- `RUN-RECORD` widths govern every database field.
- Reject record overflow, bad widths, invalid numerics and checksum failure.
- Do not replace the COBOL database with JSON, SQL, IndexedDB or an ORM.
- Do not add a dependency for behaviour clearer and smaller in local code.
- Every new edition must retain reproducible checks proving the stunt executes.

## Edition preservation

Never overwrite an earlier edition. Preserve the exact historical files beneath
`editions/<edition>/original/`, including source, build instructions,
attribution and citation metadata.

If historical defects must be repaired for current execution, keep a separately
documented runnable repair beside the immutable snapshot. Never silently rewrite
the archival copy.

- v3 lives under `editions/v3-cloud-native-punch-card/`.
- v2 lives under `editions/v2-react-in-basic-in-react/`.
- v1 lives under `editions/v1-c-in-rust-in-c/`.

## Required checks

Before reporting completion, run:

```sh
make check
```

For preserved v3:

```sh
cd editions/v3-cloud-native-punch-card/original
npm ci
npm run check
```

For preserved v2:

```sh
cd editions/v2-react-in-basic-in-react/original
npm ci
npm run check
```

For preserved v1:

```sh
cd editions/v1-c-in-rust-in-c
cargo run -q
./target/heresy_c/heresy_exe
```

Do not hide failing checks. CI may pass while sanity fails; the build itself may
not.
