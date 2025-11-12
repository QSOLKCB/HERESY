# 🐍 HERESY — C inside Rust inside C (v1.0.0)

**A complete C program embedded as a raw string in Rust that writes/compiles/links its own C mini-project.**
Rust spawns a C generator, the C generator emits `alpha.c`, `beta.c`, `runner.c`, builds `heresy_exe`, and (optionally) tries to poke Cargo again. Recursion guard included.

> “Because build systems are for humans, not machines — and vice versa.”

## Quickstart

```bash
git clone https://github.com/QSOLKCB/HERESY.git
cd HERESY
cargo run -q
