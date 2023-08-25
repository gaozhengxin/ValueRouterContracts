import "../types/types.sol";

interface IValueRouter {
    event SwapAndBridge(
        bytes32 router_tx_id,
        bytes32 bridgeMessageHash,
        bytes32 swapMessageHash,
        uint8 destDomain,
        uint256 usdcBridgeAmount,
        SwapArgs swapArgs
    );
    event Relay(bytes32 router_tx_id);
    event Cancel(bytes32 router_tx_id);

    function swap(
        Call calldata localSwapCall,
        uint8 destDomain,
        SwapArgs calldata destSwapArgs
    )
        external
        returns (
            bytes32 router_tx_id,
            bytes32 cctpBridgeNonce,
            bytes32 cctpSwapNonce
        );

    function relay(
        MessageWithAttestation calldata bridgeMsg,
        MessageWithAttestation calldata swapMsg,
        Call calldata destSwapCall
    ) external;

    function cancel(
        MessageWithAttestation calldata bridgeMsg,
        MessageWithAttestation calldata swapMsg
    ) external;
}
