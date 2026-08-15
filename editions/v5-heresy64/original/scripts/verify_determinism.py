#!/usr/bin/env python3
"""Rebuild twice away from the worktree and compare every shipped byte."""

from __future__ import annotations

import hashlib
import pathlib
import shutil
import subprocess
import sys
import tempfile

from make_d64 import build_d64


ROOT = pathlib.Path(__file__).resolve().parents[1]


def compile_once(directory: pathlib.Path, ca65: str, ld65: str) -> tuple[bytes, bytes]:
    obj = directory / "heresy64.o"
    program = directory / "HERESY64.PRG"
    subprocess.run(
        [ca65, "-I", str(ROOT / "src"), "-g", "-o", str(obj),
         str(ROOT / "src/heresy64.s")],
        cwd=ROOT,
        check=True,
    )
    subprocess.run(
        [ld65, "-C", str(ROOT / "cfg/heresy64.cfg"), "-o", str(program),
         str(obj)],
        cwd=ROOT,
        check=True,
    )
    prg = program.read_bytes()
    return prg, build_d64(prg)


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(f"usage: {argv[0]} CA65 LD65", file=sys.stderr)
        return 2
    ca65 = shutil.which(argv[1]) or argv[1]
    ld65 = shutil.which(argv[2]) or argv[2]
    with tempfile.TemporaryDirectory(prefix="heresy64-a-") as first_dir:
        with tempfile.TemporaryDirectory(prefix="heresy64-b-") as second_dir:
            first = compile_once(pathlib.Path(first_dir), ca65, ld65)
            second = compile_once(pathlib.Path(second_dir), ca65, ld65)
    shipped = (
        (ROOT / "dist/HERESY64.PRG").read_bytes(),
        (ROOT / "dist/HERESY64.D64").read_bytes(),
    )
    if first != second:
        raise AssertionError("two clean builds reached different revealed truths")
    if first != shipped:
        raise AssertionError("checked-in artifacts do not match a clean build")
    print(f"PASS deterministic PRG: {sha(first[0])}")
    print(f"PASS deterministic D64: {sha(first[1])}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv))
    except (AssertionError, FileNotFoundError, subprocess.CalledProcessError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
