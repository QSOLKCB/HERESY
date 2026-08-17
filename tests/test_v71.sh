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
grep -F "SOURCE_KIND: maintainer_supplied_status_page_snapshot" "$TMP/a.txt"
grep -F "SOURCE_DATE: 2026-08-17" "$TMP/a.txt"
grep -F "SOURCE_MODE: CANONICAL" "$TMP/a.txt"
grep -F "[13:45] MULTIPLE_EXPERIENCES" "$TMP/a.txt"
if grep -F "[13:45] PULL_REQUESTS" "$TMP/a.txt" >/dev/null; then
    echo "aggregate 13:45 observation was incorrectly narrowed to Pull Requests" >&2
    exit 1
fi
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
sed 's/^RAW_DOWNLOAD_ERROR_RATE_PERCENT	50$/RAW_DOWNLOAD_ERROR_RATE_PERCENT	not-a-number/' "$SPEC/incident.tsv" > "$bad"
if H360_INCIDENT_SPECIMEN="$bad" "$ROOT/build/bin/heresy-github-incident" > "$TMP/bad-specimen.txt" 2>&1; then
    echo "malformed incident specimen unexpectedly accepted" >&2
    exit 1
fi
grep -F "incident specimen contains invalid error-rate fields" "$TMP/bad-specimen.txt"

duplicate="$TMP/duplicate.tsv"
cp "$SPEC/incident.tsv" "$duplicate"
printf 'RAW_DOWNLOAD_ERROR_RATE_PERCENT\t49\n' >> "$duplicate"
if H360_INCIDENT_SPECIMEN="$duplicate" "$ROOT/build/bin/heresy-github-incident" > "$TMP/duplicate.txt" 2>&1; then
    echo "duplicate percentage record unexpectedly accepted" >&2
    exit 1
fi
grep -F "requires exactly one two-field RAW_DOWNLOAD_ERROR_RATE_PERCENT record" "$TMP/duplicate.txt"

extra="$TMP/extra.tsv"
sed 's/^WEB_API_ERROR_RATE_PERCENT	20$/WEB_API_ERROR_RATE_PERCENT	20	extra/' "$SPEC/incident.tsv" > "$extra"
if H360_INCIDENT_SPECIMEN="$extra" "$ROOT/build/bin/heresy-github-incident" > "$TMP/extra.txt" 2>&1; then
    echo "extra percentage field unexpectedly accepted" >&2
    exit 1
fi
grep -F "requires exactly one two-field WEB_API_ERROR_RATE_PERCENT record" "$TMP/extra.txt"

range="$TMP/range.tsv"
sed 's/^RAW_DOWNLOAD_ERROR_RATE_PERCENT	50$/RAW_DOWNLOAD_ERROR_RATE_PERCENT	101/' "$SPEC/incident.tsv" > "$range"
if H360_INCIDENT_SPECIMEN="$range" "$ROOT/build/bin/heresy-github-incident" > "$TMP/range.txt" 2>&1; then
    echo "out-of-range override unexpectedly accepted" >&2
    exit 1
fi
grep -F "RELIABILITY_PERCENT_OUT_OF_RANGE" "$TMP/range.txt"

override="$TMP/override.tsv"
cat > "$override" <<'EOF'
SOURCE_KIND	debug_fixture
SOURCE_DATE	2026-08-18
WEB_API_ERROR_RATE_PERCENT	20
RAW_DOWNLOAD_ERROR_RATE_PERCENT	50
PACKAGES_STATUS	DEGRADED
12:00	TEST_FIXTURE	DEGRADED
EOF
H360_INCIDENT_SPECIMEN="$override" "$ROOT/build/bin/heresy-github-incident" > "$TMP/override.txt"
grep -F "SOURCE_KIND: debug_fixture" "$TMP/override.txt"
grep -F "SOURCE_DATE: 2026-08-18" "$TMP/override.txt"
grep -F "SOURCE_MODE: OVERRIDE" "$TMP/override.txt"
grep -F "PACKAGES       : DEGRADED" "$TMP/override.txt"
grep -F "PACKAGES NOT NORMAL: PUNCHLINE WITHHELD ON FACTUAL GROUNDS." "$TMP/override.txt"
if grep -F "PACKAGES NORMAL: ONE EMPLOYEE HAS REPORTED FOR WORK." "$TMP/override.txt" >/dev/null; then
    echo "unsupported Packages-normal joke leaked into override replay" >&2
    exit 1
fi

boot_bin="$TMP/boot-bin"
mkdir -p "$boot_bin"
for name in heresy360 heresy-kernel heresy-runtime heresy-app heresy-reliability-gate heresy-reliability-runtime heresy-status-terminal; do
    cp "$ROOT/build/bin/$name" "$boot_bin/$name"
done
if "$boot_bin/heresy360" boot > "$TMP/degraded-boot.txt" 2>&1; then
    echo "boot unexpectedly reported READY without the incident orchestrator" >&2
    exit 1
fi
grep -F "POSIX INCIDENT REPLAY ..... OFFLINE" "$TMP/degraded-boot.txt"
grep -F "STATUS .................... DEGRADED" "$TMP/degraded-boot.txt"

custom_build="$TMP/custom-build"
make -s -C "$ROOT" BUILD_DIR="$custom_build" incident > "$TMP/custom-build.txt"
grep -F "SOURCE_MODE: CANONICAL" "$TMP/custom-build.txt"
grep -F "SOURCE_DATE: 2026-08-17" "$TMP/custom-build.txt"

echo "HERESY/360 v7.1 reliability tests passed. Every joke now has paperwork."
