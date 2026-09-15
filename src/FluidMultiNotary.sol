// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FluidMultiNotary {
    address public owner;

    // documentId => account => authorized
    mapping(bytes32 => mapping(address => bool))
        public authorizedNotarizers;

    event DeltaNotarized(
        bytes32 indexed documentId,
        bytes32 indexed deltaHash
    );

    event Granted(
        bytes32 indexed documentId,
        address indexed account
    );

    event Revoked(
        bytes32 indexed documentId,
        address indexed account
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function grant(
        bytes32 documentId,
        address account
    ) external onlyOwner {
        authorizedNotarizers[documentId][account] = true;

        emit Granted(
            documentId,
            account
        );
    }

    function revoke(
        bytes32 documentId,
        address account
    ) external onlyOwner {
        authorizedNotarizers[documentId][account] = false;

        emit Revoked(
            documentId,
            account
        );
    }

    function notarize(
        bytes32 documentId,
        bytes32 deltaHash
    ) external {
        require(
            authorizedNotarizers[documentId][msg.sender],
            "Not authorized"
        );

        emit DeltaNotarized(
            documentId,
            deltaHash
        );
    }

    function isAuthorized(
        bytes32 documentId,
        address account
    ) external view returns (bool) {
        return authorizedNotarizers[documentId][account];
    }
}
