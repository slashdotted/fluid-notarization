#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 4 ]; then
  echo "Usage: $0 <contract-address> <owner-private-key> <document-id> <authorized-address>"
  exit 1
fi

RPC=http://localhost:8545

CONTRACT=$1
OWNER_PK=$2
DOCUMENT_ID=$3
AUTHORIZED=$4

cast send "$CONTRACT" \
  "grant(bytes32,address)" \
  "$DOCUMENT_ID" \
  "$AUTHORIZED" \
  --rpc-url "$RPC" \
  --private-key "$OWNER_PK"
