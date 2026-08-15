# THE HERESY/64 MANIFESTO

Modern software routinely requires more machinery to display a form than a
1980s home computer required to become an operating environment.

HERESY/64 protests by being useful.

It boots. It launches applications. It reads a disk directory. It edits and
recovers a note. It calculates. It accepts a joystick. It draws raster bars and
plays a SID tune. It does those things in 5,424 bytes of native code behind a
326-byte cooperative microkernel.

This is not an argument that every contemporary system belongs on a
Commodore 64. It is an argument that every dependency, daemon, service, layer,
and control plane should have to explain why it exists.

The machine has sixteen brokered pages, so nobody can request “effectively
unlimited” memory in a ticket. IPC records are eight bytes, so architecture
cannot hide inside a payload. There is no network, so telemetry has nowhere to
confess. There is no package manager, so a calculator cannot become a supply
chain.

FORCEOS ’38 gives the infrastructure priesthood its own demoscene liturgy:
NixOS is the new declarative religion, Arch BTW is the Old Testament, flakes
are sacraments, and Linux From Scratch is denied entry for arriving without a
lockfile. The target is not a distribution or its users. The target is the
modern developer mindset that mistakes enforced preferences for engineering
necessity.

Use powerful tools when the problem earns them. Delete them when it does not.

Small is beautiful.

Bloat is unholy.

Infrastructure is not a personality.
