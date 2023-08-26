pragma solidity 0.8.18;

import "./Bytes.sol";
import "../types/types.sol";

struct SwapMessage {
    uint32 version;
    bytes32 bridgeNonceHash;
    SwapArgs swapArgs;
}

library SwapMessageCodec {
    using Bytes for *;

    uint8 public constant VERSION_END_INDEX = 4;
    uint8 public constant BRIDGENONCEHASH_END_INDEX = 36;
    uint8 public constant TOKENOUT_END_INDEX = 68;
    uint8 public constant MINOUTPUT_END_INDEX = 100;
    uint8 public constant RECIPIENT_END_INDEX = 132;
    uint8 public constant DEADLINE_END_INDEX = 164;
    uint8 public constant REFUNDADDRESS_END_INDEX = 196;

    function encode(
        SwapMessage memory swapMessage
    ) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                swapMessage.version,
                swapMessage.bridgeNonceHash,
                swapMessage.swapArgs.tokenOut.addressToBytes32(),
                swapMessage.swapArgs.minOutput,
                swapMessage.swapArgs.recipient.addressToBytes32(),
                swapMessage.swapArgs.deadline,
                swapMessage.swapArgs.refundAddress.addressToBytes32()
            );
    }

    function decode(
        bytes memory message
    ) public pure returns (SwapMessage memory) {
        uint32 version;
        bytes32 bridgeNonceHash;
        bytes32 tokenOut;
        uint256 minOutput;
        bytes32 recipient;
        uint256 deadline;
        bytes32 refundAddress;
        assembly {
            version := mload(add(message, VERSION_END_INDEX))
            bridgeNonceHash := mload(add(message, BRIDGENONCEHASH_END_INDEX))
            tokenOut := mload(add(message, TOKENOUT_END_INDEX))
            minOutput := mload(add(message, MINOUTPUT_END_INDEX))
            recipient := mload(add(message, RECIPIENT_END_INDEX))
            deadline := mload(add(message, DEADLINE_END_INDEX))
            refundAddress := mload(add(message, REFUNDADDRESS_END_INDEX))
        }
        return
            SwapMessage(
                version,
                bridgeNonceHash,
                SwapArgs(
                    tokenOut.bytes32ToAddress(),
                    minOutput,
                    recipient.bytes32ToAddress(),
                    deadline,
                    refundAddress.bytes32ToAddress()
                )
            );
    }
}
