#!/usr/bin/env bash
set -euo pipefail
rm -rf cache/ out/

########################################################################
# CONFIGURATION
########################################################################

MEDICAL_RECORD_ID="mario-rossi"

OWNER_PK=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

DOCTOR1="0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
DOCTOR2="0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"

DOCTOR1_PK=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
DOCTOR2_PK=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

########################################################################
# DEPLOY NOTARY
########################################################################

echo
echo "=== DEPLOY SMART CONTRACT ==="

CONTRACT=$(./init.sh "$OWNER_PK")

echo "Contract: $CONTRACT"

########################################################################
# AUTHORIZE DOCTORS
########################################################################

DOCID=$(printf "%064x" 1)
DOCID="0x$DOCID"

./grant.sh "$CONTRACT" "$OWNER_PK" "$DOCID" "$DOCTOR1"
./grant.sh "$CONTRACT" "$OWNER_PK" "$DOCID" "$DOCTOR2"

########################################################################
# V0
########################################################################

echo
echo "=== DOCTOR 1 CREATES INITIAL RECORD ==="

DELTA_V0=$(
./update.sh \
    "$MEDICAL_RECORD_ID" \
    "Doctor A" \
    "Create medical record" \
    example/record_v0.json
)

echo "DELTA_V0=$DELTA_V0"

./notarize.sh \
    "$CONTRACT" \
    "$DOCID" \
    "$DOCTOR1_PK" \
    "$DELTA_V0"

NOTARIZED=("$DELTA_V0")

########################################################################
# V1
########################################################################

echo
echo "=== DOCTOR 2 UPDATE ==="

DELTA_V1=$(
./update.sh \
    "$MEDICAL_RECORD_ID" \
    "Doctor B" \
    "Routine patient update" \
    example/record_v1.json
)

echo "DELTA_V1=$DELTA_V1"

./notarize.sh \
    "$CONTRACT" \
    "$DOCID" \
    "$DOCTOR2_PK" \
    "$DELTA_V1"

NOTARIZED+=("$DELTA_V1")

########################################################################
# CREATE CONCURRENT COPIES
########################################################################

echo
echo "=== CREATE CONCURRENT BRANCHES ==="

cp -r "$MEDICAL_RECORD_ID" doctorA_branch
cp -r "$MEDICAL_RECORD_ID" doctorB_branch

########################################################################
# BRANCH A
########################################################################

echo
echo "=== BRANCH A ==="

pushd doctorA_branch >/dev/null

DELTA_V2A=$(
../update.sh \
    "$MEDICAL_RECORD_ID" \
    "Doctor A" \
    "Allergy update" \
    ../example/record_v2a.json
)

../notarize.sh \
    "$CONTRACT" \
    "$DOCID" \
    "$DOCTOR1_PK" \
    "$DELTA_V2A"

NOTARIZED+=("$DELTA_V2A")

DELTA_V3A=$(
../update.sh \
    "$MEDICAL_RECORD_ID" \
    "Doctor A" \
    "Medication update" \
    ../example/record_v3a.json
)

../notarize.sh \
    "$CONTRACT" \
    "$DOCID" \
    "$DOCTOR1_PK" \
    "$DELTA_V3A"

NOTARIZED+=("$DELTA_V3A")

########################################################################
# NOT NOTARIZED
########################################################################

DELTA_V4A=$(
../update.sh \
    "$MEDICAL_RECORD_ID" \
    "Doctor A" \
    "Temporary draft update" \
    ../example/record_v4a.json
)

echo "DELTA_V4A=$DELTA_V4A (NOT NOTARIZED)"

popd >/dev/null

########################################################################
# BRANCH B
########################################################################

echo
echo "=== BRANCH B ==="

pushd doctorB_branch >/dev/null

DELTA_V2B=$(
../update.sh \
    "$MEDICAL_RECORD_ID" \
    "Doctor B" \
    "Radiology update" \
    ../example/record_v2b.json
)

../notarize.sh \
    "$CONTRACT" \
    "$DOCID" \
    "$DOCTOR2_PK" \
    "$DELTA_V2B"

NOTARIZED+=("$DELTA_V2B")

DELTA_V3B=$(
../update.sh \
    "$MEDICAL_RECORD_ID" \
    "Doctor B" \
    "Diagnostic update" \
    ../example/record_v3b.json
)

../notarize.sh \
    "$CONTRACT" \
    "$DOCID" \
    "$DOCTOR2_PK" \
    "$DELTA_V3B"

NOTARIZED+=("$DELTA_V3B")

popd >/dev/null

########################################################################
# MERGE BACK INTO ORIGINAL STORAGE
########################################################################

echo
echo "=== MERGE STORAGE LAYERS ==="

cp -rf doctorA_branch/"$MEDICAL_RECORD_ID"/* \
       "$MEDICAL_RECORD_ID"/

cp -rf doctorB_branch/"$MEDICAL_RECORD_ID"/* \
       "$MEDICAL_RECORD_ID"/

########################################################################
# SHOW NOTARIZED DELTAS
########################################################################

echo
echo "=== NOTARIZED DELTAS ==="

printf '%s\n' "${NOTARIZED[@]}"

########################################################################
# RECONSTRUCTION USING ONLY NOTARIZED DELTAS
########################################################################

echo
echo "=== RECONSTRUCT DOCUMENT ==="

./read.sh \
    "$MEDICAL_RECORD_ID" \
    "${NOTARIZED[@]}" \
    > reconstructed.json

cat reconstructed.json

########################################################################
# VERIFY V4A IS NOT PART OF RECONSTRUCTION
########################################################################

echo
echo "=== IMPORTANT PROPERTY ==="
echo "DELTA_V4A WAS GENERATED BUT NEVER NOTARIZED"
echo "THEREFORE IT MUST NOT APPEAR IN THE RECONSTRUCTED STATE"
echo

echo "Non-notarized delta:"
echo "$DELTA_V4A"

echo
echo "Reconstruction performed using only:"
printf '%s\n' "${NOTARIZED[@]}"
