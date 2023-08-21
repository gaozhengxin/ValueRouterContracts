pragma solidity 0.8.18;

import "./Bytes.sol";

library CCTPMessage {
    using Bytes for *;
    uint8 public constant MESSAGE_BODY_INDEX = 116;

    function body(bytes memory message) public pure returns (bytes memory) {
        return
            message.slice(
                MESSAGE_BODY_INDEX,
                message.length - MESSAGE_BODY_INDEX
            );
    }

    /*function testGetCCTPMessageBody() public pure {
        bytes
            memory message = hex"0000000000000003000000000000000000000071000000000000000000000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000233333";
        bytes memory messageBody = body(message);
        require(keccak256(messageBody) == keccak256(hex"233333"));
    }*/
}
