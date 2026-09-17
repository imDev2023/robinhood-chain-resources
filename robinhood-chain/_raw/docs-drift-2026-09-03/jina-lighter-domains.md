Title: Robinhood Chain Lighter Domains

URL Source: https://docs.robinhood.com/chain/lighter-domains

Markdown Content:
## What is a Lighter Domain?

Lighter Domains are independent Lighter instances with separate execution, sequencing, blockspace, and liquidity. That separation is intentional — allowing markets to serve different ecosystems, partners, and regulatory requirements. Long-term, they are designed to preserve separation where it matters while enabling future connectivity through proof aggregation and verified messaging.

The **Robinhood Chain Instance** is a dedicated Lighter instance deployed on the Robinhood Chain. It is not the same as Lighter Core — it has its own contracts, sequencer, blockspace, and liquidity.

## Key Information

| Resource | Address |
| --- | --- |
| Public UI | [https://robinhoodchain.lighter.xyz](https://robinhoodchain.lighter.xyz/) |
| Lighter Contract | `0x94bAB9693Ba2f6358507eFfcbd372b0660AFfF9d` |
| API Docs | [https://apidocs.rh.lighter.xyz/docs/get-started](https://apidocs.rh.lighter.xyz/docs/get-started) |
| API Base URL | [https://api.rh.lighter.xyz/](https://api.rh.lighter.xyz/) |

## Deposit

### Direct Deposit (same-chain, on RH Chain) — preferred for RH Wallet

Call the `deposit` method on the Lighter contract directly:

```
function deposit(
    address _to,
    uint16  _assetIndex,
    TxTypes.RouteType _routeType,   // uint8
    uint256 _amount
) external payable
```

**Example (USDG deposit):**

```
_to          = <recipient address>
_assetIndex  = 3          // USDG
_routeType   = 0
_amount      = 1000000    // 1 USDG = 1e6 (6 decimals)
```

> Anyone can call `deposit` on behalf of any address. The account is created on the first deposit.

### Cross-chain / Intent Address Deposit

For deposits originating from other chains (e.g., Ethereum → Robinhood Chain):

1.   Call `createIntentAddress` to get a deterministic deposit address.
2.   Send USDG to that intent address (no `deposit()` call needed).
3.   Lighter monitors the intent address and calls `deposit` on-chain via `CREATE2` (1 block + 1 round trip).
4.   The monitoring service credits the user (1 block + 1 round trip).

## Withdraw

Two modes, both operational on Robinhood Chain:

*   **Fast Withdraw** — uses Robinhood Chain's soft finality; near-instant.
*   **Secure Withdraw** — standard L2 withdrawal with full finality guarantees.

## Learn More

*   [Lighter Robinhood API Docs](https://apidocs.rh.lighter.xyz/docs/get-started)

Links/Buttons:
- [Skip to content](https://docs.robinhood.com/chain/lighter-domains#vocs-content)
- [](https://docs.robinhood.com/chain/lighter-domains#robinhood-chain-lighter-domains)
- [Connecting to Robinhood Chain](https://docs.robinhood.com/chain/connecting)
- [Add network to your wallet](https://docs.robinhood.com/chain/add-network-to-wallet)
- [Bridging](https://docs.robinhood.com/chain/bridging)
- [Overview](https://docs.robinhood.com/chain/notices-and-upgrades)
- [Building with Stock Tokens](https://docs.robinhood.com/chain/building-with-stock-tokens)
- [Stock Token APIs](https://docs.robinhood.com/chain/stock-token-apis)
- [Differences from Ethereum](https://docs.robinhood.com/chain/differences-from-ethereum)
- [Gas & Fees](https://docs.robinhood.com/chain/gas-and-fees)
- [Transaction Finality](https://docs.robinhood.com/chain/transaction-finality)
- [Token Contracts](https://docs.robinhood.com/chain/contracts)
- [Protocol Contracts](https://docs.robinhood.com/chain/protocol-contracts)
- [Deploy a Contract](https://docs.robinhood.com/chain/deploy-smart-contracts)
- [Account Abstraction](https://docs.robinhood.com/chain/account-abstraction)
- [Cross-Chain Messaging](https://docs.robinhood.com/chain/cross-chain-messaging)
- [Oracles & Price Feeds](https://docs.robinhood.com/chain/oracles-and-price-feeds)
- [Data Streams](https://docs.robinhood.com/chain/data-streams)
- [Lighter Domains](https://docs.robinhood.com/chain/lighter-domains)
- [Run a full node](https://docs.robinhood.com/chain/run-a-full-node)
- [Governance](https://docs.robinhood.com/chain/governance)
- [Report an issue](https://docs.robinhood.com/chain/report-issue)
- [Terms of Service](https://docs.robinhood.com/chain/terms-of-service)
- [Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Flighter-domains%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)
- [What is a Lighter Domain?](https://docs.robinhood.com/chain/lighter-domains#what-is-a-lighter-domain)
- [Key Information](https://docs.robinhood.com/chain/lighter-domains#key-information)
- [Deposit](https://docs.robinhood.com/chain/lighter-domains#deposit)
- [Direct Deposit (same-chain, on RH Chain) — preferred for RH Wallet](https://docs.robinhood.com/chain/lighter-domains#direct-deposit-same-chain-on-rh-chain--preferred-for-rh-wallet)
- [Cross-chain / Intent Address Deposit](https://docs.robinhood.com/chain/lighter-domains#cross-chain--intent-address-deposit)
- [Withdraw](https://docs.robinhood.com/chain/lighter-domains#withdraw)
- [Learn More](https://docs.robinhood.com/chain/lighter-domains#learn-more)
- [https://robinhoodchain.lighter.xyz](https://robinhoodchain.lighter.xyz/)
- [https://apidocs.rh.lighter.xyz/docs/get-started](https://apidocs.rh.lighter.xyz/docs/get-started)
- [https://api.rh.lighter.xyz/](https://api.rh.lighter.xyz/)
