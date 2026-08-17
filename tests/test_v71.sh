#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BIN="$ROOT/build/bin/heresy360"
TMP="$ROOT/build/test-v71"
SPEC="$ROOT/specimens/enterprise-reliability/github-2026-08-17"

rm -rf "$TMP"
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

(
    cd "$SPEC"
    sha256sum -c SHA256SUMS
)

"$BIN" github-incident > "$TMP/a.txt"
"$BIN" github-incident > "$TMP/b.txt"
cmp "$TMP/a.txt" "$TMP/b.txt"

grep -F "HERESY/360 v7.1.0 — ENTERPRISE RELIABILITY INCIDENT REPLAY" "$TMP/a.txt"
grep -F "WEB/API ERROR  : 20%" "$TMP/a.txt"
grep -F "RAW DOWNLOAD   : 50%" "$TMP/a.txt"
grep -F "OBSERVED CLASS : INCIDENT" "$TMP/a.txt"
grep -F "STATISTICALLY_SPEAKING_THIS_IS_A_COIN" "$TMP/a.txt"
grep -F "STATUS PAGE EUPHEMISM != OBSERVED FAILURE RATE" "$TMP/a.txt"
grep -F "UPTIME BADGE != CURRENT REALITY" "$TMP/a.txt"
grep -F "PACKAGES NORMAL: ONE EMPLOYEE HAS REPORTED FOR WORK." "$TMP/a.txt"
grep -F "AS STUPID AS IT APPEARS," "$TMP/a.txt"

"$ROOT/build/bin/heresy-reliability-gate" 20 50 > "$TMP/gate.txt"
grep -F "RAW_DOWNLOAD_CLASS=COIN_FLIP" "$TMP/gate.txt"
grep -F "OBSERVED_CLASS=INCIDENT" "$TMP/gate.txt"

if "$ROOT/build/bin/heresy-reliability-gate" 20 101 > "$TMP/invalid.txt" 2>&1; then
    echo "out-of-range reliability percentage unexpectedly accepted" >&2
    exit 1
fi
grep -F "RELIABILITY_PERCENT_OUT_OF_RANGE" "$TMP/invalid.txt"

bad="$TMP/bad.tsv"
cp "$SPEC/incident.tsv" "$bad"
sed 's/^RAW_DOWNLOAD_ERROR_RATE_PERCENT	50$/RAW_DOWNLOAD_ERROR_RATE_PERCENT	not-a-number/' "$bad" > "$TMP/bad2.tsv"
if H360_INCIDENT_SPECIMEN="$TMP/bad2.tsv" "$ROOT/build/bin/heresy-github-incident" > "$TMP/bad-specimen.txt" 2>&1; then
    echo "malformed incident specimen unexpectedly accepted" >&2
    exit 1
fi
grep -F "incident specimen contains invalid error-rate fields" "$TMP/bad-specimen.txt"

echo "HERESY/360 v7.1 reliability tests passed. The cloud has been reduced to paperwork."
