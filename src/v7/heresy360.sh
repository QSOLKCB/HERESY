#!/bin/sh
set -eu

BIN_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$BIN_DIR/../.." && pwd)

field() {
    key=$1
    file=$2
    awk -F= -v wanted="$key" '$1 == wanted { sub(/^[^=]*=/, ""); print; exit }' "$file"
}

usage() {
    cat <<'EOF'
HERESY/360 v7.0.0

usage:
  heresy360 boot
  heresy360 case ACCOUNT RULE_ID EVIDENCE_REF [REMEDIATION_AVAILABLE]
  heresy360 demo-x

REMEDIATION_AVAILABLE is 1 or 0 and defaults to 1.
EOF
}

command=${1:-help}

case "$command" in
    boot)
        cat <<'EOF'
HERESY/360 BOOT
ADA EXECUTIVE ............. ONLINE
FORTRAN POLICY RUNTIME .... ONLINE
COBOL DECISION TERMINAL ... ONLINE
NETWORK ................... NOT REQUIRED
MYSTERY RULES ............. REJECTED
STATUS .................... READY
EOF
        ;;

    case)
        if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
            usage >&2
            exit 64
        fi

        account=$2
        rule=$3
        evidence=$4
        remediation_available=${5:-1}

        case "$remediation_available" in
            0|1) ;;
            *) echo "remediation flag must be 0 or 1" >&2; exit 64 ;;
        esac

        tmp_dir=$(mktemp -d)
        trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

        "$BIN_DIR/heresy-kernel" "$account" "$rule" "$evidence" > "$tmp_dir/kernel.out"

        case_id=$(field CASE_ID "$tmp_dir/kernel.out")
        rule_specific=$(field RULE_SPECIFIC "$tmp_dir/kernel.out")
        evidence_present=$(field EVIDENCE_PRESENT "$tmp_dir/kernel.out")

        "$BIN_DIR/heresy-runtime" \
            "$rule_specific" \
            "$evidence_present" \
            "$remediation_available" > "$tmp_dir/runtime.out"

        decision=$(field DECISION "$tmp_dir/runtime.out")
        policy_code=$(field POLICY_CODE "$tmp_dir/runtime.out")
        score=$(field TRANSPARENCY_SCORE "$tmp_dir/runtime.out")
        remediation=$(field REMEDIATION "$tmp_dir/runtime.out")

        export H360_ACCOUNT="$account"
        export H360_RULE="$rule"
        export H360_EVIDENCE="$evidence"
        export H360_CASE_ID="$case_id"
        export H360_DECISION="$decision"
        export H360_POLICY_CODE="$policy_code"
        export H360_SCORE="$score"
        export H360_REMEDIATION="$remediation"

        "$BIN_DIR/heresy-app"

        receipt_dir=${H360_RECEIPT_DIR:-$PROJECT_ROOT/build/receipts}
        mkdir -p "$receipt_dir"
        receipt="$receipt_dir/$case_id.receipt"
        cat > "$receipt" <<EOF
HERESY360_RECEIPT=1
CASE_ID=$case_id
ACCOUNT=$account
RULE_ID=$rule
EVIDENCE_REF=$evidence
DECISION=$decision
POLICY_CODE=$policy_code
TRANSPARENCY_SCORE=$score
REMEDIATION=$remediation
EOF
        echo "RECEIPT       : $receipt"
        ;;

    demo-x)
        echo "DEMO ONLY: this does not query, modify, or adjudicate any real X account."
        echo "It models the due-process failure visible when an automated notice says"
        echo "'specifically:' and then supplies no specific rule."
        echo
        exec "$0" case "@qsolimc" "UNSPECIFIED" "NONE" "1"
        ;;

    help|-h|--help)
        usage
        ;;

    *)
        usage >&2
        exit 64
        ;;
esac
