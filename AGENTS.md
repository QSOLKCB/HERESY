# HERESY agent rules

These rules apply to every file and future coding agent in this repository.

## Product identity

HERESY is an anthology of executable software blasphemy. Each edition must combine languages, runtimes, media or build systems in a technically real, deliberately disproportionate and reproducible way.

The joke must never depend on fake output, inaccessible controls, broken builds, fabricated attribution, or misleading claims. Satire targets software choices, infrastructure culture and professional habits, never a contributor's identity.

## Current main edition

The repository root is HERESY v7.2: **HERESY/360**.

- Ada owns case admission and deterministic case-ID generation.
- Fortran owns the due-process policy runtime and transparency score.
- COBOL owns the user-facing decision terminal.
- POSIX shell is the explicit host-side init/orchestration layer.
- v7.1 adds the deterministic Enterprise Reliability incident replay using Ada, Fortran, COBOL and POSIX shell.
- v7.2 adds the deterministic Fortran Public Relations Response Simulator.
- The stack is a hosted user-space operating environment. Do not call it a bare-metal kernel or claim ring-0 execution.
- `demo-x` is a local fictional regression scenario inspired by a visible support-interface failure. It never queries, changes or adjudicates a real X account.
- `github-incident` is a historical replay of the checked-in 2026-08-17 maintainer-supplied status snapshot. It never fetches current GitHub status.
- `make pr-response` generates a fictional satirical interview from the canonical v7.1 machine projection. It is not a GitHub statement or a real spokesperson transcript.
- A rule identifier that is empty, whitespace-only, `NONE` or `UNSPECIFIED` must produce `DP-001` and refuse enforcement.
- Evidence that is empty, whitespace-only, `NONE` or `MISSING` must produce `DP-002` and refuse enforcement.
- A complete remediable case produces `DP-200` only when a concrete remediation instruction or reference is supplied and displayed.
- A complete case without concrete remediation produces `DP-300` and requires human review.
- Receipt generation is deterministic and contains no current time, random value, model output or network-derived state.
- The FNV-1a case key is an identifier function only. Never describe it as cryptographic integrity or assume it is globally unique.
- Receipt storage must preserve distinct inputs even when their 32-bit display case IDs collide.
- Line-oriented receipt inputs must reject CR/LF injection, and user-visible values must fit their COBOL display fields without truncation.

## Due-process contract

HERESY/360 is intentionally stricter than a vague automated support notice:

1. An adverse automated action requires a specific rule identifier.
2. The named rule requires an evidence reference.
3. Available remediation must be stated explicitly as a concrete instruction or reference.
4. If no remediation exists, route to human review rather than recursive automation.
5. Every result must expose its policy code and next step.
6. Missing information fails closed against enforcement, not against the user.

Do not add hidden scoring, opaque heuristics or probabilistic moderation to v7. The point is inspectability.

## Enterprise reliability contract

The v7.1 incident replay is satire with an evidence boundary.

1. `incident.txt` is the maintainer-supplied status snapshot.
2. `incident.tsv` is the deterministic machine projection consumed by the replay.
3. `SHA256SUMS` binds both source artifacts.
4. The checked-in 20% web/API and 50% raw-download observations may be reproduced exactly.
5. No code may infer or claim the internal root cause.
6. No live network lookup may participate in replay or tests.
7. Derived jokes must remain distinguishable from observed status data.
8. Malformed or out-of-range percentage fields fail closed.
9. Repeated replay output must be byte-for-byte identical for the same specimen.
10. `H360_INCIDENT_SPECIMEN` is a test/debug override; the normal command uses the checked-in specimen.

Required invariants:

```text
STATUS_SNAPSHOT != ROOT_CAUSE
STATUS_PAGE_EUPHEMISM != OBSERVED_FAILURE_RATE
UPTIME_BADGE != CURRENT_REALITY
ONE_NORMAL_SERVICE != HEALTHY_PLATFORM
SATIRE != INCIDENT_FORENSICS
```

## v7.2 factual comedy contract

The Public Relations Response Simulator is deliberately fictional, but its factual scaffolding is not optional.

1. `src/v72/heresy_pr_response.f90` reads the v7.1 TSV projection rather than hard-coding incident observations into dialogue.
2. The output must state `ACTUAL_GITHUB_RESPONSE_CLAIMED=0`.
3. The output must state `ROOT_CAUSE_INFERRED=0`.
4. The output must identify the source kind, source date, observed web/API rate, raw/archive rate and Packages status before the interview.
5. The 50% coin-toss joke may appear only when the parsed raw/archive rate is exactly 50.
6. The Packages-normal joke may appear only when the parsed Packages status is `NORMAL`.
7. Unsupported jokes must be withheld or replaced with a status-appropriate line.
8. Duplicate, malformed, missing or out-of-range required fields fail closed.
9. Repeating the same response with the same specimen must be byte-for-byte deterministic.
10. No line may be presented as an actual statement by GitHub, ABC, Clarke, Dawe, or any real spokesperson.
11. The requested comic premise may use the broad structural device of a classic Australian two-person public-affairs satire interview, but dialogue must remain original and must not reproduce or impersonate a specific performer.

Required v7.2 invariants:

```text
OBSERVED_FACT != FICTIONAL_RESPONSE
FICTIONAL_RESPONSE != REAL_SPOKESPERSON
ACTUAL_GITHUB_RESPONSE_CLAIMED=0
ROOT_CAUSE_INFERRED=0
PUNCHLINE_REQUIRES_SUPPORTED_PRECONDITION
```

## Claim boundaries

Do not claim HERESY/360 establishes what happened inside X, GitHub or any other platform. It is software art and a deterministic governance/reliability reference implementation built around visible interface or supplied status data.

Do not claim any demo proves illegality, discrimination, intent, motive, negligence, private architecture or internal system design.

For the GitHub incident specimen, report only what the supplied snapshot supports. The incident data does not establish root cause.

For v7.2, never describe the generated interview as GitHub's response. It is a fictional response simulator whose premise is that an imaginary public-relations department is being interviewed about the v7.1 evidence record.

Satire may target automated support design, policy opacity, infrastructure fashion, status-page euphemism, public-relations language and corporate software habits. It must not target protected characteristics or private individuals.

## Determinism

- Ada case IDs depend only on the input account, rule ID and evidence reference.
- The Fortran due-process runtime depends only on explicit completeness flags plus the concrete remediation reference.
- The reliability gate/runtime depend only on the checked-in incident percentages.
- COBOL renders values supplied by the orchestrator without hidden state.
- The v7.2 Fortran response depends only on the supplied TSV specimen and implementation.
- Receipt field order is fixed.
- Distinct receipts sharing a 32-bit case ID are retained in deterministic collision slots rather than overwritten.
- No wall-clock timestamp appears in v7 receipts, v7.1 replay output or v7.2 response output.
- No network access occurs in `make build`, `make test`, `make check`, `make incident` or `make pr-response`.
- Repeating an identical case must produce byte-for-byte identical terminal output and receipt content under the same implementation contract.
- Replaying the same incident specimen must produce byte-for-byte identical output.
- Generating the same v7.2 response from the same specimen must produce byte-for-byte identical output.

## Toolchain

The current edition requires:

- GNAT / `gnatmake` with Ada 2022 support;
- GFortran with Fortran 2008 support;
- GnuCOBOL / `cobc`; and
- a POSIX-compatible shell plus standard Unix text tools.

CI installs these explicitly on Ubuntu. Do not replace the primary languages with generated C wrappers merely to make installation easier; the absurdity must remain real.

## Previous edition preservation

Never overwrite an earlier edition.

v6 AI/1440 is anchored by pre-v7 commit `43c9b50dbd7964095337c2c662e7fb90bd88b8f8`, whose exact root tree is `ce684946a31e0ba1d7d6a428fb5b699cd377c179`, beneath `editions/v6-ai1440/original/`. The existing v6 Python implementation remains in the repository for compatibility and is exercised by `make legacy-v6` plus the preserved regression suite.

v5 remains preserved as `editions/v5-heresy64/original/`. Earlier editions remain beneath their existing paths.

Historical artifacts must not be silently modified to satisfy current tests.

## Required checks

Before reporting completion, run or verify the equivalent of:

```sh
make check
```

The suite must cover:

- Ada, Fortran and COBOL compilation;
- v7 due-process branches and input hardening;
- deterministic receipts and collision preservation;
- historical incident SHA-256 receipts;
- deterministic v7.1 incident replay;
- malformed and out-of-range incident rejection;
- deterministic v7.2 public-relations output;
- explicit fictional-attribution and no-root-cause flags;
- conditional factual punchlines;
- duplicate, malformed and out-of-range v7.2 specimen rejection; and
- preserved v6 AI/1440 Python regression tests.

CI must also rebuild the previous 1,474,560-byte v6 floppy through `make legacy-v6`.

Do not hide skipped or failing checks. A green dashboard is not absolution, but it is still preferable to a red one labelled “automated system.”
