# HERESY agent rules

These rules apply to every file and future coding agent in this repository.

## Product identity

HERESY is an anthology of executable software blasphemy. Each edition must
combine languages, runtimes, media, or build systems in a technically real,
deliberately disproportionate, and reproducible way.

The joke must never depend on fake output, inaccessible controls, broken builds,
or misleading claims. Satire targets software choices, infrastructure culture,
and professional habits, never a contributor's identity.

## Current main edition

The repository root is HERESY v5: HERESY/64.

- It is a native Commodore 64 desktop distributed as both PRG and D64.
- A cooperative 6510 microkernel owns scheduling, IPC, and sixteen memory pages.
- Messages are fixed eight-byte records in a bounded 32-slot ring.
- Hardware is isolated behind INPUTD, VIDEOD, DISKD, and AUDIOD services.
- Files, Notes, Calculator, System, and the FORCEOS '38 demo are applications.
- Notes uses a recoverable 1541 scratch/write/scratch/rename transaction.
- The demoscene application uses genuine VIC-II raster timing and SID audio.
- Production has no runtime dependency, package manager, network, or telemetry.

## Service ownership

- `src/kernel/` alone owns IPC, service registration, and page allocation.
- `src/servers/video.s` alone owns VIC-II, screen RAM, colour RAM, and charset.
- `src/servers/audio.s` alone owns SID registers.
- `src/servers/input.s` alone polls keyboard and joystick hardware.
- `src/servers/disk.s` alone calls KERNAL disk-channel routines.
- Applications may call documented video drawing helpers, but may not access
  VIC-II, SID, CIA, screen RAM, colour RAM, or disk KERNAL entry points.
- Every service handler must return promptly. The video raster effect may wait
  for bounded raster positions, but no service may busy-loop indefinitely.

## Non-negotiable constraints

- The complete PRG must remain below 64 KiB and load on an unexpanded C64.
- Kernel core machine code must remain below 4 KiB.
- The D64 must be a standard 35-track, 174,848-byte disk image.
- Build artifacts must be deterministic.
- Do not add generated binary blobs to source.
- Do not claim emulation where native 6510 code executes.
- Do not introduce a dependency for behaviour clearer and smaller in local code.
- Earlier editions remain byte-for-byte preserved under
  `editions/<edition>/original/`.
- Satirical copy about LCOS PR #38 must stay focused on forced architecture,
  infrastructure bloat, and tool-as-religion thinking.

## Required checks

Before reporting completion, run:

```sh
make check
```

Also run the preserved editions where the required toolchains are available:

```sh
make check-editions
```

Do not hide a skipped or failing check.
