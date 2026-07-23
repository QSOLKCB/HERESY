# HERESY agent rules

These rules apply to every file and future coding agent in this repository.

## Product identity

HERESY is an anthology of executable software blasphemy. Each edition must combine languages, runtimes or build systems in a technically real, deliberately disproportionate and reproducible way.

The joke must never depend on fake output, inaccessible controls, broken builds or misleading claims.

## Current main edition

The repository root is HERESY v2: React inside Commodore BASIC inside React.

- Outer React hosts the application.
- A bounded BASIC V2-style runtime parses the bundled numbered program.
- BASIC `DATA` bytes reconstruct the component specification.
- An inner React component renders that specification.
- The BASIC layer must materially affect rendered state.

## Non-negotiable constraints

- Production `dist/` must not exceed 1,474,560 bytes.
- The built application must work offline.
- No telemetry, analytics, cloud service, CDN, external font or remote asset.
- Preserve semantic HTML, keyboard access, focus visibility and reduced-motion compatibility.
- No arbitrary user-supplied BASIC, JavaScript or dynamic module execution.
- BASIC `DATA` values must be exact integers from 0 through 255.
- Bound all interpreters by fixed source, fixed grammar and finite work.
- Do not replace the real BASIC transformation with a decorative terminal animation.
- Do not add a dependency for behaviour clearer and smaller in local code.
- Every new edition must retain reproducible checks proving the stunt actually executes.

## Edition preservation

Never overwrite an earlier edition. Move it intact beneath `editions/` with its source, build instructions, attribution and historical DOI or release references.

The original v1 C-inside-Rust-inside-C edition lives under `editions/v1-c-in-rust-in-c/`.

## Required checks

Before reporting completion, run:

```sh
npm run test
npm run build
npm run verify:size
```

For the preserved v1 edition also run:

```sh
cd editions/v1-c-in-rust-in-c
cargo run -q
```

Do not hide failing checks. CI may pass while sanity fails; the build itself may not.
