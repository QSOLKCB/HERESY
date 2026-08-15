#!/usr/bin/env python3
"""Execute the linked 6502 program and exercise every HERESY/64 application.

This intentionally small emulator implements only the documented 6502
instructions emitted by this source tree. KERNAL calls are modelled at their
public jump-table boundary, so the test executes the real linked application,
kernel, IPC, rendering, disk, raster, and SID code.
"""

from __future__ import annotations

import pathlib
import re
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]
PRG = ROOT / "dist/HERESY64.PRG"
LABEL_FILE = ROOT / "build/heresy64.lbl"

C = 0x01
Z = 0x02
I = 0x04
D = 0x08
U = 0x20
V = 0x40
N = 0x80

KERNAL_STATUS = 0x0090
JIFFY_LO = 0x00A2
CIA1_PORTA = 0xDC00
VIC_RASTER = 0xD012

SETLFS = 0xFFBA
SETNAM = 0xFFBD
OPEN = 0xFFC0
CLOSE = 0xFFC3
CHKIN = 0xFFC6
CHKOUT = 0xFFC9
CLRCHN = 0xFFCC
CHRIN = 0xFFCF
CHROUT = 0xFFD2
GETIN = 0xFFE4


def load_labels() -> dict[str, int]:
    output: dict[str, int] = {}
    pattern = re.compile(r"^al\s+([0-9A-Fa-f]{6})\s+\.([A-Za-z_][A-Za-z0-9_]*)$")
    for line in LABEL_FILE.read_text().splitlines():
        match = pattern.match(line)
        if match:
            output[match.group(2)] = int(match.group(1), 16)
    return output


class Machine:
    def __init__(self, program: bytes):
        self.mem = bytearray(65536)
        load = program[0] | program[1] << 8
        self.mem[load : load + len(program) - 2] = program[2:]
        self.a = 0
        self.x = 0
        self.y = 0
        self.sp = 0xFF
        self.p = U
        self.pc = 0
        self.instructions = 0
        self.vic_writes = 0
        self.sid_writes = 0
        self.raster = 0
        self.keys: list[int] = []
        self.named = b""
        self.logical = 0
        self.device = 8
        self.secondary = 0
        self.input_channel: int | None = None
        self.output_channel: int | None = None
        self.channels: dict[int, dict[str, object]] = {}
        self.files: dict[str, bytes] = {}
        self.directory = (
            b'0 "HERESY64" 64 2A\r'
            b'1 "README" PRG\r'
            b'2 "NO BLOAT" SEQ\r'
        )
        self.mem[CIA1_PORTA] = 0x1F
        self.kernal = {
            SETLFS: self.k_setlfs,
            SETNAM: self.k_setnam,
            OPEN: self.k_open,
            CLOSE: self.k_close,
            CHKIN: self.k_chkin,
            CHKOUT: self.k_chkout,
            CLRCHN: self.k_clrchn,
            CHRIN: self.k_chrin,
            CHROUT: self.k_chrout,
            GETIN: self.k_getin,
        }

    def flag(self, mask: int, state: bool) -> None:
        if state:
            self.p |= mask
        else:
            self.p &= ~mask

    def nz(self, value: int) -> int:
        value &= 0xFF
        self.flag(Z, value == 0)
        self.flag(N, bool(value & 0x80))
        return value

    def read(self, address: int) -> int:
        address &= 0xFFFF
        if address == VIC_RASTER:
            self.raster = (self.raster + 1) & 0xFF
            self.mem[VIC_RASTER] = self.raster
            return self.raster
        return self.mem[address]

    def write(self, address: int, value: int) -> None:
        address &= 0xFFFF
        value &= 0xFF
        self.mem[address] = value
        if 0xD000 <= address <= 0xD02E:
            self.vic_writes += 1
        if 0xD400 <= address <= 0xD418:
            self.sid_writes += 1

    def fetch(self) -> int:
        value = self.read(self.pc)
        self.pc = (self.pc + 1) & 0xFFFF
        return value

    def word(self) -> int:
        low = self.fetch()
        return low | self.fetch() << 8

    def read_word(self, address: int) -> int:
        return self.read(address) | self.read((address + 1) & 0xFFFF) << 8

    def read_word_zp(self, address: int) -> int:
        return self.read(address & 0xFF) | self.read((address + 1) & 0xFF) << 8

    def push(self, value: int) -> None:
        self.write(0x0100 | self.sp, value)
        self.sp = (self.sp - 1) & 0xFF

    def pop(self) -> int:
        self.sp = (self.sp + 1) & 0xFF
        return self.read(0x0100 | self.sp)

    def rts(self) -> None:
        low = self.pop()
        high = self.pop()
        self.pc = ((high << 8 | low) + 1) & 0xFFFF

    def address(self, mode: str) -> int:
        if mode == "imm":
            result = self.pc
            self.pc = (self.pc + 1) & 0xFFFF
            return result
        if mode == "zp":
            return self.fetch()
        if mode == "zpx":
            return (self.fetch() + self.x) & 0xFF
        if mode == "zpy":
            return (self.fetch() + self.y) & 0xFF
        if mode == "abs":
            return self.word()
        if mode == "absx":
            return (self.word() + self.x) & 0xFFFF
        if mode == "absy":
            return (self.word() + self.y) & 0xFFFF
        if mode == "indx":
            return self.read_word_zp((self.fetch() + self.x) & 0xFF)
        if mode == "indy":
            return (self.read_word_zp(self.fetch()) + self.y) & 0xFFFF
        raise AssertionError(f"unknown addressing mode {mode}")

    def compare(self, register: int, value: int) -> None:
        result = (register - value) & 0x1FF
        self.flag(C, register >= value)
        self.nz(result)

    def adc(self, value: int) -> None:
        total = self.a + value + bool(self.p & C)
        result = total & 0xFF
        self.flag(C, total > 0xFF)
        self.flag(V, bool((~(self.a ^ value) & (self.a ^ result) & 0x80)))
        self.a = self.nz(result)

    def branch(self, condition: bool) -> None:
        offset = self.fetch()
        if condition:
            if offset & 0x80:
                offset -= 0x100
            self.pc = (self.pc + offset) & 0xFFFF

    def step(self) -> None:
        self.instructions += 1
        if self.instructions % 500 == 0:
            self.mem[JIFFY_LO] = (self.mem[JIFFY_LO] + 1) & 0xFF
        if self.pc in self.kernal:
            self.kernal[self.pc]()
            self.rts()
            return

        opcode = self.fetch()

        read_ops = {
            0x69: ("ADC", "imm"), 0x65: ("ADC", "zp"),
            0x75: ("ADC", "zpx"), 0x6D: ("ADC", "abs"),
            0x7D: ("ADC", "absx"), 0x79: ("ADC", "absy"),
            0x61: ("ADC", "indx"), 0x71: ("ADC", "indy"),
            0x29: ("AND", "imm"), 0x25: ("AND", "zp"),
            0x35: ("AND", "zpx"), 0x2D: ("AND", "abs"),
            0x3D: ("AND", "absx"), 0x39: ("AND", "absy"),
            0x21: ("AND", "indx"), 0x31: ("AND", "indy"),
            0xC9: ("CMP", "imm"), 0xC5: ("CMP", "zp"),
            0xD5: ("CMP", "zpx"), 0xCD: ("CMP", "abs"),
            0xDD: ("CMP", "absx"), 0xD9: ("CMP", "absy"),
            0xC1: ("CMP", "indx"), 0xD1: ("CMP", "indy"),
            0x49: ("EOR", "imm"), 0x45: ("EOR", "zp"),
            0x55: ("EOR", "zpx"), 0x4D: ("EOR", "abs"),
            0x5D: ("EOR", "absx"), 0x59: ("EOR", "absy"),
            0x41: ("EOR", "indx"), 0x51: ("EOR", "indy"),
            0xA9: ("LDA", "imm"), 0xA5: ("LDA", "zp"),
            0xB5: ("LDA", "zpx"), 0xAD: ("LDA", "abs"),
            0xBD: ("LDA", "absx"), 0xB9: ("LDA", "absy"),
            0xA1: ("LDA", "indx"), 0xB1: ("LDA", "indy"),
            0xA2: ("LDX", "imm"), 0xA6: ("LDX", "zp"),
            0xB6: ("LDX", "zpy"), 0xAE: ("LDX", "abs"),
            0xBE: ("LDX", "absy"),
            0xA0: ("LDY", "imm"), 0xA4: ("LDY", "zp"),
            0xB4: ("LDY", "zpx"), 0xAC: ("LDY", "abs"),
            0xBC: ("LDY", "absx"),
            0x09: ("ORA", "imm"), 0x05: ("ORA", "zp"),
            0x15: ("ORA", "zpx"), 0x0D: ("ORA", "abs"),
            0x1D: ("ORA", "absx"), 0x19: ("ORA", "absy"),
            0x01: ("ORA", "indx"), 0x11: ("ORA", "indy"),
            0xE9: ("SBC", "imm"), 0xE5: ("SBC", "zp"),
            0xF5: ("SBC", "zpx"), 0xED: ("SBC", "abs"),
            0xFD: ("SBC", "absx"), 0xF9: ("SBC", "absy"),
            0xE1: ("SBC", "indx"), 0xF1: ("SBC", "indy"),
            0xE0: ("CPX", "imm"), 0xE4: ("CPX", "zp"),
            0xEC: ("CPX", "abs"),
            0xC0: ("CPY", "imm"), 0xC4: ("CPY", "zp"),
            0xCC: ("CPY", "abs"),
        }
        if opcode in read_ops:
            operation, mode = read_ops[opcode]
            value = self.read(self.address(mode))
            if operation == "ADC":
                self.adc(value)
            elif operation == "AND":
                self.a = self.nz(self.a & value)
            elif operation == "CMP":
                self.compare(self.a, value)
            elif operation == "CPX":
                self.compare(self.x, value)
            elif operation == "CPY":
                self.compare(self.y, value)
            elif operation == "EOR":
                self.a = self.nz(self.a ^ value)
            elif operation == "LDA":
                self.a = self.nz(value)
            elif operation == "LDX":
                self.x = self.nz(value)
            elif operation == "LDY":
                self.y = self.nz(value)
            elif operation == "ORA":
                self.a = self.nz(self.a | value)
            elif operation == "SBC":
                self.adc(value ^ 0xFF)
            return

        store_ops = {
            0x85: ("A", "zp"), 0x95: ("A", "zpx"),
            0x8D: ("A", "abs"), 0x9D: ("A", "absx"),
            0x99: ("A", "absy"), 0x81: ("A", "indx"),
            0x91: ("A", "indy"),
            0x86: ("X", "zp"), 0x96: ("X", "zpy"),
            0x8E: ("X", "abs"),
            0x84: ("Y", "zp"), 0x94: ("Y", "zpx"),
            0x8C: ("Y", "abs"),
        }
        if opcode in store_ops:
            register, mode = store_ops[opcode]
            value = self.a if register == "A" else self.x if register == "X" else self.y
            self.write(self.address(mode), value)
            return

        shifts = {
            0x0A: ("ASL", "acc"), 0x06: ("ASL", "zp"),
            0x16: ("ASL", "zpx"), 0x0E: ("ASL", "abs"),
            0x1E: ("ASL", "absx"),
            0x4A: ("LSR", "acc"), 0x46: ("LSR", "zp"),
            0x56: ("LSR", "zpx"), 0x4E: ("LSR", "abs"),
            0x5E: ("LSR", "absx"),
        }
        if opcode in shifts:
            operation, mode = shifts[opcode]
            target = None if mode == "acc" else self.address(mode)
            value = self.a if target is None else self.read(target)
            if operation == "ASL":
                self.flag(C, bool(value & 0x80))
                result = self.nz(value << 1)
            else:
                self.flag(C, bool(value & 1))
                result = self.nz(value >> 1)
            if target is None:
                self.a = result
            else:
                self.write(target, result)
            return

        modify_ops = {
            0xE6: ("INC", "zp"), 0xF6: ("INC", "zpx"),
            0xEE: ("INC", "abs"), 0xFE: ("INC", "absx"),
            0xC6: ("DEC", "zp"), 0xD6: ("DEC", "zpx"),
            0xCE: ("DEC", "abs"), 0xDE: ("DEC", "absx"),
        }
        if opcode in modify_ops:
            operation, mode = modify_ops[opcode]
            address = self.address(mode)
            delta = 1 if operation == "INC" else -1
            self.write(address, self.nz(self.read(address) + delta))
            return

        if opcode == 0x4C:
            self.pc = self.word()
        elif opcode == 0x6C:
            pointer = self.word()
            self.pc = self.read(pointer) | self.read(
                (pointer & 0xFF00) | ((pointer + 1) & 0xFF)
            ) << 8
        elif opcode == 0x20:
            target = self.word()
            return_address = (self.pc - 1) & 0xFFFF
            self.push(return_address >> 8)
            self.push(return_address)
            self.pc = target
        elif opcode == 0x60:
            self.rts()
        elif opcode == 0x90:
            self.branch(not bool(self.p & C))
        elif opcode == 0xB0:
            self.branch(bool(self.p & C))
        elif opcode == 0xF0:
            self.branch(bool(self.p & Z))
        elif opcode == 0xD0:
            self.branch(not bool(self.p & Z))
        elif opcode == 0x18:
            self.flag(C, False)
        elif opcode == 0x38:
            self.flag(C, True)
        elif opcode == 0xD8:
            self.flag(D, False)
        elif opcode == 0x58:
            self.flag(I, False)
        elif opcode == 0x78:
            self.flag(I, True)
        elif opcode == 0xE8:
            self.x = self.nz(self.x + 1)
        elif opcode == 0xCA:
            self.x = self.nz(self.x - 1)
        elif opcode == 0xC8:
            self.y = self.nz(self.y + 1)
        elif opcode == 0x88:
            self.y = self.nz(self.y - 1)
        elif opcode == 0xAA:
            self.x = self.nz(self.a)
        elif opcode == 0xA8:
            self.y = self.nz(self.a)
        elif opcode == 0x8A:
            self.a = self.nz(self.x)
        elif opcode == 0x98:
            self.a = self.nz(self.y)
        elif opcode == 0x9A:
            self.sp = self.x
        elif opcode == 0x48:
            self.push(self.a)
        elif opcode == 0x68:
            self.a = self.nz(self.pop())
        else:
            raise AssertionError(
                f"unsupported opcode ${opcode:02X} at ${(self.pc - 1) & 0xFFFF:04X}"
            )

    def call(self, address: int, *, a: int = 0, x: int = 0, y: int = 0,
             limit: int = 500_000) -> None:
        sentinel = 0x0200
        self.a, self.x, self.y = a & 0xFF, x & 0xFF, y & 0xFF
        self.sp = 0xFF
        return_address = sentinel - 1
        self.push(return_address >> 8)
        self.push(return_address)
        self.pc = address
        starting = self.instructions
        while self.pc != sentinel:
            if self.instructions - starting >= limit:
                raise AssertionError(f"subroutine ${address:04X} did not return")
            self.step()

    def run(self, count: int) -> None:
        for _ in range(count):
            self.step()

    def set_status(self, value: int) -> None:
        self.mem[KERNAL_STATUS] = value & 0xFF

    def k_setnam(self) -> None:
        pointer = self.x | self.y << 8
        self.named = bytes(self.read(pointer + index) for index in range(self.a))

    def k_setlfs(self) -> None:
        self.logical, self.device, self.secondary = self.a, self.x, self.y

    def k_open(self) -> None:
        self.set_status(0)
        name = self.named.decode("ascii")
        if self.secondary == 15:
            self.execute_command(name)
            self.channels[self.logical] = {"mode": "command"}
        elif name == "$":
            self.channels[self.logical] = {
                "mode": "read", "data": self.directory, "position": 0
            }
        elif name.endswith(",S,W"):
            self.channels[self.logical] = {
                "mode": "write", "name": name[:-4], "data": bytearray()
            }
        elif name in self.files:
            self.channels[self.logical] = {
                "mode": "read", "data": self.files[name], "position": 0
            }
        else:
            self.set_status(0x80)

    def k_close(self) -> None:
        channel = self.channels.pop(self.a, None)
        if channel and channel.get("mode") == "write":
            self.files[str(channel["name"])] = bytes(channel["data"])
        if self.input_channel == self.a:
            self.input_channel = None
        if self.output_channel == self.a:
            self.output_channel = None

    def k_chkin(self) -> None:
        self.input_channel = self.x

    def k_chkout(self) -> None:
        self.output_channel = self.x

    def k_clrchn(self) -> None:
        self.input_channel = None
        self.output_channel = None

    def k_chrin(self) -> None:
        channel = self.channels.get(self.input_channel or -1)
        if not channel or channel.get("mode") != "read":
            self.a = 0
            self.set_status(0x80)
            return
        data = bytes(channel["data"])
        position = int(channel["position"])
        if position >= len(data):
            self.a = 0
            self.set_status(0x40)
            return
        self.a = data[position]
        channel["position"] = position + 1
        self.set_status(0x40 if position + 1 == len(data) else 0)

    def k_chrout(self) -> None:
        channel = self.channels.get(self.output_channel or -1)
        if not channel or channel.get("mode") != "write":
            self.set_status(0x80)
            return
        channel["data"].append(self.a)
        self.set_status(0)

    def k_getin(self) -> None:
        self.a = self.keys.pop(0) if self.keys else 0
        self.nz(self.a)

    def execute_command(self, command: str) -> None:
        if command.startswith("S0:"):
            self.files.pop(command[3:], None)
        elif command.startswith("R0:") and "=" in command:
            destination, source = command[3:].split("=", 1)
            if source in self.files:
                self.files[destination] = self.files.pop(source)
            else:
                self.set_status(0x80)


class Runtime:
    def __init__(self):
        self.labels = load_labels()
        self.machine = Machine(PRG.read_bytes())
        self.machine.pc = self.labels["boot_trampoline"]

    def byte(self, name: str) -> int:
        return self.machine.mem[self.labels[name]]

    def set_byte(self, name: str, value: int) -> None:
        self.machine.mem[self.labels[name]] = value & 0xFF

    def invoke(self, service: str, message: int, p0: int = 0, p1: int = 0) -> None:
        self.set_byte("kernel_msg_type", message)
        self.set_byte("kernel_msg_p0", p0)
        self.set_byte("kernel_msg_p1", p1)
        self.machine.call(self.labels[f"{service}_handler"])

    def drain(self, limit: int = 256) -> None:
        for _ in range(limit):
            if self.byte("ipc_head") == self.byte("ipc_tail"):
                return
            self.machine.call(self.labels["kernel_dispatch"])
        raise AssertionError("IPC queue did not drain")

    def boot(self) -> None:
        self.machine.run(80_000)
        self.drain()


def main() -> int:
    run = Runtime()
    cpu = run.machine
    labels = run.labels
    run.boot()

    handlers = labels["service_handlers_lo"]
    if any(cpu.mem[handlers + index] == 0 for index in range(11)):
        raise AssertionError("boot did not register all eleven services")
    if sum(cpu.mem[labels["page_bitmap"] : labels["page_bitmap"] + 16]) != 10:
        raise AssertionError("boot did not broker ten non-kernel pages")
    if run.byte("active_view") != 0:
        raise AssertionError("desktop did not become the initial view")

    # FILESD -> DISKD -> FILESD -> VIDEOD.
    run.set_byte("active_view", 1)
    run.invoke("files", 5)
    run.drain()
    if run.byte("files_count") != 3:
        raise AssertionError("Files did not parse three fixed directory names")

    # NOTESD persists through the recoverable temp/write/scratch/rename flow.
    run.set_byte("active_view", 2)
    for character in b"NO BLOAT":
        run.invoke("notes", 3, character)
        run.drain()
    run.invoke("notes", 3, 0x86)  # F3
    run.drain()
    if cpu.files.get("HERESY NOTE") != b"NO BLOAT":
        raise AssertionError("Notes save did not commit the transactional survivor")
    if "HERESY NEW" in cpu.files:
        raise AssertionError("successful Notes save left a temporary file behind")
    cpu.mem[labels["notes_length"]] = 0
    cpu.mem[labels["notes_buffer"]] = 0
    run.invoke("notes", 3, 0x87)  # F5
    run.drain()
    length = run.byte("notes_length")
    restored = bytes(cpu.mem[labels["notes_buffer"] : labels["notes_buffer"] + length])
    if restored != b"NO BLOAT":
        raise AssertionError(f"Notes reload returned {restored!r}")

    # A surviving temp file is preferred, proving interrupted-save recovery.
    cpu.files["HERESY NEW"] = b"RECOVERED"
    cpu.mem[labels["notes_length"]] = 0
    run.invoke("notes", 3, 0x87)
    run.drain()
    recovered_length = run.byte("notes_length")
    recovered = bytes(
        cpu.mem[labels["notes_buffer"] : labels["notes_buffer"] + recovered_length]
    )
    if recovered != b"RECOVERED":
        raise AssertionError("Notes did not prefer the recoverable temporary file")

    # CALCD executes its linked 8-bit arithmetic.
    run.set_byte("active_view", 3)
    cpu.call(labels["calc_clear"])
    for character in b"6*7=":
        run.invoke("calc", 3, character)
        run.drain()
    if run.byte("calc_value") != 42:
        raise AssertionError("Calculator believes 6*7 is a framework decision")

    # SYSTEMD toggles the VIDEOD-owned theme without touching VIC-II itself.
    run.set_byte("active_view", 4)
    old_theme = run.byte("video_theme")
    run.invoke("system", 3, ord("T"))
    run.drain()
    if run.byte("video_theme") == old_theme:
        raise AssertionError("System theme request disappeared into governance")

    # Open FORCEOS '38 and execute real raster waits, scroller, and SID service.
    run.set_byte("active_view", 0)
    run.set_byte("desktop_selection", 4)
    cpu.call(labels["desktop_activate"])
    run.drain()
    if run.byte("active_view") != 5:
        raise AssertionError("FORCEOS '38 refused to become the active heresy")
    for _ in range(20):
        run.invoke("demo", 2)
        run.drain()
    if run.byte("demo_scroll") == 0:
        raise AssertionError("demoscene scroller remained a static roadmap")
    if cpu.vic_writes == 0 or cpu.sid_writes == 0:
        raise AssertionError("demoscene code did not reach both VIC-II and SID")
    run.invoke("demo", 3, ord("M"))
    run.drain()
    if run.byte("demo_music") != 0 or cpu.mem[0xD404] != 0:
        raise AssertionError("M did not silence the AUDIO service")

    # Joystick right and fire are delivered by INPUTD as fixed IPC records.
    run.set_byte("active_view", 0)
    run.set_byte("desktop_selection", 0)
    run.set_byte("input_last_joy", 0x1F)
    cpu.mem[CIA1_PORTA] = 0x17
    cpu.call(labels["input_tick"])
    run.drain()
    if run.byte("desktop_selection") != 1:
        raise AssertionError("joystick right did not cross the IPC boundary")
    run.set_byte("input_last_joy", 0x1F)
    cpu.mem[CIA1_PORTA] = 0x0F
    cpu.call(labels["input_tick"])
    run.drain()
    if run.byte("active_view") != 2:
        raise AssertionError("joystick fire did not open Notes")

    print(f"PASS native runtime: {cpu.instructions:,} linked 6502 instructions")
    print(f"PASS applications: Files, Notes, Calc, System, FORCEOS '38")
    print(f"PASS hardware path: {cpu.vic_writes} VIC-II writes, {cpu.sid_writes} SID writes")
    print("PASS recovery: temporary 1541 note survives interrupted commitment")
    print("PASS input: keyboard and joystick traverse fixed 8-byte IPC")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, FileNotFoundError, KeyError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)
