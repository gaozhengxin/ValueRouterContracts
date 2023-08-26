pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../contracts/lib/SwapMessage.sol";

contract TestCCTPMessage is Test {
    using SwapMessageCodec for *;
    using console for *;

    function test_encode() public {
        SwapArgs memory swapArgs = SwapArgs({
            tokenOut: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            minOutput: 11000000,
            recipient: 0x05a56E2D52c817161883f50c441c3228CFe54d9f,
            deadline: 1694000000,
            refundAddress: 0x05a56E2D52c817161883f50c441c3228CFe54d9f
        });
        SwapMessage memory swapMessage = SwapMessage({
            version: 1,
            bridgeNonceHash: keccak256(abi.encode(1, 2)),
            swapArgs: swapArgs
        });

        bytes memory encoded = swapMessage.encode();
        encoded.logBytes();

        bytes
            memory expected = hex"00000001e90b7bceb6e7df5418fb78d8ee546e97c83a08bbccc01a0644d599ccd2a7c2e0000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb480000000000000000000000000000000000000000000000000000000000a7d8c000000000000000000000000005a56e2d52c817161883f50c441c3228cfe54d9f0000000000000000000000000000000000000000000000000000000064f8638000000000000000000000000005a56e2d52c817161883f50c441c3228cfe54d9f";
        assertTrue(keccak256(encoded) == keccak256(expected));
    }

    function test_decode() public {
        bytes
            memory message = hex"00000001e90b7bceb6e7df5418fb78d8ee546e97c83a08bbccc01a0644d599ccd2a7c2e0000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb480000000000000000000000000000000000000000000000000000000000a7d8c000000000000000000000000005a56e2d52c817161883f50c441c3228cfe54d9f0000000000000000000000000000000000000000000000000000000064f8638000000000000000000000000005a56e2d52c817161883f50c441c3228cfe54d9f";

        SwapMessage memory decoded = message.decode();

        assertTrue(decoded.version == 1);
        assertTrue(decoded.bridgeNonceHash == keccak256(abi.encode(1, 2)));
        assertTrue(
            decoded.swapArgs.tokenOut ==
                0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        );
        assertTrue(decoded.swapArgs.minOutput == 11000000);
        assertTrue(
            decoded.swapArgs.recipient ==
                0x05a56E2D52c817161883f50c441c3228CFe54d9f
        );
        assertTrue(decoded.swapArgs.deadline == 1694000000);
        assertTrue(
            decoded.swapArgs.refundAddress ==
                0x05a56E2D52c817161883f50c441c3228CFe54d9f
        );
    }
}
