pragma solidity 0.8.18;

import "forge-std/Test.sol";

import "../contracts/lib/CCTPMessage.sol";

contract TestCCTPMessage is Test {
    using CCTPMessage for bytes;

    function test_getCCTPMessageBody() public {
        bytes
            memory message = hex"0000000000000003000000000000000000000071000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000233333";
        bytes memory messageBody = message.body();
        assertTrue(keccak256(messageBody) == keccak256(hex"233333"));
    }
}
