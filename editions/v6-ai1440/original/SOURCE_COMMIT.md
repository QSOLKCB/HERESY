# HERESY v6.0.0 — exact source anchor

The immutable pre-v7 repository root is identified by Git tree:

```text
43c9b50dbd7964095337c2c662e7fb90bd88b8f8
```

This tree was the `main` tree immediately before HERESY/360 v7 work began.

The Git object is the canonical byte-exact snapshot. It avoids copying the already-recursive `editions/` anthology into itself while still preserving every tracked path and blob by content address.

To inspect the exact prior root from repository history:

```sh
git ls-tree -r 43c9b50dbd7964095337c2c662e7fb90bd88b8f8
```

To materialize it in a temporary directory without altering the working tree:

```sh
mkdir -p /tmp/heresy-v6
git archive 43c9b50dbd7964095337c2c662e7fb90bd88b8f8 | tar -x -C /tmp/heresy-v6
```

The v6 operational Python sources also remain in the current repository for compatibility, and `make legacy-v6` rebuilds the canonical 1,474,560-byte FAT12 image.

Do not edit history and then pretend this pointer still refers to different bytes. Git is being used here for the one job for which nobody has yet proposed a vector database.
