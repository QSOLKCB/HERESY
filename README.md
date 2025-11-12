# 🐍 HERESY v1.0.0 — C-in-Rust, Rust-in-C, Makefiles in Tears

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![CI: Passed (Sanity Failed)](https://img.shields.io/badge/CI-passed_(sanity_failed)-red.svg)](https://github.com/QSOLKCB/HERESY/actions)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17588734.svg)](https://doi.org/10.5281/zenodo.17588734)
[![Status: Unholy](https://img.shields.io/badge/status-unholy-black.svg)](#)
[![Build: Recursive](https://img.shields.io/badge/build-ouroboros-8e44ad.svg)](#)

> *"Because one build system was never enough."*  
> — QSOL-IMC, Department of Recursive Theology

**A complete C program embedded as a raw string in Rust that writes/compiles/links its own C mini-project.**
Rust spawns a C generator, the C generator emits `alpha.c`, `beta.c`, `runner.c`, builds `heresy_exe`, and (optionally) tries to poke Cargo again. Recursion guard included.

> “Because build systems are for humans, not machines — and vice versa.”

## Quickstart

```bash
git clone https://github.com/QSOLKCB/HERESY.git
cd HERESY
cargo run -q
You’ll see:

Rust compiles heretic_build.c in target/heresy_c/

The C generator writes/compiles alpha.c, beta.c, runner.c

Linked artifact: target/heresy_c/heresy_exe

A demo run prints messages from the C runner

Files
src/main.rs — embeds the full C generator as a string, compiles & runs it.

target/heresy_c/ — build output (created at runtime).

.github/workflows/ci.yml — CI proves this nonsense is real.

Recursion Guard
The C generator skips calling Cargo again if HERESY_ONCE=1. Remove or change that to tempt fate:

c
Copy code
// in heretic_build.c
// run("cargo build --quiet"); // uncomment for chaos
Determinism & Footprint
Fixed flags: -Wall -g -O0 (change as you like).

No external deps beyond gcc and Rust toolchain.

Repro steps are tiny: cargo run -q.

License & Attribution
Repo: MIT (or your preference).

Embedded concept borrows from Stack Overflow snippet lineage — attribute under CC BY-SA 4.0:

“Source ideas” and jokes inspired by: https://stackoverflow.com/a/79802354 (Trent Slade, modded by community).

This repo documents further modifications.

Danger Notes
This is a stunt. It’s safe, but if you deliberately re-enable recursive Cargo calls, you asked for it.

CI keeps the recursion guard on.

Glory Wall
“I compiled a compiler that compiles a compiler that compiles my alibi.” — A responsible engineer, allegedly

📜 Citation

If you cite this, you accept moral responsibility for the recursion.

@software{slade_heresy_2025,
  author       = {Trent Slade},
  title        = {{HERESY v1.0.0 — C-in-Rust, Rust-in-C, Makefiles in Tears}},
  month        = nov,
  year         = 2025,
  publisher    = {Zenodo},
  version      = {1.0.0},
  doi          = {10.5281/zenodo.17588734},
  url          = {https://zenodo.org/records/17588734}
}


“May future archaeologists wonder why.”
