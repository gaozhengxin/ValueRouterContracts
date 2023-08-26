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
}
