#!/usr/bin/env python3
"""Build a deterministic, standard 35-track Commodore 1541 disk image."""

from __future__ import annotations

import pathlib
import sys


SECTORS_PER_TRACK = (
    0,
    *([21] * 17),
    *([19] * 7),
    *([18] * 6),
    *([17] * 5),
)
TRACKS = 35
SECTOR_SIZE = 256
D64_SIZE = sum(SECTORS_PER_TRACK[1:]) * SECTOR_SIZE
INTERLEAVE = 10


def sector_offset(track: int, sector: int) -> int:
    if not 1 <= track <= TRACKS:
        raise ValueError(f"invalid track {track}")
    if not 0 <= sector < SECTORS_PER_TRACK[track]:
        raise ValueError(f"invalid sector {track}/{sector}")
    preceding = sum(SECTORS_PER_TRACK[1:track])
    return (preceding + sector) * SECTOR_SIZE


def petscii_field(text: str, width: int) -> bytes:
    encoded = text.upper().encode("ascii")
    if len(encoded) > width:
        raise ValueError(f"{text!r} exceeds {width} PETSCII bytes")
    return encoded + bytes([0xA0]) * (width - len(encoded))


def allocate_chain(block_count: int) -> list[tuple[int, int]]:
    """Allocate low tracks with a classic ten-sector interleave."""
    chain: list[tuple[int, int]] = []
    track = 1
    sector = 0
    while len(chain) < block_count:
        count = SECTORS_PER_TRACK[track]
        used = {s for t, s in chain if t == track}
        if len(used) == count:
            track += 1
            if track == 18:
                track += 1
            if track > TRACKS:
                raise ValueError("disk full; capitalism wins")
            sector = 0
            continue
        while sector in used:
            sector = (sector + 1) % count
        chain.append((track, sector))
        sector = (sector + INTERLEAVE) % count
    return chain


def mark_free(bam: bytearray, track: int, sector: int, free: bool) -> None:
    entry = 4 + (track - 1) * 4
    mask_offset = entry + 1 + sector // 8
    mask = 1 << (sector % 8)
    was_free = bool(bam[mask_offset] & mask)
    if free and not was_free:
        bam[mask_offset] |= mask
        bam[entry] += 1
    elif not free and was_free:
        bam[mask_offset] &= ~mask
        bam[entry] -= 1


def initialise_bam(image: bytearray) -> bytearray:
    bam_start = sector_offset(18, 0)
    bam = image[bam_start : bam_start + SECTOR_SIZE]
    bam[0:4] = bytes((18, 1, 0x41, 0))
    for track in range(1, TRACKS + 1):
        entry = 4 + (track - 1) * 4
        sector_count = SECTORS_PER_TRACK[track]
        bam[entry] = sector_count
        for sector in range(sector_count):
            bam[entry + 1 + sector // 8] |= 1 << (sector % 8)
    bam[0x90:0xA0] = petscii_field("HERESY 64", 16)
    bam[0xA0:0xA2] = b"\x00\x00"
    bam[0xA2:0xA4] = petscii_field("64", 2)
    bam[0xA4] = 0
    bam[0xA5:0xA7] = b"2A"
    bam[0xA7] = 0
    return bam


def build_d64(program: bytes) -> bytes:
    if not program:
        raise ValueError("refusing to put an empty spiritual dependency on disk")
    blocks = (len(program) + 253) // 254
    chain = allocate_chain(blocks)
    image = bytearray(D64_SIZE)
    bam = initialise_bam(image)

    mark_free(bam, 18, 0, False)
    mark_free(bam, 18, 1, False)
    for track, sector in chain:
        mark_free(bam, track, sector, False)
    bam_start = sector_offset(18, 0)
    image[bam_start : bam_start + SECTOR_SIZE] = bam

    for index, (track, sector) in enumerate(chain):
        start = sector_offset(track, sector)
        payload = program[index * 254 : (index + 1) * 254]
        if index + 1 < len(chain):
            image[start] = chain[index + 1][0]
            image[start + 1] = chain[index + 1][1]
        else:
            image[start] = 0
            image[start + 1] = len(payload) + 1
        image[start + 2 : start + 2 + len(payload)] = payload

    directory = sector_offset(18, 1)
    image[directory : directory + 2] = b"\x00\xff"
    entry = directory + 2
    image[entry] = 0x82
    image[entry + 1] = chain[0][0]
    image[entry + 2] = chain[0][1]
    image[entry + 3 : entry + 19] = petscii_field("HERESY64", 16)
    image[entry + 30] = blocks & 0xFF
    image[entry + 31] = blocks >> 8
    return bytes(image)


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(f"usage: {argv[0]} INPUT.PRG OUTPUT.D64", file=sys.stderr)
        return 2
    source = pathlib.Path(argv[1])
    target = pathlib.Path(argv[2])
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(build_d64(source.read_bytes()))
    print(f"WROTE {target} ({D64_SIZE} bytes; lockfile count: 0)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
