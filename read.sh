#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <medical-record-id> <deltaHash1> [deltaHash2 ...]"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

MEDICAL_RECORD_ID="$1"
shift

TEMP_DIR=$(mktemp -d)

cp -r "$MEDICAL_RECORD_ID" "$TEMP_DIR/view"

declare -A NOTARIZED

for HASH in "$@"
do
    HASH=${HASH#0x}
    NOTARIZED["$HASH"]=1
done

find "$TEMP_DIR/view" -type f -name "*.delta" | while read -r FILE
do
    BASENAME=$(basename "$FILE" .delta)
    HASH=${BASENAME#*-}

    if [ -z "${NOTARIZED[$HASH]:-}" ]
    then
        rm -f "$FILE"
    fi
done

"$SCRIPT_DIR/libmelda-tools" read \
    -s "file://$(realpath "$TEMP_DIR/view")" \
| jq

rm -rf "$TEMP_DIR"
