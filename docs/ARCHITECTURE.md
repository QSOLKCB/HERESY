# Architecture

HERESY/64 is a native Commodore 64 program, not a browser simulation. A BASIC
stub executes a fixed trampoline at `$080D`; the trampoline enters a
cooperative 6510 microkernel.

## Boot

The kernel clears its tables, registers eleven handlers, allocates one
256-byte page to every non-kernel service, queues ten initialisation messages,
then enters a dispatch loop. A changed KERNAL jiffy produces tick messages for
input and the demo. All other work is event-driven.

## Kernel policy

The 326-byte core provides registration, bounded IPC, cooperative dispatch,
page allocation/free, tick inspection, pending-message inspection, and a
stable jump table. It contains no filesystem, widget toolkit, driver model,
JSON parser, dependency injection container, or inspirational YAML.

There are sixteen pages in the brokered pool. The ten non-kernel services each
receive one at boot. State remains statically linked because a real C64 does
not need a service mesh to discover itself.

## Hardware ownership

Hardware access is separated by source-level capability boundaries:

- `INPUTD` owns keyboard and joystick reads.
- `VIDEOD` owns screen RAM, colour RAM, VIC-II, charset setup, and drawing.
- `DISKD` owns file and command channels to device 8.
- `AUDIOD` owns SID registers.

Applications request those effects with fixed messages. Verification rejects
hardware symbols outside their owner.

## Applications

`DESKTOPD` maps keyboard or joystick selection to one of five views.
`FILESD`, `NOTESD`, `CALCD`, and `SYSTEMD` own their application state.
`DEMOD` sequences the demoscene but cannot touch VIC-II or SID directly.

Notes persistence is a deliberately small transaction:

1. scratch stale `HERESY NEW`;
2. write the current note to `HERESY NEW,S,W`;
3. close and verify the channel;
4. scratch `HERESY NOTE`;
5. rename `HERESY NEW` to `HERESY NOTE`.

Load probes `HERESY NEW` before `HERESY NOTE`, preserving recovery from a
power loss between write and rename.

## Trust boundary

The C64 has no MMU. Isolation is therefore enforced by explicit ownership,
link-time layout, code review, and automated source checks. This is less
fashionable than claiming an internal HTTP boundary is security, but it has
the advantage of being honest.
