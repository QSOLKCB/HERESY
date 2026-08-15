"""Dependency-free deterministic 1.44 MB FAT12 image builder.

The boot sector is genuine 16-bit x86 code. It prints a short governance notice
with BIOS teletype output and halts. The filesystem is standard FAT12 and holds
the compact evidence bundle. No generated image is committed; CI rebuilds it.
"""

from __future__ import annotations

import struct
from dataclasses import dataclass


IMAGE_SIZE = 1_474_560
SECTOR_SIZE = 512
TOTAL_SECTORS = 2880
SECTORS_PER_CLUSTER = 1
RESERVED_SECTORS = 1
FAT_COUNT = 2
SECTORS_PER_FAT = 9
ROOT_ENTRIES = 224
ROOT_SECTORS = 14
DATA_START_SECTOR = RESERVED_SECTORS + FAT_COUNT * SECTORS_PER_FAT + ROOT_SECTORS
FIXED_DATE = (2026, 8, 15, 22, 50, 0)


@dataclass(frozen=True)
class ImageFile:
    name: str
    data: bytes


def _fat_name(name: str) -> bytes:
    upper = name.upper()
    if upper.count(".") > 1:
        raise ValueError(f"not an 8.3 name: {name}")
    stem, dot, ext = upper.partition(".")
    allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$~!#%&-{}()@'`"
    if not (1 <= len(stem) <= 8 and len(ext) <= 3):
        raise ValueError(f"not an 8.3 name: {name}")
    if any(ch not in allowed for ch in stem + ext):
        raise ValueError(f"unsupported FAT character in {name}")
    return stem.ljust(8).encode("ascii") + ext.ljust(3).encode("ascii")


def _dos_datetime() -> tuple[int, int]:
    year, month, day, hour, minute, second = FIXED_DATE
    date = ((year - 1980) << 9) | (month << 5) | day
    time = (hour << 11) | (minute << 5) | (second // 2)
    return time, date


def _set_fat12(fat: bytearray, cluster: int, value: int) -> None:
    offset = cluster + cluster // 2
    value &= 0xFFF
    if cluster & 1:
        fat[offset] = (fat[offset] & 0x0F) | ((value << 4) & 0xF0)
        fat[offset + 1] = (value >> 4) & 0xFF
    else:
        fat[offset] = value & 0xFF
        fat[offset + 1] = (fat[offset + 1] & 0xF0) | ((value >> 8) & 0x0F)


def boot_sector() -> bytes:
    sector = bytearray(SECTOR_SIZE)
    sector[0:3] = b"\xEB\x3C\x90"  # JMP over the BPB; nostalgia with a destination.
    sector[3:11] = b"HERESY6 "
    struct.pack_into("<H", sector, 11, SECTOR_SIZE)
    sector[13] = SECTORS_PER_CLUSTER
    struct.pack_into("<H", sector, 14, RESERVED_SECTORS)
    sector[16] = FAT_COUNT
    struct.pack_into("<H", sector, 17, ROOT_ENTRIES)
    struct.pack_into("<H", sector, 19, TOTAL_SECTORS)
    sector[21] = 0xF0
    struct.pack_into("<H", sector, 22, SECTORS_PER_FAT)
    struct.pack_into("<H", sector, 24, 18)
    struct.pack_into("<H", sector, 26, 2)
    struct.pack_into("<I", sector, 28, 0)
    struct.pack_into("<I", sector, 32, 0)
    sector[36] = 0
    sector[37] = 0
    sector[38] = 0x29
    struct.pack_into("<I", sector, 39, 0x18437144)
    sector[43:54] = b"HERESY1440 "
    sector[54:62] = b"FAT12   "

    message = (
        b"\r\nHERESY AI/1440\r\n"
        b"ZERO-PARAMETER MODEL GOVERNANCE APPLIANCE\r\n"
        b"THE MODEL WEIGHTS WERE DENIED BOARDING.\r\n"
        b"EVIDENCE IS ON THE FAT12 VOLUME.\r\n"
        b"NO CLOUD ACCOUNT WAS CREATED.\r\n\x00"
    )

    code_offset = 62
    # xor ax,ax; mov ds,ax; mov si,imm16; lodsb; test al,al; jz halt;
    # mov ah,0x0e; mov bx,0x0007; int 10h; jmp loop; cli; hlt; jmp hlt
    code = bytearray(b"\x31\xC0\x8E\xD8\xBE\x00\x00\xAC\x84\xC0\x74\x09\xB4\x0E\xBB\x07\x00\xCD\x10\xEB\xF2\xFA\xF4\xEB\xFD")
    msg_offset = code_offset + len(code)
    msg_address = 0x7C00 + msg_offset
    struct.pack_into("<H", code, 5, msg_address)
    if msg_offset + len(message) > 510:
        raise AssertionError("boot governance exceeded one sector; create a steering committee")
    sector[code_offset:code_offset + len(code)] = code
    sector[msg_offset:msg_offset + len(message)] = message
    sector[510:512] = b"\x55\xAA"
    return bytes(sector)


def build_image(files: list[ImageFile]) -> bytes:
    if len(files) > ROOT_ENTRIES:
        raise ValueError("root directory exceeded; microservices are not the answer")
    image = bytearray(IMAGE_SIZE)
    image[:SECTOR_SIZE] = boot_sector()

    fat = bytearray(SECTORS_PER_FAT * SECTOR_SIZE)
    fat[0:3] = b"\xF0\xFF\xFF"
    root = bytearray(ROOT_SECTORS * SECTOR_SIZE)
    data_offset = DATA_START_SECTOR * SECTOR_SIZE
    next_cluster = 2
    dos_time, dos_date = _dos_datetime()

    seen: set[bytes] = set()
    for entry_index, item in enumerate(sorted(files, key=lambda f: f.name.upper())):
        fatname = _fat_name(item.name)
        if fatname in seen:
            raise ValueError(f"duplicate FAT filename: {item.name}")
        seen.add(fatname)
        clusters = max(1, (len(item.data) + SECTOR_SIZE - 1) // SECTOR_SIZE)
        first_cluster = next_cluster
        last_cluster = first_cluster + clusters - 1
        max_cluster = (TOTAL_SECTORS - DATA_START_SECTOR) // SECTORS_PER_CLUSTER + 1
        if last_cluster > max_cluster:
            raise ValueError("evidence no longer fits on floppy; please delete a framework")

        for cluster in range(first_cluster, last_cluster + 1):
            _set_fat12(fat, cluster, 0xFFF if cluster == last_cluster else cluster + 1)
        start = data_offset + (first_cluster - 2) * SECTOR_SIZE
        image[start:start + len(item.data)] = item.data

        off = entry_index * 32
        root[off:off + 11] = fatname
        root[off + 11] = 0x20
        struct.pack_into("<H", root, off + 22, dos_time)
        struct.pack_into("<H", root, off + 24, dos_date)
        struct.pack_into("<H", root, off + 26, first_cluster)
        struct.pack_into("<I", root, off + 28, len(item.data))
        next_cluster = last_cluster + 1

    fat1 = RESERVED_SECTORS * SECTOR_SIZE
    fat2 = fat1 + SECTORS_PER_FAT * SECTOR_SIZE
    root_offset = fat2 + SECTORS_PER_FAT * SECTOR_SIZE
    image[fat1:fat1 + len(fat)] = fat
    image[fat2:fat2 + len(fat)] = fat
    image[root_offset:root_offset + len(root)] = root
    return bytes(image)
