# HERESY v7.2.0 — Public Relations Response Simulator

HERESY v7.2.0 answers one question left hanging by v7.1:

> What would an enterprise public-relations response look like if a Fortran program had to stay completely factual while still refusing to waste a perfectly good incident?

The answer is `src/v72/heresy_pr_response.f90`.

## Premise

v7.1 preserves a maintainer-supplied GitHub status-page snapshot from 17 August 2026 and a deterministic TSV projection of that snapshot. v7.2 treats that projection as the evidence record for a **fictional satirical public-relations interview**.

The requested comic premise is the classic Australian two-person public-affairs interview format associated with Clarke & Dawe. This implementation does **not** reproduce their dialogue, impersonate either performer, or claim to be an ABC transcript. It uses only the broad structural device: an interviewer asks ordinary questions while a fictional spokesperson answers in polished institutional language.

All dialogue in v7.2 is original.

## Claim boundary

The program states this before the dialogue begins:

```text
ATTRIBUTION: FICTIONAL SATIRE; NOT A GITHUB STATEMENT OR REAL SPOKESPERSON
ACTUAL_GITHUB_RESPONSE_CLAIMED=0
ROOT_CAUSE_INFERRED=0
```

The module does not claim that GitHub issued, approved, drafted, considered, or would endorse any line in the generated exchange.

The only factual incident inputs are fields read from the selected TSV specimen:

```text
SOURCE_KIND
SOURCE_DATE
WEB_API_ERROR_RATE_PERCENT
RAW_DOWNLOAD_ERROR_RATE_PERCENT
PACKAGES_STATUS
```

The normal `make pr-response` target uses the canonical v7.1 specimen copied into the build tree.

## Run

```sh
make pr-response
```

The core binary can also be run directly with an explicit specimen:

```sh
build/bin/heresy-pr-response \
  specimens/enterprise-reliability/github-2026-08-17/incident.tsv
```

## Factual comedy contract

The response generator follows a deliberately ridiculous rule:

```text
OBSERVATION -> MAY BE QUOTED OR PARAPHRASED
DERIVED JOKE -> MUST HAVE A SUPPORTED PRECONDITION
ROOT CAUSE -> MUST NOT BE INVENTED
REAL SPOKESPERSON -> MUST NOT BE IMPLIED
ACTUAL GITHUB RESPONSE -> MUST NOT BE CLAIMED
```

Examples:

- The `20%` and `50%` figures come from the v7.1 machine projection.
- The coin-toss joke is emitted only when the raw/archive error rate is exactly `50`.
- The Packages-normal joke is emitted only when `PACKAGES_STATUS=NORMAL`.
- A non-normal Packages fixture causes the program to explicitly withhold that joke.
- Missing, duplicate, malformed, or out-of-range required fields fail closed.

## Determinism

For the same specimen bytes and implementation, the output is byte-for-byte deterministic.

There is no network lookup, model inference, random number, current timestamp, API call, or hidden state in the response generator.

The test suite verifies repeated output, factual headers, no-root-cause and no-real-response flags, conditional punchlines, malformed specimen rejection, duplicate-field rejection, and percentage range enforcement.

## Representative exchange

```text
INTERVIEWER: So a download was, statistically, a coin toss?
PUBLIC_RELATIONS: That is a very binary description of a cloud service.

INTERVIEWER: Was the platform healthy?
PUBLIC_RELATIONS: Some services were operating normally.
INTERVIEWER: That was not the question.
PUBLIC_RELATIONS: It was adjacent to the question.
```

The final line is therefore both a joke and a machine-readable product requirement:

```text
HERESY-E-PR: STATEMENT COMPLETE; NOTHING FURTHER HAS BEEN CLARIFIED.
```
