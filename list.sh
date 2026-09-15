#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <contract-address> <document-id>"
  exit 1
fi

RPC=http://localhost:8545

CONTRACT=$1
DOCUMENT_ID=$(echo "$2" | tr '[:upper:]' '[:lower:]')

TOPIC0=$(cast keccak "DeltaNotarized(bytes32,bytes32)")

cast logs \
  --rpc-url "$RPC" \
  --address "$CONTRACT" \
  "$TOPIC0" \
  --json |
jq -c '.[]' |
while read -r LOG; do

  DOC=$(echo "$LOG" | jq -r '.topics[1]' | tr '[:upper:]' '[:lower:]')

  if [ "$DOC" != "$DOCUMENT_ID" ]; then
    continue
  fi

  DELTA=$(echo "$LOG" | jq -r '.topics[2]')
  TX=$(echo "$LOG" | jq -r '.transactionHash')

  NOTARIZER=$(cast tx "$TX" \
    --rpc-url "$RPC" \
    --json | jq -r '.data.from')

  echo "${DELTA},${NOTARIZER}"

done
