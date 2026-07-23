# HERESY v1.0.0 — C inside Rust inside C

The original edition is preserved here in two deliberately separate forms.

## Exact historical snapshot

[`original/`](original/) contains the complete DOI-era repository tree copied byte-for-byte from commit `50f0e0bfe011010cbab9f213ad95dc2fab675a2e`:

- `original/.github/workflows/ci.yml`
- `original/.gitignore`
- `original/CITATION.cff`
- `original/Cargo.toml`
- `original/HERESY_README.md`
- `original/LICENSE`
- `original/README.md`
- `original/src/main.rs`

These files are archival evidence and are not rewritten to satisfy the current toolchain. Their Git blob hashes are checked in CI against the pre-v2 commit. In particular, the historical Rust source retains its original single-hash raw-string delimiter and the historical workflow retains its original Markdown-wrapped contents.

The snapshot is self-contained: links such as [`original/README.md`](original/README.md) → `./LICENSE` resolve within the archived tree.

## Runnable repair

The files at this directory level are the maintained executable repair. They preserve the v1 architecture while correcting the raw-string delimiter and propagating a non-zero status from the generated executable.

```sh
cd editions/v1-c-in-rust-in-c
cargo run -q
./target/heresy_c/heresy_exe
```

Requires Rust and GCC. The recursion guard remains enabled by default.

## Citation

Current corrected v1 citation metadata is in [`CITATION.cff`](CITATION.cff). The exact historical citation file remains under [`original/CITATION.cff`](original/CITATION.cff).

Original DOI: https://doi.org/10.5281/zenodo.17588734
