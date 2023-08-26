pragma solidity ^0.8.0;

struct Call {
    address to;
    bytes data;
    uint256 value;
    uint256 gas;
}

struct SwapArgs {
    address tokenOut;
    uint256 minOutput;
    address recipient;
    uint256 deadline;
    address refundAddress;
}

struct MessageWithAttestation {
    bytes message;
    bytes attestation;
}
