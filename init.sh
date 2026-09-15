#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <owner-private-key>"
  exit 1
fi

RPC=http://localhost:8545
OWNER_PK=$1

OUTPUT=$(forge create \
  src/FluidMultiNotary.sol:FluidMultiNotary \
  --rpc-url "$RPC" \
  --private-key "$OWNER_PK" \
  --broadcast)

echo "$OUTPUT" >&2

ADDRESS=$(echo "$OUTPUT" | grep "Deployed to:" | awk '{print $3}')

echo "$ADDRESS"
