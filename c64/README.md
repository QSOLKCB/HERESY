# HERESY v5.0.0 release notes

## HERESY/64: the immutable desktop that fits before the lockfile

v5 replaces the browser-based current edition with a native Commodore 64
microkernel desktop while preserving v4 byte-for-byte under `editions/`.

### Highlights

- 5,424-byte native PRG and deterministic standard D64.
- 326-byte cooperative 6510 microkernel.
- Eleven services, 32 fixed eight-byte IPC slots, and sixteen memory pages.
- Files, Notes, Calculator, and System applications.
- Recoverable 1541 note persistence without in-place `SAVE@`.
- Keyboard and joystick support.
- Native runtime tests that execute the linked 6502 instructions.
- FORCEOS '38, a real VIC-II/SID demoscene satire of infrastructure religion.

### FORCEOS '38

The new fifth app responds to LCOS PR #38 with raster bars, a scrolling
manifesto, and a SID arpeggio. NixOS becomes the new declarative religion,
Arch BTW becomes the Old Testament, and Linux From Scratch is rejected for
lacking `flake.lock`.

The satire targets forced architecture, bloated infrastructure, and the modern
developer mindset that turns configuration into moral virtue.

### Verification

`make check` reconstructs the D64, validates its file chain, measures kernel
symbols, enforces hardware ownership, compares v4 with its release tag, and
executes all five apps through a dependency-free 6502 runtime.

Small is beautiful. Bloat is unholy. Infrastructure is not a personality.
