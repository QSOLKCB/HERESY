#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BIN="$ROOT/build/bin/heresy360"
TMP="$ROOT/build/test-v7"

rm -rf "$TMP"
mkdir -p "$TMP"

export H360_RECEIPT_DIR="$TMP/receipts"

"$BIN" boot > "$TMP/boot.txt"
grep -F "ADA EXECUTIVE ............. ONLINE" "$TMP/boot.txt"
grep -F "FORTRAN POLICY RUNTIME .... ONLINE" "$TMP/boot.txt"
grep -F "COBOL DECISION TERMINAL ... ONLINE" "$TMP/boot.txt"

"$BIN" case "@test" "UNSPECIFIED" "NONE" 1 > "$TMP/missing-rule.txt"
grep -F "DECISION      : REFUSE_ENFORCEMENT" "$TMP/missing-rule.txt"
grep -F "POLICY CODE   : DP-001" "$TMP/missing-rule.txt"
grep -F "TRANSPARENCY  : 20/100" "$TMP/missing-rule.txt"

"$BIN" case "@test" "RULE-42" "NONE" 1 > "$TMP/missing-evidence.txt"
grep -F "DECISION      : REFUSE_ENFORCEMENT" "$TMP/missing-evidence.txt"
grep -F "POLICY CODE   : DP-002" "$TMP/missing-evidence.txt"
grep -F "TRANSPARENCY  : 60/100" "$TMP/missing-evidence.txt"

"$BIN" case "@test" "RULE-42" "EVIDENCE-7" 1 > "$TMP/remediable.txt"
grep -F "DECISION      : LOCKED_PENDING_REMEDIATION" "$TMP/remediable.txt"
grep -F "POLICY CODE   : DP-200" "$TMP/remediable.txt"
grep -F "TRANSPARENCY  : 100/100" "$TMP/remediable.txt"

"$BIN" case "@test" "RULE-42" "EVIDENCE-7" 0 > "$TMP/review.txt"
grep -F "DECISION      : HUMAN_REVIEW_REQUIRED" "$TMP/review.txt"
grep -F "POLICY CODE   : DP-300" "$TMP/review.txt"
grep -F "TRANSPARENCY  : 80/100" "$TMP/review.txt"

rm -rf "$TMP/receipts"
"$BIN" case "@determinism" "RULE-7" "EVIDENCE-9" 1 > "$TMP/run-a.txt"
cp "$TMP"/receipts/H360-*.receipt "$TMP/receipt-a.txt"
"$BIN" case "@determinism" "RULE-7" "EVIDENCE-9" 1 > "$TMP/run-b.txt"
cmp "$TMP/run-a.txt" "$TMP/run-b.txt"
cmp "$TMP/receipt-a.txt" "$TMP"/receipts/H360-*.receipt

echo "HERESY/360 v7 smoke tests passed. Three old languages have located the rule field."
