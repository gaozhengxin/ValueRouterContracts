pragma solidity 0.8.18;

import "./Bytes.sol";

struct SwapMessage {
    uint32 version;
    bytes32 bridgeNonceHash;
    uint256 sellAmount;
    bytes32 buyToken;
    uint256 guaranteedBuyAmount;
    bytes32 recipient;
    uint256 callgas;
    bytes swapdata;
}

library SwapMessageCodec {
    using Bytes for *;

    uint8 public constant VERSION_END_INDEX = 4;
    uint8 public constant BRIDGENONCEHASH_END_INDEX = 36;
    uint8 public constant SELLAMOUNT_END_INDEX = 68;
    uint8 public constant BUYTOKEN_END_INDEX = 100;
    uint8 public constant BUYAMOUNT_END_INDEX = 132;
    uint8 public constant RECIPIENT_END_INDEX = 164;
    uint8 public constant GAS_END_INDEX = 196;
    uint8 public constant SWAPDATA_INDEX = 196;

    function encode(
        SwapMessage memory swapMessage
    ) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                swapMessage.version,
                swapMessage.bridgeNonceHash,
                swapMessage.sellAmount,
                swapMessage.buyToken,
                swapMessage.guaranteedBuyAmount,
                swapMessage.recipient,
                swapMessage.callgas,
                swapMessage.swapdata
            );
    }

    function decode(
        bytes memory message
    ) public pure returns (SwapMessage memory) {
        uint32 version;
        bytes32 bridgeNonceHash;
        uint256 sellAmount;
        bytes32 buyToken;
        uint256 guaranteedBuyAmount;
        bytes32 recipient;
        uint256 callgas;
        bytes memory swapdata;
        assembly {
            version := mload(add(message, VERSION_END_INDEX))
            bridgeNonceHash := mload(add(message, BRIDGENONCEHASH_END_INDEX))
            sellAmount := mload(add(message, SELLAMOUNT_END_INDEX))
            buyToken := mload(add(message, BUYTOKEN_END_INDEX))
            guaranteedBuyAmount := mload(add(message, BUYAMOUNT_END_INDEX))
            recipient := mload(add(message, RECIPIENT_END_INDEX))
            callgas := mload(add(message, GAS_END_INDEX))
        }
        swapdata = message.slice(
            SWAPDATA_INDEX,
            message.length - SWAPDATA_INDEX
        );
        return
            SwapMessage(
                version,
                bridgeNonceHash,
                sellAmount,
                buyToken,
                guaranteedBuyAmount,
                recipient,
                callgas,
                swapdata
            );
    }

    /*
    function testEncode() public pure returns (bytes memory) {
        return
            encode(
                SwapMessage(
                    3,
                    0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
                    1000,
                    0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB
                        .addressToBytes32(),
                    2000,
                    0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC
                        .addressToBytes32(),
                    0x33aaaa,
                    hex"dddddddd"
                )
            );
        //hex
        //00000003
        //aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
        //00000000000000000000000000000000000000000000000000000000000003e8
        //000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
        //00000000000000000000000000000000000000000000000000000000000007d0
        //000000000000000000000000cccccccccccccccccccccccccccccccccccccccc
        //000000000000000000000000000000000000000000000000000000000033aaaa
        //dddddddd
    }

    function testDecode() public pure returns (SwapMessage memory) {
        return
            decode(
                hex"00000003aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000003e8000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000007d0000000000000000000000000cccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000033aaaadddddddd"
            );
    }

    function testMessageCodec() public pure returns (bool) {
        bytes
            memory message = hex"00000003aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000003e8000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000000007d0000000000000000000000000cccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000033aaaadddddddd";
        SwapMessage memory args = decode(message);
        bytes memory encoded = encode(args);
        require(keccak256(message) == keccak256(encoded));
        return true;
    }
*/
}
