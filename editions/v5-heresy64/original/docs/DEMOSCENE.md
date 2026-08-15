# FORCEOS ’38

FORCEOS ’38 is a real Commodore 64 demoscene application aimed at the modern
habit of turning infrastructure preference into compulsory doctrine.

The reference is LCOS pull request 38: a proposed switch to NixOS with forced
packages, compositor policy, branding, and system choices. HERESY’s response
does not need a distribution. It needs six raster bars and approximately three
voices’ worth of theological confidence squeezed through one SID voice.

## Effects

- `DEMOD` advances a frame counter and a 252-character scroll position.
- Every other tick advances the scrolling manifesto.
- Every eighth frame requests the next note of an eight-tone arpeggio.
- `VIDEOD` draws a 40-column window from the wrapped text, then waits for six
  real VIC-II raster positions and changes border/background colours.
- `AUDIOD` alone writes SID frequency, envelope, gate, and volume registers.

The demo app contains no VIC-II or SID register references. Its purity is
enforced by the same IPC it mocks modern developers for rediscovering over
HTTP.

## The joke

Arch’s “BTW” identity becomes the Old Testament. NixOS becomes the new
declarative religion. Flakes become sacraments. Linux From Scratch is rejected
for failing to bring a `flake.lock`. systemd is promoted from PID 1 to provider
of the afterlife.

The target is forced architecture, bloat, and tool-as-personality thinking.
The implementation is intentionally competent: the raster waits are bounded,
the scroller wraps correctly, audio is service-owned, mute works, and F1
returns home.
