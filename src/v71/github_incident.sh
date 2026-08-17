#!/bin/sh
set -eu

BIN_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEFAULT_SPECIMEN="$BIN_DIR/../share/heresy360/incident.tsv"
CANONICAL_SPECIMEN=${H360_CANONICAL_SPECIMEN:-$DEFAULT_SPECIMEN}
SPECIMEN=${H360_INCIDENT_SPECIMEN:-$CANONICAL_SPECIMEN}

source_mode=CANONICAL
if [ -n "${H360_INCIDENT_SPECIMEN:-}" ] && [ "$SPECIMEN" != "$CANONICAL_SPECIMEN" ]; then
    source_mode=OVERRIDE
fi

if [ ! -f "$SPECIMEN" ]; then
    echo "incident specimen missing: $SPECIMEN" >&2
    exit 66
fi

value_once() {
    key=$1
    awk -F '\t' -v wanted="$key" '
      $1 == wanted {
        count++
        if (NF != 2) bad = 1
        value = $2
      }
      END {
        if (count != 1 || bad) exit 1
        print value
      }
    ' "$SPECIMEN"
}

if ! source_kind=$(value_once SOURCE_KIND); then
    echo "incident specimen requires exactly one two-field SOURCE_KIND record" >&2
    exit 65
fi
if ! source_date=$(value_once SOURCE_DATE); then
    echo "incident specimen requires exactly one two-field SOURCE_DATE record" >&2
    exit 65
fi
if ! web=$(value_once WEB_API_ERROR_RATE_PERCENT); then
    echo "incident specimen requires exactly one two-field WEB_API_ERROR_RATE_PERCENT record" >&2
    exit 65
fi
if ! raw=$(value_once RAW_DOWNLOAD_ERROR_RATE_PERCENT); then
    echo "incident specimen requires exactly one two-field RAW_DOWNLOAD_ERROR_RATE_PERCENT record" >&2
    exit 65
fi
if ! packages=$(value_once PACKAGES_STATUS); then
    echo "incident specimen requires exactly one two-field PACKAGES_STATUS record" >&2
    exit 65
fi

for required_value in "$source_kind" "$source_date" "$packages"; do
    if [ -z "$required_value" ]; then
        echo "incident specimen contains empty required metadata" >&2
        exit 65
    fi
done

case "$web" in
    ''|*[!0-9]*)
        echo "incident specimen contains invalid error-rate fields" >&2
        exit 65
        ;;
esac
case "$raw" in
    ''|*[!0-9]*)
        echo "incident specimen contains invalid error-rate fields" >&2
        exit 65
        ;;
esac

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

if "$BIN_DIR/heresy-reliability-gate" "$web" "$raw" > "$tmp_dir/gate.out" 2>&1; then
    :
else
    status=$?
    cat "$tmp_dir/gate.out" >&2
    exit "$status"
fi

if "$BIN_DIR/heresy-reliability-runtime" "$web" "$raw" > "$tmp_dir/runtime.out" 2>&1; then
    :
else
    status=$?
    cat "$tmp_dir/runtime.out" >&2
    exit "$status"
fi

field() {
    key=$1
    file=$2
    awk -F= -v wanted="$key" '$1 == wanted { sub(/^[^=]*=/, ""); gsub(/^ +| +$/, ""); print; exit }' "$file"
}

observed=$(field OBSERVED_CLASS "$tmp_dir/runtime.out")
diagnostic=$(field RAW_DIAGNOSTIC "$tmp_dir/runtime.out")

printf '%s\n' "HERESY/360 v7.1.0 — ENTERPRISE RELIABILITY INCIDENT REPLAY"
printf 'SOURCE_KIND: %s\n' "$source_kind"
printf 'SOURCE_DATE: %s\n' "$source_date"
printf 'SOURCE_MODE: %s\n' "$source_mode"
printf '%s\n' "BOUNDARY: snapshot evidence; no root cause inferred"
printf '\n'
printf '%s\n' "TIMELINE:"
awk -F '\t' '
  $1 ~ /^[0-9][0-9]:[0-9][0-9]$/ {
    printf "[%s] %-22s %s\n", $1, $2, $3
  }
' "$SPECIMEN"
printf '\n'

export H360_STATUS_WEB="$web"
export H360_STATUS_RAW="$raw"
export H360_STATUS_CLASS="$observed"
export H360_STATUS_DIAGNOSTIC="$diagnostic"
export H360_STATUS_PACKAGES="$packages"

"$BIN_DIR/heresy-status-terminal"
printf '\n'
printf '%s\n' "HERESY-E-GITHUB:"
printf '%s\n' "AS STUPID AS IT APPEARS,"
printf '%s\n' "IT IS ACTUALLY VERY GOOD AT STATUS PAGES."
