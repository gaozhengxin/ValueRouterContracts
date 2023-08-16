
## 测试合约地址
- AVAX - https://snowtrace.io/address/0xf8d0f5f8bba78f1d91b8576c4c5c8399b0bdd33f#code
- Arbitrum - https://arbiscan.io/address/0xFA08bc4dc51eD8DB9898D872241a593a53768C3F#code

## Functions
### swap(0xf9f288b5) payable

发起本地 swap

参数
| name                | type    |                         |
| ------------------- | ------- | ----------------------- |
| swapcalldata        | bytes   | 0x swap calldata        |
| callgas             | uint256 | gas required by 0x swap |
| sellToken           | address | 卖出 token              |
| sellAmount          | uint256 | 卖出 token 数量         |
| buyToken            | address | 买入 token              |
| guaranteedBuyAmount | uint256 | 至少买入 token 数量     |

### swapAndBridge(0x8f4d57d4) payable

发起跨链 swap

参数
| name       | type     |                                       |
| ---------- | -------- | ------------------------------------- |
| sellArgs   | SellArgs | 源链 swap参数                         |
| buyArgs    | BuyArgs  | 目标链 swap参数                       |
| destDomain | uint32   | 目标链标识，ETH-0，AVAX-1，Arbitrum-3 |
| recipient  | bytes32  | 目标链Token接收地址                   |

返回值

| name         | type   |                               |
| ------------ | ------ | ----------------------------- |
| bridgeNonce  | uint64 | CCTP bridge 消息的 nonce      |
| messageNonce | uint64 | CCTP 目标链 swap 消息的 nonce |

#### SellArgs
| name                | type    |                                                          |
| ------------------- | ------- | -------------------------------------------------------- |
| sellToken           | address | 卖出的 ERC20 token 地址                                  |
| guaranteedBuyAmount | uint256 | 至少要买到的 usdc 数量，用作第二个 0x swap 的 sellAmount |
| sellAmount          | uint256 | 卖出的 ERC20 数量                                        |
| sellcallgas         | uint256 | 0x swap 消耗的 gas                                       |
| sellcalldata        | bytes   | 0x swap calldata                                         |

- sellcallgas: 0xAPIResult.gas
- sellcalldata: 0xAPIResult.data

Example
<details>
  <summary>0x swap api result example</summary>
```JSON
{"chainId":5,"price":"23.17878037803780378","guaranteedPrice":"22.946894689468946894","estimatedPriceImpact":"0","to":"0xf91bb752490473b8342a3e964e855b9f9a2a668e","data":"0x415565b0000000000000000000000000b4fbf271143f4fbf7b91a5ded31805e42b2208d60000000000000000000000001f9840a85d5af5bf1d1762f925bdaddc4201f98400000000000000000000000000000000000000000000000000000000000022b80000000000000000000000000000000000000000000000000000000000031cb000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000003e000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b4fbf271143f4fbf7b91a5ded31805e42b2208d60000000000000000000000001f9840a85d5af5bf1d1762f925bdaddc4201f98400000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000000000000000000000000000000000000000022b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000025375736869537761700000000000000000000000000000000000000000000000000000000000000000000000000022b80000000000000000000000000000000000000000000000000000000000031cb0000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000001b02da8cb0d097eb8d57a175b88c7d8b4799750600000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000002000000000000000000000000b4fbf271143f4fbf7b91a5ded31805e42b2208d60000000000000000000000001f9840a85d5af5bf1d1762f925bdaddc4201f9840000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000b4fbf271143f4fbf7b91a5ded31805e42b2208d6000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000869584cd000000000000000000000000100000000000000000000000000000000000001100000000000000000000000000000000000000000000009a4a77535f64c9d010","value":"0","gas":"265000","estimatedGas":"265000","gasPrice":"20000","protocolFee":"0","minimumProtocolFee":"0","buyTokenAddress":"0x1f9840a85d5af5bf1d1762f925bdaddc4201f984","sellTokenAddress":"0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6","buyAmount":"206013","sellAmount":"8888","sources":[{"name":"0x","proportion":"0"},{"name":"SushiSwap","proportion":"1"},{"name":"Uniswap","proportion":"0"},{"name":"Uniswap_V2","proportion":"0"},{"name":"Uniswap_V3","proportion":"0"}],"orders":[{"type":0,"source":"SushiSwap","makerToken":"0x1f9840a85d5af5bf1d1762f925bdaddc4201f984","takerToken":"0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6","makerAmount":"206013","takerAmount":"8888","fillData":{"tokenAddressPath":["0xb4fbf271143f4fbf7b91a5ded31805e42b2208d6","0x1f9840a85d5af5bf1d1762f925bdaddc4201f984"],"router":"0x1b02da8cb0d097eb8d57a175b88c7d8b47997506"},"fill":{"input":"8888","output":"206013","adjustedOutput":"1","gas":115000}}],"allowanceTarget":"0xf91bb752490473b8342a3e964e855b9f9a2a668e","decodedUniqueId":"9a4a77535f-1690947600","sellTokenToEthRate":"1","buyTokenToEthRate":"23.154654038331182393","fees":{"zeroExFee":null},"grossPrice":"23.17878037803780378","grossBuyAmount":"206013","grossSellAmount":"8888","auxiliaryChainData":{},"expectedSlippage":null}
```
</details>

- sellcallgas: 265000
- sellcalldata - `0x415565b0......`

##### 源链输入 USDC
不需要 0x swapdata，sellToken 设为 `0x0000000000000000000000000000000000000000` 或 usdc token 地址，sellcalldata 设为 "0x0000000000000000000000000000000000000000000000000000000000000000".
##### 源链输入 ETH
sellToken `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`.

#### BuyArgs
| name                | type    |                                                                            |
| ------------------- | ------- | -------------------------------------------------------------------------- |
| buyToken            | bytes32 | 买入的 ERC20 token 地址                                                    |
| guaranteedBuyAmount | uint256 | 预计买入的 ERC20 数量，用户同意前提下略低于 0x api 返回的 gross buy amount |
| buycallgas          | uint256 | 0x swap 消耗的 gas                                                         |
| buycalldata         | bytes   | 0x swap calldata                                                           |

##### 目标链输出 USDC
不需要 0x swapdata，sellToken 设为 `0x0000000000000000000000000000000000000000` 或**目标链的** usdc token 地址，sellcalldata 设为空.
##### 目标链输出 ETH
sellToken `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`.

### relay(0xa3fc34a3)
| name          | type                   |                        |
| ------------- | ---------------------- | ---------------------- |
| bridgeMessage | MessageWithAttestation | bridge 消息和证明      |
| swapMessage   | MessageWithAttestation | 目标链 swap 消息和证明 |

#### MessageWithAttestation
| name        | type  |           |
| ----------- | ----- | --------- |
| message     | bytes | CCTP 消息 |
| attestation | bytes | CCTP 证明 |

## Events
### SwapAndBridge
源链发起跨链
`event SwapAndBridge(address sellToken,address buyToken,uint256 ridgeUSDCAmount,uint32 destDomain,address recipient,uint64 bridgeNonce,uint64 swapMessageNonce,bytes32 bridgeHash);`
### BridgeArrive
USDC 跨链完成
`event BridgeArrive(bytes32 bridgeNonceHash, uint256 amount);`
### DestSwapFailed
目标链 swap 失败
`event DestSwapFailed(bytes32 bridgeNonceHash);`
### DestSwapSuccess
目标链 swap 成功`event DestSwapSuccess(bytes32 bridgeNonceHash);`