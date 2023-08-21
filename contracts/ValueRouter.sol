// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./interfaces/IERC20.sol";
import "./interfaces/IMessageTransmitter.sol";
import "./interfaces/ITokenMessenger.sol";

import "./lib/Bytes.sol";
import "./lib/CCTPMessage.sol";
import "./lib/SwapMessage.sol";

import "./utils/AdminControl.sol";

contract ValueRouter is AdminControl {
    using Bytes for *;
    using CCTPMessage for *;
    using SwapMessageCodec for *;

    struct MessageWithAttestation {
        bytes message;
        bytes attestation;
    }

    struct SellArgs {
        address sellToken;
        uint256 sellAmount;
        uint256 guaranteedBuyAmount;
        uint256 sellcallgas;
        bytes sellcalldata;
    }

    struct BuyArgs {
        bytes32 buyToken;
        uint256 guaranteedBuyAmount;
        uint256 buycallgas;
        bytes buycalldata;
    }

    address public immutable usdc;
    IMessageTransmitter public immutable messageTransmitter;
    ITokenMessenger public immutable tokenMessenger;
    address public immutable zeroEx;
    uint16 public immutable version = 1;

    uint256 public feeRate = 1;
    uint256 public constant feeDenominator = 1000;

    mapping(uint32 => bytes32) public remoteRouter;
    mapping(bytes32 => address) swapHashSender;

    event TakeFee(address to, uint256 amount);

    event SwapAndBridge(
        address sellToken,
        address buyToken,
        uint256 bridgeUSDCAmount,
        uint32 destDomain,
        address recipient,
        uint64 bridgeNonce,
        uint64 swapMessageNonce,
        bytes32 bridgeHash
    );

    event ReplaceSwapMessage(
        address buyToken,
        uint32 destDomain,
        address recipient,
        uint64 swapMessageNonce
    );

    event LocalSwap(
        address msgsender,
        address sellToken,
        uint256 sellAmount,
        address buyToken,
        uint256 boughtAmount
    );

    event BridgeArrive(bytes32 bridgeNonceHash, uint256 amount);

    event DestSwapFailed(bytes32 bridgeNonceHash);

    event DestSwapSuccess(bytes32 bridgeNonceHash);

    event UpdateFeeRate(uint256 feeRate);

    constructor(
        address _usdc,
        address _messageTransmtter,
        address _tokenMessenger,
        address _zeroEx,
        address admin
    ) AdminControl(admin) {
        usdc = _usdc;
        messageTransmitter = IMessageTransmitter(_messageTransmtter);
        tokenMessenger = ITokenMessenger(_tokenMessenger);
        zeroEx = _zeroEx;
    }

    receive() external payable {}

    function updateFeeRate(uint256 _feeRate) public onlyAdmin {
        feeRate = _feeRate;
        emit UpdateFeeRate(feeRate);
    }

    function setRemoteRouter(
        uint32 remoteDomain,
        address router
    ) public onlyAdmin {
        remoteRouter[remoteDomain] = router.addressToBytes32();
    }

    function getFee(uint256 usdcBridgeAmount) public view returns (uint256) {
        return (usdcBridgeAmount * feeRate) / feeDenominator;
    }

    function takeFee(address to, uint256 amount) public onlyAdmin {
        bool succ = IERC20(usdc).transfer(to, amount);
        require(succ);
        emit TakeFee(to, amount);
    }

    /// @param recipient set recipient to address(0) to save token in the router contract.
    function zeroExSwap(
        bytes memory swapcalldata,
        uint256 callgas,
        address sellToken,
        uint256 sellAmount,
        address buyToken,
        uint256 guaranteedBuyAmount,
        address recipient
    ) public payable returns (uint256 boughtAmount) {
        // before swap
        // approve
        if (sellToken != 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            require(
                IERC20(sellToken).approve(zeroEx, sellAmount),
                "erc20 approve failed"
            );
        }
        // check balance 0
        uint256 buyToken_bal_0;
        if (buyToken == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            buyToken_bal_0 = address(this).balance;
        } else {
            buyToken_bal_0 = IERC20(buyToken).balanceOf(address(this));
        }

        _zeroExSwap(swapcalldata, callgas);

        // after swap
        // cancel approval
        if (sellToken != 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            // cancel approval
            require(
                IERC20(sellToken).approve(zeroEx, 0),
                "erc20 cancel approval failed"
            );
        }
        // check balance 1
        uint256 buyToken_bal_1;
        if (buyToken == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            buyToken_bal_1 = address(this).balance;
        } else {
            buyToken_bal_1 = IERC20(buyToken).balanceOf(address(this));
        }
        boughtAmount = buyToken_bal_1 - buyToken_bal_0;
        require(boughtAmount >= guaranteedBuyAmount, "swap output not enough");
        // send token to recipient
        if (recipient == address(0)) {
            return boughtAmount;
        }
        if (buyToken == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            (bool succ, ) = recipient.call{value: boughtAmount}("");
            require(succ, "send eth failed");
        } else {
            bool succ = IERC20(buyToken).transfer(recipient, boughtAmount);
            require(succ, "erc20 transfer failed");
        }

        return boughtAmount;
    }

    function _zeroExSwap(bytes memory swapcalldata, uint256 callgas) internal {
        (bool succ, ) = zeroEx.call{value: msg.value, gas: callgas}(
            swapcalldata
        );
        require(succ, "call swap failed");
    }

    function swap(
        bytes calldata swapcalldata,
        uint256 callgas,
        address sellToken,
        uint256 sellAmount,
        address buyToken,
        uint256 guaranteedBuyAmount,
        address recipient
    ) public payable {
        if (sellToken == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            require(msg.value >= sellAmount, "tx value is not enough");
        } else {
            bool succ = IERC20(sellToken).transferFrom(
                msg.sender,
                address(this),
                sellAmount
            );
            require(succ, "erc20 transfer failed");
        }
        uint256 boughtAmount = zeroExSwap(
            swapcalldata,
            callgas,
            sellToken,
            sellAmount,
            buyToken,
            guaranteedBuyAmount,
            recipient
        );
        emit LocalSwap(
            msg.sender,
            sellToken,
            sellAmount,
            buyToken,
            boughtAmount
        );
    }

    /// User entrance
    /// @param sellArgs : sell-token arguments
    /// @param buyArgs : buy-token arguments
    /// @param destDomain : destination domain
    /// @param recipient : token receiver on dest domain
    function swapAndBridge(
        SellArgs calldata sellArgs,
        BuyArgs calldata buyArgs,
        uint32 destDomain,
        bytes32 recipient
    ) public payable returns (uint64, uint64) {
        if (recipient == bytes32(0)) {
            recipient = msg.sender.addressToBytes32();
        }

        // swap sellToken to usdc
        if (sellArgs.sellToken == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            require(msg.value >= sellArgs.sellAmount, "tx value is not enough");
        } else {
            bool succ = IERC20(sellArgs.sellToken).transferFrom(
                msg.sender,
                address(this),
                sellArgs.sellAmount
            );
            require(succ, "erc20 transfer failed");
        }
        uint256 bridgeUSDCAmount;
        if (sellArgs.sellToken == usdc) {
            bridgeUSDCAmount = sellArgs.sellAmount;
        } else {
            bridgeUSDCAmount = zeroExSwap(
                sellArgs.sellcalldata,
                sellArgs.sellcallgas,
                sellArgs.sellToken,
                sellArgs.sellAmount,
                usdc,
                sellArgs.guaranteedBuyAmount,
                address(0)
            );
        }

        // bridge usdc
        require(
            IERC20(usdc).approve(address(tokenMessenger), bridgeUSDCAmount),
            "erc20 approve failed"
        );

        bytes32 destRouter = remoteRouter[destDomain];

        uint64 bridgeNonce = tokenMessenger.depositForBurnWithCaller(
            bridgeUSDCAmount,
            destDomain,
            destRouter,
            usdc,
            destRouter
        );

        bytes32 bridgeNonceHash = keccak256(
            abi.encodePacked(messageTransmitter.localDomain(), bridgeNonce)
        );

        // send swap message
        SwapMessage memory swapMessage = SwapMessage(
            version,
            bridgeNonceHash,
            bridgeUSDCAmount,
            buyArgs.buyToken,
            buyArgs.guaranteedBuyAmount,
            recipient,
            buyArgs.buycallgas,
            buyArgs.buycalldata
        );
        bytes memory messageBody = swapMessage.encode();
        uint64 swapMessageNonce = messageTransmitter.sendMessageWithCaller(
            destDomain,
            destRouter, // remote router will receive this message
            destRouter, // message will only submited through the remote router (handleBridgeAndSwap)
            messageBody
        );
        emit SwapAndBridge(
            sellArgs.sellToken,
            buyArgs.buyToken.bytes32ToAddress(),
            bridgeUSDCAmount,
            destDomain,
            recipient.bytes32ToAddress(),
            bridgeNonce,
            swapMessageNonce,
            bridgeNonceHash
        );
        swapHashSender[
            keccak256(abi.encode(destDomain, swapMessageNonce))
        ] = msg.sender;
        return (bridgeNonce, swapMessageNonce);
    }

    function replaceSwapMessage(
        uint64 bridgeMessageNonce,
        uint64 swapMessageNonce,
        MessageWithAttestation calldata originalMessage,
        uint32 destDomain,
        BuyArgs calldata buyArgs,
        address recipient
    ) public {
        require(
            swapHashSender[
                keccak256(abi.encode(destDomain, swapMessageNonce))
            ] == msg.sender
        );

        bytes32 bridgeNonceHash = keccak256(
            abi.encodePacked(
                messageTransmitter.localDomain(),
                bridgeMessageNonce
            )
        );

        SwapMessage memory swapMessage = SwapMessage(
            version,
            bridgeNonceHash,
            0,
            buyArgs.buyToken,
            buyArgs.guaranteedBuyAmount,
            recipient.addressToBytes32(),
            buyArgs.buycallgas,
            buyArgs.buycalldata
        );

        messageTransmitter.replaceMessage(
            originalMessage.message,
            originalMessage.attestation,
            swapMessage.encode(),
            remoteRouter[destDomain]
        );
        emit ReplaceSwapMessage(
            buyArgs.buyToken.bytes32ToAddress(),
            destDomain,
            recipient,
            swapMessageNonce
        );
    }

    /// Relayer entrance
    function relay(
        MessageWithAttestation calldata bridgeMessage,
        MessageWithAttestation calldata swapMessage
    ) public {
        // 1. decode swap message, get binding bridge message nonce.
        SwapMessage memory swapArgs = swapMessage.message.body().decode();

        // 2. check bridge message nonce is unused.
        require(
            messageTransmitter.usedNonces(swapArgs.bridgeNonceHash) == 0,
            "bridge message nonce is already used"
        );

        // 3. verifys bridge message attestation and mint usdc to this contract.
        // reverts when atestation is invalid.
        uint256 usdc_bal_0 = IERC20(usdc).balanceOf(address(this));
        messageTransmitter.receiveMessage(
            bridgeMessage.message,
            bridgeMessage.attestation
        );
        uint256 usdc_bal_1 = IERC20(usdc).balanceOf(address(this));
        require(usdc_bal_1 >= usdc_bal_0, "usdc bridge error");

        // 4. check bridge message nonce is used.
        require(
            messageTransmitter.usedNonces(swapArgs.bridgeNonceHash) == 1,
            "bridge message nonce is incorrect"
        );

        // 5. verifys swap message attestation.
        // reverts when atestation is invalid.
        messageTransmitter.receiveMessage(
            swapMessage.message,
            swapMessage.attestation
        );

        address recipient = swapArgs.recipient.bytes32ToAddress();

        emit BridgeArrive(swapArgs.bridgeNonceHash, usdc_bal_1 - usdc_bal_0);

        uint256 bridgeUSDCAmount;
        if (swapArgs.sellAmount == 0) {
            bridgeUSDCAmount = usdc_bal_1 - usdc_bal_0;
        } else {
            bridgeUSDCAmount = swapArgs.sellAmount;
            require(
                bridgeUSDCAmount <= (usdc_bal_1 - usdc_bal_0),
                "router did not receive enough usdc"
            );
        }

        uint256 swapAmount = bridgeUSDCAmount - getFee(bridgeUSDCAmount);

        require(swapArgs.version == version, "wrong swap message version");

        if (
            swapArgs.buyToken == bytes32(0) ||
            swapArgs.buyToken == usdc.addressToBytes32()
        ) {
            // receive usdc
            bool succ = IERC20(usdc).transfer(recipient, bridgeUSDCAmount);
            require(succ, "erc20 transfer failed");
        } else {
            try
                this.zeroExSwap(
                    swapArgs.swapdata,
                    swapArgs.callgas,
                    usdc,
                    swapAmount,
                    swapArgs.buyToken.bytes32ToAddress(),
                    swapArgs.guaranteedBuyAmount,
                    recipient
                )
            {} catch {
                IERC20(usdc).transfer(recipient, swapAmount);
                emit DestSwapFailed(swapArgs.bridgeNonceHash);
                return;
            }
            // TODO get usdc_bal_2
            // rem = usdc_bal_1 - usdc_bal_2
            // transfer rem to recipient
            emit DestSwapSuccess(swapArgs.bridgeNonceHash);
        }
    }

    /// @dev Does not handle message.
    /// Returns a boolean to make message transmitter accept or refuse a message.
    function handleReceiveMessage(
        uint32 sourceDomain,
        bytes32 sender,
        bytes calldata messageBody
    ) external returns (bool) {
        require(
            msg.sender == address(messageTransmitter),
            "caller not allowed"
        );
        if (remoteRouter[sourceDomain] == sender) {
            return true;
        }
        return false;
    }

    function usedNonces(bytes32 nonce) external view returns (uint256) {
        return messageTransmitter.usedNonces(nonce);
    }

    function localDomain() external view returns (uint32) {
        return messageTransmitter.localDomain();
    }
}
