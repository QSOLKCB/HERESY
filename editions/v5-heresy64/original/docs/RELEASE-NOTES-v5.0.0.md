# HERESY v5.0.0 — release notes

## HERESY/64: no web, no cloud, no alibi

v5 replaces the current browser edition with a native Commodore 64
microkernel desktop while preserving v4 byte-for-byte under `editions/`.

### Highlights

- 5,424-byte native PRG and deterministic standard 174,848-byte D64.
- 326-byte cooperative 6510 microkernel.
- Eleven services, 32 fixed eight-byte IPC slots, and sixteen brokered pages.
- Files, Notes, Calculator, and System applications.
- Recoverable device-8 Notes persistence without in-place `SAVE@`.
- Keyboard and joystick navigation.
- Dependency-free native runtime tests that execute the linked 6502 code.
- FORCEOS ’38, a genuine VIC-II/SID demoscene satire of infrastructure
  religion.

### FORCEOS ’38

The new fifth application responds to LCOS PR 38 with raster bars, a scrolling
manifesto, and a SID arpeggio. NixOS becomes the new declarative religion,
Arch BTW becomes the Old Testament, Linux From Scratch is rejected for lacking
`flake.lock`, and systemd is assigned the afterlife.

The satire targets forced architecture, bloated infrastructure, and the modern
developer mindset that turns configuration into moral virtue.

### Production characteristics

The shipped program has no runtime dependencies, network access, database,
package manager, telemetry, heap, or update daemon. It boots on an unexpanded
C64, reads a real 1541 directory, saves and recovers a note, performs 8-bit
arithmetic, accepts keyboard and joystick input, and drives VIC-II and SID.

### Verification

`make check` reconstructs the D64, validates its chain and BAM, measures linker
symbols, enforces hardware ownership, compares v4 with its release tag, proves
two clean builds are identical, and executes all five applications in a
dependency-free 6502 runtime.

Artifact SHA-256:

```text
HERESY64.PRG
9fe2fbd2e51d9806f071e6e45ab5991ddfebfc9868806a5569588cfae61edae3

HERESY64.D64
ffeb6216f577a9e9fb6d6295cde4f1f4f9892bcf400918041d7d836d765193b0
```

Small is beautiful. Bloat is unholy. Infrastructure is not a personality.
