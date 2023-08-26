pragma solidity 0.8.18;

import "forge-std/Test.sol";

import "../contracts/lib/Bytes.sol";

contract TestBytes is Test {
    using Bytes for *;

    function test_addressToBytes32() public {
        address a = 0x05a56E2D52c817161883f50c441c3228CFe54d9f;
        bytes32 b = 0x00000000000000000000000005a56e2d52c817161883f50c441c3228cfe54d9f;
        assertTrue(b == a.addressToBytes32());
    }

    function test_bytes32ToAddress() public {
        address a = 0x05a56E2D52c817161883f50c441c3228CFe54d9f;
        bytes32 b = 0x00000000000000000000000005a56e2d52c817161883f50c441c3228cfe54d9f;
        assertTrue(a == b.bytes32ToAddress());
    }

    function test_slice() public {
        bytes
            memory b = hex"00000000000000000000000005a56e2d52c817161883f50c441c3228cfe54d9f";
        bytes memory b1 = hex"0000000000";
        assertTrue(keccak256(b.slice(0, 5)) == keccak256(b1));
        bytes memory b2 = hex"05a56e2d52c817161883f50c441c3228cfe54d9f";
        assertTrue(keccak256(b.slice(12, 20)) == keccak256(b2));
        bytes memory b3 = hex"";
        assertTrue(keccak256(b.slice(12, 0)) == keccak256(b3));
    }

    function test_sliceOutOfBounds() public {
        bytes
            memory b = hex"00000000000000000000000005a56e2d52c817161883f50c441c3228cfe54d9f";
        vm.expectRevert(bytes("slice_outOfBounds"));
        bytes memory b3 = b.slice(12, 21);
    }
}
