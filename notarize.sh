#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 4 ]; then
  echo "Usage: $0 <contract-address> <document-id> <notarizer-private-key> <deltahash>"
  exit 1
fi

RPC=http://localhost:8545

CONTRACT=$1
DOCUMENT_ID=$2
NOTARIZER_PK=$3
DELTA_HASH=$4

cast send "$CONTRACT" \
  "notarize(bytes32,bytes32)" \
  "$DOCUMENT_ID" \
  "$DELTA_HASH" \
  --rpc-url "$RPC" \
  --private-key "$NOTARIZER_PK"
