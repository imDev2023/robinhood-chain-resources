# TaxProcessor-0xd62198DC5aA79754D36DD07B90393C96f2B72EB4

**TaxProcessor clone for one tax token**

- Address: `0xd62198DC5aA79754D36DD07B90393C96f2B72EB4`
- Contract name on Blockscout: `unnamed`
- Verified: yes
- Proxy type: `eip1167`, implementation `0x92C7ed364CB74B13D0C0168CDb2195e569811dF2`
- Creator: `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09`
- Creation tx: `0xcf12b7e5eff03861824b465cc39129ed6fcf32a0ffab500042e1257c4b5b3778`
- Explorer: <https://robinhoodchain.blockscout.com/address/0xd62198DC5aA79754D36DD07B90393C96f2B72EB4>

EIP-1167 clone of `TaxProcessorUniV2Impl`.
One is deployed per tax token, and it is where the tax is split.

Live reads on 2026-09-02 (`_raw/rpc/taxprocessor-live.txt`):

| call | value |
| --- | --- |
| `taxToken()` | `0xa942f0bcca47752a942039559d00525633737777` |
| `quoteToken()` | `0x0bd7d308...` (WETH) |
| `feeReceiver()` | `0xa4a727e0...`, the Flap FeeSafe |
| `marketAddress()` | `0xd35e36df...`, the Sinjoh adapter |
| `commissionReceiver()` | `0xd35e36df...` |
| `commissionBps()` | `60` |
| `feeConfigV2()` | `(marketBps 10000, deflationBps 0, lpBps 0, dividendBps 0, feeRate 300, isWeth true, commissionBps 60, dividendToken WETH)` |

So of every unit of tax collected: 3% to Flap, 0.6% to the commission receiver, and the remaining 96.4% split across the four creator buckets.

## Callable surface

No verified source.
`bytecode.hex` holds the runtime code, `selectors.txt` is a PUSH4 scan of it, and `selectors-decoded.txt` resolves those selectors through openchain.

## Files in this directory

- `address.json`
- `bytecode.hex`
- `metadata.json`
- `selectors.txt`
