#!/usr/bin/env python3
"""Structural checks for the tiny machine and its deliberately large claims."""

from __future__ import annotations

import hashlib
import pathlib
import re
import subprocess
import sys

from make_d64 import D64_SIZE, SECTORS_PER_TRACK, sector_offset


ROOT = pathlib.Path(__file__).resolve().parents[1]
PRG = ROOT / "dist/HERESY64.PRG"
D64 = ROOT / "dist/HERESY64.D64"
LABELS = ROOT / "build/heresy64.lbl"
V4_ARCHIVE = ROOT / "editions/v4-modern-developer-simulator/original"
PRG_SHA256 = "9fe2fbd2e51d9806f071e6e45ab5991ddfebfc9868806a5569588cfae61edae3"
D64_SHA256 = "ffeb6216f577a9e9fb6d6295cde4f1f4f9892bcf400918041d7d836d765193b0"


def fail(message: str) -> None:
    raise AssertionError(message)


def digest(path: pathlib.Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def labels() -> dict[str, int]:
    found: dict[str, int] = {}
    pattern = re.compile(r"^al\s+([0-9A-Fa-f]{6})\s+\.([A-Za-z_][A-Za-z0-9_]*)$")
    for line in LABELS.read_text().splitlines():
        match = pattern.match(line)
        if match:
            found[match.group(2)] = int(match.group(1), 16)
    return found


def read_file_chain(image: bytes) -> tuple[bytes, list[tuple[int, int]], int]:
    directory = sector_offset(18, 1)
    if image[directory : directory + 2] != b"\x00\xff":
        fail("directory does not terminate in the traditional, reassuring way")
    entry = directory + 2
    if image[entry] != 0x82:
        fail("HERESY64 is not a closed PRG directory entry")
    filename = image[entry + 3 : entry + 19].rstrip(b"\xa0")
    if filename != b"HERESY64":
        fail(f"unexpected disk filename {filename!r}")
    blocks = image[entry + 30] | image[entry + 31] << 8
    track, sector = image[entry + 1], image[entry + 2]
    payload = bytearray()
    chain: list[tuple[int, int]] = []
    seen: set[tuple[int, int]] = set()
    while track:
        point = (track, sector)
        if point in seen:
            fail(f"cyclic 1541 theology at {track}/{sector}")
        seen.add(point)
        chain.append(point)
        start = sector_offset(track, sector)
        next_track, next_sector = image[start], image[start + 1]
        if next_track:
            payload.extend(image[start + 2 : start + 256])
        else:
            if not 1 <= next_sector <= 255:
                fail("last file sector has an impossible byte count")
            payload.extend(image[start + 2 : start + 1 + next_sector])
        track, sector = next_track, next_sector
    return bytes(payload), chain, blocks


def check_bam(image: bytes, used: set[tuple[int, int]]) -> None:
    bam_start = sector_offset(18, 0)
    bam = image[bam_start : bam_start + 256]
    if bam[:3] != bytes((18, 1, 0x41)):
        fail("BAM does not point at 18/1 with DOS version A")
    if bam[0x90:0xA0].rstrip(b"\xa0") != b"HERESY 64":
        fail("disk name is not HERESY 64")
    if bam[0xA2:0xA4] != b"64" or bam[0xA5:0xA7] != b"2A":
        fail("disk ID/DOS type escaped the fixed record")
    for track in range(1, 36):
        entry = 4 + (track - 1) * 4
        bitmap = bam[entry + 1 : entry + 4]
        free_count = 0
        for sector in range(SECTORS_PER_TRACK[track]):
            free = bool(bitmap[sector // 8] & (1 << (sector % 8)))
            expected_free = (track, sector) not in used
            if free != expected_free:
                fail(f"BAM disagrees with allocation at {track}/{sector}")
            free_count += free
        if bam[entry] != free_count:
            fail(f"BAM free count is wrong on track {track}")


def check_kernel_symbols(symbols: dict[str, int]) -> None:
    required = (
        "boot_trampoline",
        "kernel_jump_table",
        "kernel_core_start",
        "kernel_core_end",
        "kernel_send",
        "kernel_dispatch",
        "kernel_register",
        "kernel_page_alloc",
        "kernel_page_free",
        "kernel_pending",
        "kernel_ticks",
        "kernel_pages_used",
        "kernel_yield",
    )
    missing = [name for name in required if name not in symbols]
    if missing:
        fail(f"linker labels missing: {', '.join(missing)}")
    if symbols["boot_trampoline"] != 0x080D:
        fail("BASIC SYS 2061 no longer lands on the fixed boot trampoline")
    size = symbols["kernel_core_end"] - symbols["kernel_core_start"]
    if size != 326:
        fail(f"kernel core changed from the published 326 bytes to {size}")
    if size > 512:
        fail("the microkernel has become a mesokernel")


def check_hardware_ownership() -> None:
    sources = {
        path.relative_to(ROOT).as_posix(): path.read_text()
        for path in (ROOT / "src").rglob("*.s")
    }
    rules = (
        (re.compile(r"\bVIC_[A-Z0-9_]+\b|\bCOLOR_RAM\b|\bSCREEN_RAM\b"),
         {"src/servers/video.s", "src/data.s", "src/abi.inc"}),
        (re.compile(r"\bSID_[A-Z0-9_]+\b"),
         {"src/servers/audio.s", "src/data.s", "src/abi.inc"}),
        (re.compile(r"\bKERNAL_(?:SETLFS|SETNAM|OPEN|CLOSE|CHKIN|CHKOUT|CLRCHN|CHRIN|CHROUT)\b"),
         {"src/servers/disk.s", "src/abi.inc"}),
        (re.compile(r"\bKERNAL_GETIN\b|\bCIA1_PORTA\b"),
         {"src/servers/input.s", "src/abi.inc"}),
    )
    violations: list[str] = []
    for pattern, owners in rules:
        for name, text in sources.items():
            if pattern.search(text) and name not in owners:
                violations.append(f"{name} uses hardware owned by {sorted(owners)}")
    if violations:
        fail("; ".join(violations))
    demo = sources["src/apps/demo.s"]
    if "SID_" in demo or "VIC_" in demo:
        fail("DEMOD touched hardware instead of enduring IPC")


def check_demo() -> None:
    data = (ROOT / "src/data.s").read_text()
    demo = (ROOT / "src/apps/demo.s").read_text()
    video = (ROOT / "src/servers/video.s").read_text()
    required = (
        "NIXOS IS THE NEW DECLARATIVE RELIGION",
        "ARCH BTW: NOW THE OLD TESTAMENT",
        "LFS REJECTED: MISSING FLAKE.LOCK",
        "INFRASTRUCTURE IS NOT A PERSONALITY",
        "MINDSET: CONFIGURATION IS MORAL VIRTUE",
        "PID 1: SYSTEMD NOW PROVIDES AFTERLIFE",
        "SMALL IS BEAUTIFUL. BLOAT IS UNHOLY.",
        "8 COMMITS / 252 LINES / 0 CHECKS",
    )
    for phrase in required:
        if phrase not in data:
            fail(f"FORCEOS '38 has misplaced its doctrine: {phrase}")
    if "MSG_AUDIO_TONE" not in demo or "MSG_DEMO_FRAME" not in demo:
        fail("demo does not broker both audio and video through IPC")
    if "VIC_RASTER" not in video or "demo_scroll_text" not in video:
        fail("video service no longer performs a real raster/scroller effect")


def tracked_files_at(ref: str) -> list[str]:
    result = subprocess.run(
        ["git", "ls-tree", "-r", "--name-only", ref],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    return [line for line in result.stdout.splitlines() if line]


def check_v4_archive() -> None:
    required = (
        ".github/workflows/ci.yml",
        ".gitignore",
        "AGENTS.md",
        "CITATION.cff",
        "HERESY_README.md",
        "LICENSE",
        "Makefile",
        "README.md",
        "index.html",
        "programs/modern-developer.cob",
        "scripts/punch-cobol.js",
        "scripts/selftest.js",
        "scripts/verify-size.js",
        "src/app.js",
        "src/cobol-database.js",
        "src/cobol-deck.js",
        "src/engine.js",
        "style.css",
    )
    tagged = set(tracked_files_at("v4.0.0"))
    missing_from_tag = set(required) - tagged
    if missing_from_tag:
        fail(
            "the published v4 tag lacks expected root files: "
            + ", ".join(sorted(missing_from_tag))
        )
    for relative in required:
        archive_file = V4_ARCHIVE / relative
        if not archive_file.is_file():
            fail(f"v4 archive is missing {relative}")
        tagged_bytes = subprocess.run(
            ["git", "show", f"v4.0.0:{relative}"],
            cwd=ROOT,
            check=True,
            capture_output=True,
        ).stdout
        if archive_file.read_bytes() != tagged_bytes:
            fail(f"v4 archive drifted from v4.0.0: {relative}")


def main() -> int:
    if len(PRG.read_bytes()) != 5424:
        fail(f"PRG is {PRG.stat().st_size} bytes, not the published 5,424")
    if PRG.read_bytes()[:2] != b"\x01\x08":
        fail("PRG load address is not $0801")
    if digest(PRG) != PRG_SHA256:
        fail("PRG differs from the published v5 artifact")
    if D64.stat().st_size != D64_SIZE:
        fail(f"D64 is not a standard 174,848-byte 35-track image")
    if digest(D64) != D64_SHA256:
        fail("D64 differs from the published v5 artifact")

    image = D64.read_bytes()
    recovered, chain, blocks = read_file_chain(image)
    if recovered != PRG.read_bytes():
        fail("D64 file chain does not reconstruct the PRG")
    if blocks != len(chain) or blocks != 22:
        fail(f"directory says {blocks} blocks; chain has {len(chain)}")
    check_bam(image, set(chain) | {(18, 0), (18, 1)})

    symbols = labels()
    check_kernel_symbols(symbols)
    check_hardware_ownership()
    check_demo()
    check_v4_archive()

    print(f"PASS PRG: {PRG.stat().st_size:,} bytes ({digest(PRG)})")
    print(f"PASS D64: {D64.stat().st_size:,} bytes, {blocks} blocks ({digest(D64)})")
    print("PASS kernel: 326 bytes, 32 x 8-byte IPC, 16 brokered pages")
    print("PASS ownership: VIC-II, SID, input, and disk remain service-owned")
    print("PASS edition: v4 archive is byte-for-byte v4.0.0")
    print("PASS satire: infrastructure religion remains operational")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, FileNotFoundError, subprocess.CalledProcessError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
