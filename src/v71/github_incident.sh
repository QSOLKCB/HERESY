#!/bin/sh
set -eu

BIN_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$BIN_DIR/../.." && pwd)
SPECIMEN=${H360_INCIDENT_SPECIMEN:-"$PROJECT_ROOT/specimens/enterprise-reliability/github-2026-08-17/incident.tsv"}

value() {
    key=$1
    awk -F '\t' -v wanted="$key" '$1 == wanted { print $2; exit }' "$SPECIMEN"
}

if [ ! -f "$SPECIMEN" ]; then
    echo "incident specimen missing: $SPECIMEN" >&2
    exit 66
fi

web=$(value WEB_API_ERROR_RATE_PERCENT)
raw=$(value RAW_DOWNLOAD_ERROR_RATE_PERCENT)
packages=$(value PACKAGES_STATUS)

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

"$BIN_DIR/heresy-reliability-gate" "$web" "$raw" > "$tmp_dir/gate.out"
"$BIN_DIR/heresy-reliability-runtime" "$web" "$raw" > "$tmp_dir/runtime.out"

field() {
    key=$1
    file=$2
    awk -F= -v wanted="$key" '$1 == wanted { sub(/^[^=]*=/, ""); gsub(/^ +| +$/, ""); print; exit }' "$file"
}

observed=$(field OBSERVED_CLASS "$tmp_dir/runtime.out")
diagnostic=$(field RAW_DIAGNOSTIC "$tmp_dir/runtime.out")

printf '%s\n' "HERESY/360 v7.1.0 — ENTERPRISE RELIABILITY INCIDENT REPLAY"
printf '%s\n' "SOURCE: maintainer-supplied GitHub status snapshot, 2026-08-17"
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
