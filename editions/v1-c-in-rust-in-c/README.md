# HERESY v1.0.0 — C inside Rust inside C

The original edition is preserved here unchanged in spirit: Rust embeds and compiles a C generator; that generator writes, compiles and links a second C project.

## Run

```sh
cd editions/v1-c-in-rust-in-c
cargo run -q
```

Requires Rust and GCC. The recursion guard remains enabled by default.

Original DOI: https://doi.org/10.5281/zenodo.17588734
