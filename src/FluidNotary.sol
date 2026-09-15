// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FluidNotary {
    address public owner;

    mapping(address => bool) public authorizedNotarizers;

    event DeltaNotarized(
        bytes32 indexed deltaHash
    );

    event Granted(address indexed account);
    event Revoked(address indexed account);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAuthorized() {
        require(
            authorizedNotarizers[msg.sender],
            "Not authorized"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
        authorizedNotarizers[msg.sender] = true;
    }

    function grant(address account) external onlyOwner {
        authorizedNotarizers[account] = true;
        emit Granted(account);
    }

    function revoke(address account) external onlyOwner {
        authorizedNotarizers[account] = false;
        emit Revoked(account);
    }

    function notarize(bytes32 deltaHash)
        external
        onlyAuthorized
    {
        emit DeltaNotarized(deltaHash);
    }
}
