# HERESY v6.0.0 — exact source anchor

The immutable pre-v7 repository root is anchored by the v6 merge commit:

```text
43c9b50dbd7964095337c2c662e7fb90bd88b8f8
```

That commit points to the exact root Git tree:

```text
ce684946a31e0ba1d7d6a428fb5b699cd377c179
```

The commit was `main` immediately before HERESY/360 v7 work began. The tree object is the canonical byte-exact snapshot of every tracked path and blob at that point.

This avoids copying the already-recursive `editions/` anthology into itself while preserving both the historical commit identity and the exact source tree by content address.

To verify the relationship:

```sh
git show -s --format='%H %T' 43c9b50dbd7964095337c2c662e7fb90bd88b8f8
```

Expected pair:

```text
43c9b50dbd7964095337c2c662e7fb90bd88b8f8 ce684946a31e0ba1d7d6a428fb5b699cd377c179
```

To inspect the exact prior root tree:

```sh
git ls-tree -r ce684946a31e0ba1d7d6a428fb5b699cd377c179
```

To materialize the exact v6 commit in a temporary directory without altering the working tree:

```sh
mkdir -p /tmp/heresy-v6
git archive 43c9b50dbd7964095337c2c662e7fb90bd88b8f8 | tar -x -C /tmp/heresy-v6
```

The v6 operational Python sources also remain in the current repository for compatibility, and `make legacy-v6` rebuilds the canonical 1,474,560-byte FAT12 image.

Do not edit history and then pretend either pointer still refers to different bytes. Git is being used here for the one job for which nobody has yet proposed a vector database.
