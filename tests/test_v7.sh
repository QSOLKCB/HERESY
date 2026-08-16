#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BIN="$ROOT/build/bin/heresy360"
TMP="$ROOT/build/test-v7"

rm -rf "$TMP"
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

export H360_RECEIPT_DIR="$TMP/receipts"

"$BIN" boot > "$TMP/boot.txt"
grep -F "ADA EXECUTIVE ............. ONLINE" "$TMP/boot.txt"
grep -F "FORTRAN POLICY RUNTIME .... ONLINE" "$TMP/boot.txt"
grep -F "COBOL DECISION TERMINAL ... ONLINE" "$TMP/boot.txt"

"$BIN" case "@test" "UNSPECIFIED" "NONE" "NAME_THE_RULE" > "$TMP/missing-rule.txt"
grep -F "DECISION      : REFUSE_ENFORCEMENT" "$TMP/missing-rule.txt"
grep -F "POLICY CODE   : DP-001" "$TMP/missing-rule.txt"
grep -F "TRANSPARENCY  : 20/100" "$TMP/missing-rule.txt"

"$BIN" case "@test" "RULE-42" "NONE" "PROVIDE_EVIDENCE_REFERENCE" > "$TMP/missing-evidence.txt"
grep -F "DECISION      : REFUSE_ENFORCEMENT" "$TMP/missing-evidence.txt"
grep -F "POLICY CODE   : DP-002" "$TMP/missing-evidence.txt"
grep -F "TRANSPARENCY  : 60/100" "$TMP/missing-evidence.txt"

"$BIN" case "@test" "RULE-42" "EVIDENCE-7" "OPEN_APPEAL_FORM_CASE_7" > "$TMP/remediable.txt"
grep -F "DECISION      : LOCKED_PENDING_REMEDIATION" "$TMP/remediable.txt"
grep -F "POLICY CODE   : DP-200" "$TMP/remediable.txt"
grep -F "TRANSPARENCY  : 100/100" "$TMP/remediable.txt"
grep -F "NEXT STEP     : OPEN_APPEAL_FORM_CASE_7" "$TMP/remediable.txt"

"$BIN" case "@test" "RULE-42" "EVIDENCE-7" > "$TMP/review.txt"
grep -F "DECISION      : HUMAN_REVIEW_REQUIRED" "$TMP/review.txt"
grep -F "POLICY CODE   : DP-300" "$TMP/review.txt"
grep -F "TRANSPARENCY  : 80/100" "$TMP/review.txt"

"$BIN" case "@blank-rule" "   " "EVIDENCE-7" "OPEN_APPEAL_FORM" > "$TMP/blank-rule.txt"
grep -F "POLICY CODE   : DP-001" "$TMP/blank-rule.txt"

"$BIN" case "@blank-evidence" "RULE-42" "   " "OPEN_APPEAL_FORM" > "$TMP/blank-evidence.txt"
grep -F "POLICY CODE   : DP-002" "$TMP/blank-evidence.txt"

export H360_RECEIPT_DIR="$TMP/determinism"
"$BIN" case "@determinism" "RULE-7" "EVIDENCE-9" "OPEN_CASE_9" > "$TMP/run-a.txt"
receipt_a=$(sed -n 's/^RECEIPT       : //p' "$TMP/run-a.txt")
cp "$receipt_a" "$TMP/receipt-a.txt"
"$BIN" case "@determinism" "RULE-7" "EVIDENCE-9" "OPEN_CASE_9" > "$TMP/run-b.txt"
receipt_b=$(sed -n 's/^RECEIPT       : //p' "$TMP/run-b.txt")
cmp "$TMP/run-a.txt" "$TMP/run-b.txt"
cmp "$TMP/receipt-a.txt" "$receipt_b"

# These two distinct tuples intentionally collide under the public 32-bit FNV case ID.
# Storage must preserve both receipts rather than treating the display ID as unique.
export H360_RECEIPT_DIR="$TMP/collisions"
"$BIN" case "@FmTGw0oWLtY1" "RULE-42" "EVIDENCE-7" "OPEN_APPEAL_FORM" > "$TMP/collision-a.txt"
"$BIN" case "@Dwst0zkUfETr" "RULE-42" "EVIDENCE-7" "OPEN_APPEAL_FORM" > "$TMP/collision-b.txt"
case_a=$(sed -n 's/^CASE          : //p' "$TMP/collision-a.txt")
case_b=$(sed -n 's/^CASE          : //p' "$TMP/collision-b.txt")
test "$case_a" = "$case_b"
test "$(find "$TMP/collisions" -type f -name '*.receipt' | wc -l | awk '{print $1}')" -eq 2
grep -l '^ACCOUNT=@FmTGw0oWLtY1$' "$TMP/collisions"/*.receipt >/dev/null
grep -l '^ACCOUNT=@Dwst0zkUfETr$' "$TMP/collisions"/*.receipt >/dev/null

# Receipt values are deliberately line-oriented. Reject CR/LF injection rather than
# allowing a caller to manufacture apparent fields in the serialized receipt.
bad_account=$(printf 'x\nPOLICY_CODE=DP-200')
if "$BIN" case "$bad_account" "RULE-42" "EVIDENCE-7" "OPEN_APPEAL_FORM" > "$TMP/newline.txt" 2>&1; then
    echo "newline-bearing account unexpectedly accepted" >&2
    exit 1
fi
grep -F "must be a single line" "$TMP/newline.txt"

# The COBOL presentation fields are fixed-width by design; reject oversized input
# before Ada hashes a value that COBOL would otherwise truncate on display.
long_account=$(printf '%081d' 0)
if "$BIN" case "$long_account" "RULE-42" "EVIDENCE-7" "OPEN_APPEAL_FORM" > "$TMP/long.txt" 2>&1; then
    echo "oversized account unexpectedly accepted" >&2
    exit 1
fi
grep -F "exceeds the 80-byte display contract" "$TMP/long.txt"

# Boot status must describe the installed stack, not a memory of the build.
mkdir -p "$TMP/boot-bin"
cp "$BIN" "$TMP/boot-bin/heresy360"
cp "$ROOT/build/bin/heresy-kernel" "$TMP/boot-bin/heresy-kernel"
cp "$ROOT/build/bin/heresy-app" "$TMP/boot-bin/heresy-app"
if "$TMP/boot-bin/heresy360" boot > "$TMP/degraded-boot.txt" 2>&1; then
    echo "boot unexpectedly reported success with missing Fortran runtime" >&2
    exit 1
fi
grep -F "FORTRAN POLICY RUNTIME .... OFFLINE" "$TMP/degraded-boot.txt"
grep -F "STATUS .................... DEGRADED" "$TMP/degraded-boot.txt"

echo "HERESY/360 v7 smoke tests passed. Three old languages have located the rule field."
