# Fluid Notarization Prototype

This repository contains a set of helper scripts used to demonstrate the **Fluid Notarization** proof of concept described in the accompanying paper.

The prototype combines:

- **Melda** as the document evolution and synchronization layer.
- **Ethereum** as the notarization layer.
- A minimal **FluidMultiNotary** smart contract deployed on a local blockchain.

The goal is to notarize the evolution of structured documents by recording **delta identifiers** on-chain while keeping the actual document data off-chain.

---

# Prerequisites

## 1. Install libmelda-tools

Install and build `libmelda-tools`:

https://github.com/slashdotted/libmelda-tools/

The executable `libmelda-tools` must be available in the same directory as the scripts contained in this repository.

Example:

```text
.
├── init.sh
├── grant.sh
├── revoke.sh
├── notarize.sh
├── read.sh
├── update.sh
├── medical-record-example.sh
├── libmelda-tools
└── example/
```

The executable may be the actual binary or a symbolic link.

Example:

```bash
ln -s /path/to/libmelda-tools/target/debug/libmelda-tools ./libmelda-tools
```

---

## 2. Install Anvil

Install Anvil from Foundry:

https://www.getfoundry.sh/anvil/

Start a local blockchain before running any script:

```bash
anvil
```

The scripts assume that Anvil is already running and reachable at:

```text
http://localhost:8545
```

---

# Smart Contract Deployment

Deploy the `FluidMultiNotary` contract using:

```bash
./init.sh <owner-private-key>
```

Example:

```bash
./init.sh \
  0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

The script returns the deployed contract address.

---

# Scripts

## init.sh

Deploys the `FluidMultiNotary` smart contract.

```bash
./init.sh <owner-private-key>
```

Returns:

```text
0x...
```

---

## grant.sh

Authorizes an identity to notarize updates for a document.

```bash
./grant.sh \
  <contract-address> \
  <owner-private-key> \
  <document-id> \
  <authorized-address>
```

Example:

```bash
./grant.sh \
  0x1234... \
  <owner-pk> \
  0x01 \
  0x70997970C51812dc3A010C7d01b50e0d17dc79C8
```

---

## revoke.sh

Revokes a previously granted authorization.

```bash
./revoke.sh \
  <contract-address> \
  <owner-private-key> \
  <document-id> \
  <authorized-address>
```

---

## update.sh

Applies a modification to a document using Melda.

```bash
./update.sh \
  <medical-record-id> \
  <doctor-name> \
  <description> \
  <json-file>
```

Example:

```bash
./update.sh \
  mario-rossi \
  "Dr. House" \
  "Update blood pressure" \
  example/record_v2a.json
```

Returns:

```text
<delta-hash>
```

The generated delta is stored in the repository associated with the specified medical record.

---

## notarize.sh

Registers a delta hash on the blockchain.

```bash
./notarize.sh \
  <contract-address> \
  <document-id> \
  <notarizer-private-key> \
  <delta-hash>
```

Example:

```bash
./notarize.sh \
  0x1234... \
  0x01 \
  <doctor-pk> \
  <delta-hash>
```

---

## read.sh

Reconstructs the state of a document using only the supplied notarized deltas.

```bash
./read.sh \
  <medical-record-id> \
  <deltaHash1> \
  <deltaHash2> \
  ... \
  <deltaHashN>
```

The script:

1. Creates a temporary copy of the repository.
2. Removes all delta files whose hash is not present in the supplied list.
3. Reconstructs the document using Melda.
4. Outputs the resulting JSON document.

This demonstrates how the blockchain determines the authoritative document history without storing document contents on-chain.

---

## list.sh

Retrieves the notarized delta history for a document from the blockchain.

```bash
./list.sh \
  <contract-address> \
  <document-id>
```

The output consists of:

```text
deltaHash,notarizerIdentity
```

For each notarized contribution, the script:

1. Retrieves the corresponding blockchain event.
2. Extracts the transaction hash.
3. Retrieves the transaction metadata.
4. Determines the blockchain identity of the notarizer.

---

# Example Scenario

The script:

```bash
./medical-record-example.sh
```

demonstrates a complete Fluid Notarization workflow based on a collaboratively edited electronic health record.

The scenario includes:

1. Creation of an initial patient record.
2. Updates from multiple physicians.
3. Concurrent modifications performed on independent repository copies.
4. Notarization of selected updates.
5. Merge of the repository branches.
6. Reconstruction of the document using only notarized deltas.

The example also demonstrates that updates physically present in the storage layer but **not notarized** do not affect the reconstructed document state.

---

# Example Data

The `example/` directory contains the JSON files used by the scenario:

```text
example/
├── record_v0.json
├── record_v1.json
├── record_v2a.json
├── record_v2b.json
├── record_v3a.json
├── record_v3b.json
└── record_v4a.json
```

These files model the evolution of a hypothetical electronic health record edited by multiple healthcare professionals.

---

# Architecture Overview

```text
                        +----------------------+
                        |      Blockchain      |
                        |   FluidMultiNotary   |
                        +----------+-----------+
                                   |
                          Delta Hashes
                                   |
                                   v
                        +----------------------+
                        |  Fluid Notarization  |
                        |       Scripts        |
                        +----------+-----------+
                                   |
                                   v
                        +----------------------+
                        |        Melda         |
                        |      Delta CRDT      |
                        +----------+-----------+
                                   |
                                   v
                        +----------------------+
                        |    Storage Layer      |
                        |  Delta Blocks & Data  |
                        +----------------------+
```

The blockchain stores only notarized delta identifiers and authorization policies. Document contents, synchronization, reconstruction, and conflict resolution remain entirely delegated to Melda.

---

# License

This code is released under the MIT License. See the LICENSE file for details.
This repository is provided as a proof-of-concept implementation accompanying the Fluid Notarization paper.

## Citation

If you use this software in academic work, please cite:

Amos Brocco, Giuliano Gremlich, Roberto Guidi. "Fluid Notarization: Verifiable Evolution of Concurrently Edited Structured Documents", arxiv
