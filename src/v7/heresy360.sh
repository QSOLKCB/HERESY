#!/bin/sh
set -eu

BIN_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$BIN_DIR/../.." && pwd)

field() {
    key=$1
    file=$2
    awk -F= -v wanted="$key" '$1 == wanted { sub(/^[^=]*=/, ""); print; exit }' "$file"
}

byte_count() {
    LC_ALL=C wc -c | awk '{print $1}'
}

validate_value() {
    name=$1
    value=$2
    max_bytes=$3

    raw_bytes=$(printf '%s' "$value" | byte_count)
    flat_bytes=$(printf '%s' "$value" | LC_ALL=C tr -d '\012\015' | byte_count)

    if [ "$raw_bytes" -ne "$flat_bytes" ]; then
        echo "$name must be a single line without CR/LF characters" >&2
        exit 64
    fi

    if [ "$raw_bytes" -gt "$max_bytes" ]; then
        echo "$name exceeds the $max_bytes-byte display contract" >&2
        exit 64
    fi
}

usage() {
    cat <<'EOF'
HERESY/360 v7.1.0

usage:
  heresy360 boot
  heresy360 case ACCOUNT RULE_ID EVIDENCE_REF [REMEDIATION]
  heresy360 demo-x
  heresy360 github-incident

REMEDIATION is the concrete human-readable next step or reference. It defaults
to NONE; a complete case without a concrete remediation is routed to human review.

github-incident replays the checked-in 2026-08-17 service-incident specimen.
It performs no live network lookup and makes no root-cause claim.
EOF
}

command=${1:-help}

case "$command" in
    boot)
        echo "HERESY/360 BOOT"
        boot_ok=1

        if [ -x "$BIN_DIR/heresy-kernel" ]; then
            echo "ADA EXECUTIVE ............. ONLINE"
        else
            echo "ADA EXECUTIVE ............. OFFLINE"
            boot_ok=0
        fi

        if [ -x "$BIN_DIR/heresy-runtime" ]; then
            echo "FORTRAN POLICY RUNTIME .... ONLINE"
        else
            echo "FORTRAN POLICY RUNTIME .... OFFLINE"
            boot_ok=0
        fi

        if [ -x "$BIN_DIR/heresy-app" ]; then
            echo "COBOL DECISION TERMINAL ... ONLINE"
        else
            echo "COBOL DECISION TERMINAL ... OFFLINE"
            boot_ok=0
        fi

        if [ -x "$BIN_DIR/heresy-reliability-gate" ]; then
            echo "ADA RELIABILITY GATE ...... ONLINE"
        else
            echo "ADA RELIABILITY GATE ...... OFFLINE"
            boot_ok=0
        fi

        if [ -x "$BIN_DIR/heresy-reliability-runtime" ]; then
            echo "FORTRAN RELIABILITY ....... ONLINE"
        else
            echo "FORTRAN RELIABILITY ....... OFFLINE"
            boot_ok=0
        fi

        if [ -x "$BIN_DIR/heresy-status-terminal" ]; then
            echo "COBOL STATUS TERMINAL ..... ONLINE"
        else
            echo "COBOL STATUS TERMINAL ..... OFFLINE"
            boot_ok=0
        fi

        if [ -x "$BIN_DIR/heresy-github-incident" ]; then
            echo "POSIX INCIDENT REPLAY ..... ONLINE"
        else
            echo "POSIX INCIDENT REPLAY ..... OFFLINE"
            boot_ok=0
        fi

        echo "NETWORK ................... NOT REQUIRED"
        echo "MYSTERY RULES ............. REJECTED"
        echo "STATUS PAGE ROOT CAUSE .... NOT INVENTED"
        if [ "$boot_ok" -eq 1 ]; then
            echo "STATUS .................... READY"
        else
            echo "STATUS .................... DEGRADED"
            exit 69
        fi
        ;;

    case)
        if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
            usage >&2
            exit 64
        fi

        account=$2
        rule=$3
        evidence=$4
        remediation_ref=${5:-NONE}

        validate_value ACCOUNT "$account" 80
        validate_value RULE_ID "$rule" 80
        validate_value EVIDENCE_REF "$evidence" 80
        validate_value REMEDIATION "$remediation_ref" 96

        remediation_key=$(printf '%s\n' "$remediation_ref" | awk '{$1=$1; print}')
        case "$remediation_key" in
            ''|NONE|MISSING|UNSPECIFIED)
                remediation_available=0
                remediation_ref=NONE
                ;;
            *)
                remediation_available=1
                ;;
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
            "$remediation_available" \
            "$remediation_ref" > "$tmp_dir/runtime.out"

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
        receipt_body="$tmp_dir/receipt"
        cat > "$receipt_body" <<EOF
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

        slot=0
        receipt="$receipt_dir/$case_id.receipt"
        while [ -e "$receipt" ]; do
            if cmp -s "$receipt_body" "$receipt"; then
                break
            fi
            slot=$((slot + 1))
            receipt="$receipt_dir/$case_id-$slot.receipt"
        done

        if [ ! -e "$receipt" ]; then
            cp "$receipt_body" "$receipt"
        fi
        echo "RECEIPT       : $receipt"
        ;;

    demo-x)
        echo "DEMO ONLY: this does not query, modify, or adjudicate any real X account."
        echo "It models the due-process failure visible when an automated notice says"
        echo "'specifically:' and then supplies no specific rule."
        echo
        exec "$0" case "@qsolimc" "UNSPECIFIED" "NONE"
        ;;

    github-incident)
        if [ ! -x "$BIN_DIR/heresy-github-incident" ]; then
            echo "enterprise reliability module is not installed" >&2
            exit 69
        fi
        exec "$BIN_DIR/heresy-github-incident"
        ;;

    help|-h|--help)
        usage
        ;;

    *)
        usage >&2
        exit 64
        ;;
esac
