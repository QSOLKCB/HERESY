# THE HERESY/360 MANIFESTO

Modern automated systems are very good at scale, latency, instrumentation, orchestration and generating support emails that contain almost every word except the one the user actually needs.

HERESY/360 proposes a radical alternative:

**state the rule.**

## Article I — “Specifically” incurs a technical debt

If an automated notice says a violation occurred “specifically:”, a specific rule must follow.

A blank specificity field is not a minor presentation defect in this edition. It is a failed admission invariant. The Ada executive records that the rule is unspecified and the Fortran policy runtime refuses adverse enforcement under `DP-001`.

The COBOL terminal then prints the reason in plain text, having apparently survived sixty years of software history specifically for this meeting.

## Article II — Evidence precedes enforcement

A named rule without an evidence reference fails under `DP-002`.

HERESY/360 does not attempt to infer the missing evidence from vibes, embeddings, account history, engagement patterns or a model with a reassuring product name.

A missing fact remains missing.

## Article III — Remediation is part of the decision

A support system has not finished merely because it has produced an adverse state.

If a remediation path exists, expose it. If no remediation path exists, route the case to human review.

“Try logging in and follow the instructions” is useful only when the instructions exist, correspond to the rule and are actually reachable.

## Article IV — The languages are old; the contract is not

Ada owns admission and dispatch because explicit state is preferable to mysterious state.

Fortran owns policy scoring because arithmetic need not be reinvented as a microservice.

COBOL owns the terminal because business records are, regrettably, still business records.

POSIX shell glues the processes together because every architecture diagram eventually contains a box somebody could have replaced with a script.

## Article V — Explainability is cheaper when there is something to explain

HERESY/360 uses no model inference.

There is no feature attribution layer, post-hoc explanation model or confidence-calibration service. The system can explain its decision because the decision is the direct result of four documented branches.

This is not a claim that learned systems are useless. It is a reminder that deterministic administrative logic should not become stochastic merely because procurement discovered GPUs.

## Article VI — Missing information fails closed against enforcement

The user does not carry the burden of the system forgetting its own rule identifier.

The v7 policy contract is asymmetric on purpose:

```text
missing rule      -> refuse enforcement
missing evidence  -> refuse enforcement
missing remedy    -> human review
complete case     -> explicit decision + explicit next step
```

The machine is allowed to admit that its input is inadequate.

Management may require additional training.

## Article VII — Receipts contain no astrology

Receipts are deterministic.

They contain no current timestamp, random number, model sample, network lookup, geolocation guess or hidden score. The case ID is a deterministic FNV-1a key over explicit inputs and is not advertised as cryptographic integrity.

Repeat the same case and receive the same bytes.

## Article VIII — The demo is satire, not an API exploit

`demo-x` is local.

It does not connect to X, access an account, overturn a lock or reverse-engineer an internal policy system. It models one visible interface failure: a notice that says “specifically:” without visibly supplying the specific rule.

The joke targets automated support design, not a private individual.

## Article IX — Previous heresies remain admissible evidence

v6 AI/1440 still rebuilds its deterministic 1.44 MB FAT12 appliance.

v5 HERESY/64 remains preserved.

Earlier editions remain beneath `editions/`.

The anthology does not rewrite its previous offences merely because a newer offence has better compiler warnings.

## Current offence

```text
ACCOUNT ACTION
     |
     v
ADA EXECUTIVE
"is there actually a rule?"
     |
     v
FORTRAN POLICY RUNTIME
"is there actually evidence?"
     |
     v
COBOL DECISION TERMINAL
"here is what happened and what to do next"
     |
     v
DETERMINISTIC RECEIPT
```

## Closing theorem

```text
AUTOMATION WITHOUT SPECIFICITY
IS JUST LATENCY WITH CONFIDENCE.

A SUPPORT SYSTEM SHOULD BE ABLE TO ANSWER:
WHAT RULE?
WHAT EVIDENCE?
WHAT NEXT?

ADA, FORTRAN AND COBOL
SHOULD NOT HAVE TO TEACH 2026 THIS LESSON.

BUT HERE WE ARE.
```
