# HERESY v5.0.0 — HERESY/64

> “I replaced the modern web stack with a 326-byte microkernel because users
> had already installed the operating system in 1982.”

HERESY/64 is a useful, native Commodore 64 desktop squeezed into a **5,424-byte
PRG**. It has a cooperative 6510 microkernel, fixed-record IPC, brokered memory,
four practical applications, recoverable 1541 persistence, keyboard and
joystick input, and a real VIC-II/SID demoscene program.

There is no browser. There is no package manager. There is no network request,
database daemon, container, control plane, telemetry collector, JavaScript
framework, declarative operating-system religion, or YAML file describing the
YAML file.

The complete executable is smaller than many modern applications’ cookie
banners.

## Run it

Use either checked-in production artifact:

- [`dist/HERESY64.PRG`](dist/HERESY64.PRG) — 5,424 bytes
- [`dist/HERESY64.D64`](dist/HERESY64.D64) — standard 35-track 1541 disk

Attach the D64 to device 8 in VICE, Denise, or real-compatible hardware, then:

```basic
LOAD"HERESY64",8,1
RUN
```

The PRG can also be autostarted directly in an emulator.

| Control | Result |
| --- | --- |
| `1`–`5` | Select Files, Notes, Calc, System, or FORCEOS ’38 |
| `RETURN` / joystick fire | Open selected application |
| `F1` | Return to the desktop |
| Joystick | Move desktop selection |
| `R` | Refresh Files; restart the demo |
| `F3` / `F5` | Save / load Notes |
| `DEL` | Delete a Notes character |
| `T` | Toggle the System theme |
| `M` | Toggle demo music |

## Useful software, pre-bloat

**Files** reads and displays a device-8 directory through ordinary Commodore
KERNAL channels.

**Notes** edits a 160-byte document and persists it on a 1541. It avoids the
unsafe in-place `SAVE@` pattern: scratch stale temp, write `HERESY NEW`, scratch
the old note, then rename the survivor. Loading prefers the temp file, so an
interrupted commit remains recoverable.

**Calculator** performs bounded 8-bit `+`, `-`, `*`, and `/` arithmetic without
downloading an arbitrary-precision package maintained by a left-pad survivor.

**System** reports what the machine actually owns: a kernel, IPC records,
brokered pages, services, and storage. It does not report pod health because
there are no pods to develop feelings.

## The microkernel

The kernel core is **326 bytes** of linked 6510 machine code. It owns only:

- registration for eleven services;
- a bounded ring of 32 fixed eight-byte IPC records;
- allocation of sixteen 256-byte pages;
- cooperative dispatch and a 16-bit tick count.

Everything impolite is isolated behind a service:

| Service | Exclusive responsibility |
| --- | --- |
| `INPUTD` | keyboard and joystick polling |
| `VIDEOD` | VIC-II, screen, colour RAM, charset, drawing |
| `DISKD` | device-8 KERNAL channels and note transactions |
| `AUDIOD` | SID registers and tones |
| `DESKTOPD` | launcher and navigation |
| `FILESD`, `NOTESD`, `CALCD`, `SYSTEMD` | useful applications |
| `DEMOD` | FORCEOS ’38 sequencing through IPC |

Applications cannot casually scribble on hardware. Apparently memory
protection can also be a code-review rule when the entire product is 5 KiB.
See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) and
[`docs/ABI.md`](docs/ABI.md).

## FORCEOS ’38

The fifth application is a genuine C64 demoscene rebuttal to infrastructure as
identity. It uses timed VIC-II raster bars, a 252-character scroller, and a SID
arpeggio—but only by requesting work from `VIDEOD` and `AUDIOD`.

Its doctrinal status screen includes:

```text
MINDSET: CONFIGURATION IS MORAL VIRTUE
INFRASTRUCTURE IS NOT A PERSONALITY
NIXOS IS THE NEW DECLARATIVE RELIGION
ARCH BTW: NOW THE OLD TESTAMENT
LFS REJECTED: MISSING FLAKE.LOCK
PID 1: SYSTEMD NOW PROVIDES AFTERLIFE
SMALL IS BEAUTIFUL. BLOAT IS UNHOLY.
```

The joke targets forced architecture, infrastructure bloat, and the developer
mindset that turns a tool choice into moral virtue—not people or identities.
The technical anatomy is in [`docs/DEMOSCENE.md`](docs/DEMOSCENE.md).

## Build and verify

The only build dependency is [cc65](https://cc65.github.io/) plus Python 3 for
artifact construction and tests.

```sh
make
make check
```

`make check`:

1. validates the PRG, linker symbols, kernel size, and hardware ownership;
2. reconstructs and traverses the standard D64 file chain and BAM;
3. performs two clean builds and demands byte-for-byte determinism;
4. executes the linked 6502 instructions in a dependency-free runtime test;
5. exercises Files, Notes, recovery, Calculator, System, keyboard, joystick,
   VIC-II raster effects, and SID audio;
6. compares the archived v4 root with the immutable `v4.0.0` tag.

Published v5 artifact identities:

```text
HERESY64.PRG
9fe2fbd2e51d9806f071e6e45ab5991ddfebfc9868806a5569588cfae61edae3

HERESY64.D64
ffeb6216f577a9e9fb6d6295cde4f1f4f9892bcf400918041d7d836d765193b0
```

## Source map

```text
cfg/        linker layout
src/kernel cooperative microkernel
src/servers hardware-owning services
src/apps/   desktop, applications, and demo sequencer
scripts/    deterministic D64 builder and native verification
docs/       ABI, architecture, memory map, demo, release notes
dist/       reproducible production PRG and D64
editions/   immutable earlier acts of software misconduct
```

v4 remains byte-for-byte preserved under
[`editions/v4-modern-developer-simulator/original`](editions/v4-modern-developer-simulator/original).
Earlier editions remain beside it.

Small is beautiful. Bloat is unholy. Infrastructure is not a personality.
