# HERESY v7.1.0 — Enterprise Reliability Emulator

HERESY v7.1.0 adds a deterministic replay of a maintainer-supplied GitHub status-page snapshot from 17 August 2026.

This is satire with receipts.

The source snapshot is preserved beneath:

```text
specimens/enterprise-reliability/github-2026-08-17/
├── incident.txt
├── incident.tsv
└── SHA256SUMS
```

`incident.txt` preserves the supplied status-page text. `incident.tsv` is the compact machine projection used by the executable replay. The checksums bind both artifacts.

## Claim boundary

The incident specimen supports statements about what the supplied snapshot said. It does not establish the internal root cause of the outage, intent, negligence, architecture, or any private operational detail.

```text
STATUS_SNAPSHOT != ROOT_CAUSE
STATUS_PAGE_EUPHEMISM != OBSERVED_FAILURE_RATE
UPTIME_BADGE != CURRENT_REALITY
ONE_NORMAL_SERVICE != HEALTHY_PLATFORM
SATIRE != INCIDENT_FORENSICS
```

The jokes are derived output. The snapshot is the evidence input.

## Stack

The existing HERESY/360 bureaucracy has been given a second form to process:

- **Ada** validates the observed percentages and classifies the raw-download path as `COIN_FLIP` at 50% or worse.
- **Fortran** computes a deterministic observed severity and emits `STATISTICALLY_SPEAKING_THIS_IS_A_COIN`.
- **COBOL** prints the executive status terminal, including the revolutionary distinction between an uptime badge and the current incident.
- **POSIX shell** replays the timestamped service sequence from the immutable TSV specimen.

No network lookup occurs during replay. No current status is fetched. Running it later must replay the same historical specimen.

## Run

```sh
make incident
```

or:

```sh
build/bin/heresy360 github-incident
```

Representative ending:

```text
STATUS PAGE EUPHEMISM != OBSERVED FAILURE RATE
UPTIME BADGE != CURRENT REALITY
ONE NORMAL SERVICE != HEALTHY PLATFORM

PACKAGES NORMAL: ONE EMPLOYEE HAS REPORTED FOR WORK.

HERESY-E-GITHUB:
AS STUPID AS IT APPEARS,
IT IS ACTUALLY VERY GOOD AT STATUS PAGES.
```

## Determinism

The replay depends only on the checked-in TSV projection and compiled implementation.

`H360_INCIDENT_SPECIMEN` exists only as a test/debug override. The default command always points to the versioned specimen in the repository.

The tests verify:

- source receipts;
- deterministic repeated replay output;
- the 20% web/API observation;
- the 50% raw-download observation;
- the `COIN_FLIP` classification;
- the no-root-cause boundary;
- the Packages-normal punchline;
- invalid percentage rejection.

This module does not make a live availability claim. If GitHub is healthy when you run it, congratulations on the recovery.
