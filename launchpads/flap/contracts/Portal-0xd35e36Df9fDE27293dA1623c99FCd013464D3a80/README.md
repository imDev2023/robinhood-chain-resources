# Portal-0xd35e36Df9fDE27293dA1623c99FCd013464D3a80

**SinjohFlapAdapter clone, NOT the Flap Portal**

- Address: `0xd35e36Df9fDE27293dA1623c99FCd013464D3a80`
- Contract name on Blockscout: `unnamed`
- Verified: yes
- Proxy type: `eip1167`, implementation `0x4c34af31ef8962317497Cc558612a48443971243`
- Creator: `0x77748D07CAD323A7f6EFa54968aCF69de743be61`
- Creation tx: `0x4d12f1da137ba48434dd065099f047ff3e3b3c64dd478f902b1ac2d8b07cfac2`
- Explorer: <https://robinhoodchain.blockscout.com/address/0xd35e36Df9fDE27293dA1623c99FCd013464D3a80>

The directory name is wrong and is kept only because earlier captures referenced it.
This address is an EIP-1167 clone of `SinjohFlapAdapterImpl-0x4c34af31ef8962317497Cc558612a48443971243`, deployed by `SinjohFlapAdapterFactory-0x77748D07CAD323A7f6EFa54968aCF69de743be61`.
The real Flap Portal is `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09` (directory `FlapCore-...`).

Live reads (`_raw/rpc/sinjoh-adapter.txt`) show it is a third-party launcher wrapped around Flap:

| call | value |
| --- | --- |
| `portal()` | `0x26605f32...`, the Flap Portal |
| `subject()` | `0xa942f0bcca47752a942039559d00525633737777`, the token it launched |
| `creator()` | `0x3d58e42d3a920de4c1f71ee041c7ebb82ee23f49` |
| `taxProcessor()` | `0xd62198DC5aA79754D36DD07B90393C96f2B72EB4` |
| `flapFeeRate()` | `300` |
| `flapCommissionBps()` | `60` |
| `feeRoutingIntact()` | `true` |
| `deploymentChainId()` | `4663` |

It is simultaneously the `marketAddress` and the `commissionReceiver` on that token's TaxProcessor, so it collects both the creator bucket and the launcher commission.

## Callable surface

No verified source.
`bytecode.hex` holds the runtime code, `selectors.txt` is a PUSH4 scan of it, and `selectors-decoded.txt` resolves those selectors through openchain.

## Files in this directory

- `address.json`
- `bytecode.hex`
- `metadata.json`
- `selectors.txt`
