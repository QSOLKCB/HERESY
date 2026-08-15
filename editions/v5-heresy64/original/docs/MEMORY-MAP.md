# Memory map

| Range | Purpose |
| --- | --- |
| `$00F7`–`$00FC` | VIDEOD zero-page pointers |
| `$0801`–`$080C` | BASIC `10 SYS2061` launcher |
| `$080D`–`$080F` | fixed boot trampoline |
| `$0810`–`$082A` | stable kernel jump table |
| `$082B`–`$0970` | 326-byte kernel core |
| `$0971`–`$1D2E` | boot, services, apps, read-only data |
| `$3000`–`$37FF` | copied character set |
| `$4000`–`$4FFF` | sixteen brokerable 256-byte pages |
| `$C000`–`$C267` | IPC ring and linked service state |
| `$D000`–`$DFFF` | I/O/character ROM window |
| `$FFBA`–`$FFE4` | Commodore KERNAL jump-table calls |

The PRG loads at `$0801`, ends at `$1D2E`, and occupies 5,424 bytes including
its two-byte load address.

## BSS

The largest BSS object is the 256-byte IPC ring. Notes receives a 161-byte
buffer for a 160-byte document plus terminator. The directory cache holds five
fixed sixteen-byte names. No heap exists, so fragmentation has been deprecated
with extreme prejudice.

## Display

VIDEOD uses the standard screen at `$0400` and colour RAM at `$D800`. It copies
two kilobytes of character ROM to `$3000` and selects that charset through
`$D018`. The demo changes border/background colours at six bounded raster
positions.
