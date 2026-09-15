#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 4 ]; then
    echo "Usage: $0 <medical-record-id> <doctor-name> <description> <json-file>"
    exit 1
fi

MEDICAL_RECORD_ID="$1"
DOCTOR_NAME="$2"
DESCRIPTION="$3"
JSON_FILE="$4"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$MEDICAL_RECORD_ID"

OUTPUT=$(
"$SCRIPT_DIR/libmelda-tools" update \
    -a "$DOCTOR_NAME" \
    -d "$DESCRIPTION" \
    -j "$JSON_FILE" \
    -t "file://$(pwd)/$MEDICAL_RECORD_ID"
)

DELTA_ID=$(
echo "$OUTPUT" \
| grep -oE '[0-9]+-[0-9a-f]{64}' \
| head -n1
)

if [ -z "$DELTA_ID" ]; then
    echo "Unable to extract delta id" >&2
    echo "$OUTPUT" >&2
    exit 1
fi

echo "$DELTA_ID" | cut -d'-' -f2
