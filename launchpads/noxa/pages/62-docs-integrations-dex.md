# Noxa - docs integrations dex

> Source: https://docs.noxa.fi/integrations/dex/
> Retrieved: 2026-09-02 (Jina Reader)

---

Title: DEX Integration

URL Source: https://docs.noxa.fi/integrations/dex/

Markdown Content:
NOXA Fun supports multiple DEXes per chain. If you run a DEX and want to be added as a launch target, this page explains the requirements and process.

Your DEX must be:

1.   **Uniswap V3 fork** (unmodified contracts), OR
2.   **PancakeSwap V3 fork** (unmodified contracts)

We do not support:

*   V2-only DEXes (no concentrated liquidity)
*   Custom AMM implementations
*   DEXes with modified core contracts

NOXA Fun creates LP positions programmatically. We need to know exactly how the contracts behave. Modified forks introduce unknown behavior that could cause issues.

Unmodified means:

*   Same function signatures as Uniswap/PancakeSwap V3
*   Same events
*   Same pool creation process
*   Same NFT position manager

## What We Need From You

[Section titled “What We Need From You”](https://docs.noxa.fi/integrations/dex/#what-we-need-from-you)

To add your DEX to NOXA Fun:

### 1. Contract Addresses

[Section titled “1. Contract Addresses”](https://docs.noxa.fi/integrations/dex/#1-contract-addresses)

*   NonfungiblePositionManager
*   SwapRouter02 (for Uniswap V3 forks) or SmartRouter (for PancakeSwap V3 forks)
*   Factory
*   QuoterV2

### 2. Chain Information

[Section titled “2. Chain Information”](https://docs.noxa.fi/integrations/dex/#2-chain-information)

*   Chain ID
*   RPC endpoints (public or shared)
*   Block explorer URL

*   DEX name
*   Logo
*   Website URL

*   Confirm contracts are unmodified Uniswap V3 or PancakeSwap V3 forks
*   Confirm you’re okay being listed on NOXA Fun
*   Point of contact for issues

## Integration Process

[Section titled “Integration Process”](https://docs.noxa.fi/integrations/dex/#integration-process)

1.   **Contact us** via [Telegram](https://t.me/Noxa_Fi)
2.   **Provide** the information listed above
3.   **We verify** the contracts are compatible
4.   **Testing** on testnet if available
5.   **Deployment** - your DEX appears as an option on NOXA Fun

## Example: Monad Integration

[Section titled “Example: Monad Integration”](https://docs.noxa.fi/integrations/dex/#example-monad-integration)

On Monad, we support:

*   **NOXA DEX** - our own deployment
*   **Uniswap** - official Uniswap deployment
*   **PancakeSwap** - official PancakeSwap deployment

Users launching tokens on [fun.noxa.fi/monad](https://fun.noxa.fi/monad) can choose any of these.

## Benefits for Your DEX

[Section titled “Benefits for Your DEX”](https://docs.noxa.fi/integrations/dex/#benefits-for-your-dex)

Being listed on NOXA Fun means:

*   **New tokens launch on your DEX** - immediate volume and users
*   **Locked liquidity** - LP that never leaves
*   **Degen community** - exposure to active traders

Ready to integrate? Reach out:

*   **Telegram:**[t.me/Noxa_Fi](https://t.me/Noxa_Fi)
*   **Twitter:**[@Noxa_Fi](https://x.com/Noxa_Fi)
*   **Dev Contact:**[t.me/AmunPhantom](https://t.me/AmunPhantom)

Links/Buttons:
- [Skip to content](https://docs.noxa.fi/integrations/dex/#_top)
- [NOXA](https://docs.noxa.fi/)
- [Twitter](https://x.com/Noxa_Fi)
- [Telegram](https://t.me/Noxa_Fi)
- [Introduction](https://docs.noxa.fi/introduction/)
- [Overview](https://docs.noxa.fi/dex/overview/)
- [How to Launch](https://docs.noxa.fi/launchpad/how-to-launch/)
- [Supported Chains](https://docs.noxa.fi/launchpad/chains/)
- [Trading](https://docs.noxa.fi/dex/trading/)
- [Liquidity](https://docs.noxa.fi/dex/liquidity/)
- [NOXA Fun](https://docs.noxa.fi/contracts/noxa-fun/)
- [NOXA DEX](https://docs.noxa.fi/contracts/noxa-dex/)
- [Building on NOXA Fun](https://docs.noxa.fi/integrations/launchpad/)
- [DEX Integration](https://docs.noxa.fi/integrations/dex/)
- [Requirements](https://docs.noxa.fi/integrations/dex/#requirements)
- [Why Unmodified?](https://docs.noxa.fi/integrations/dex/#why-unmodified)
- [What We Need From You](https://docs.noxa.fi/integrations/dex/#what-we-need-from-you)
- [1. Contract Addresses](https://docs.noxa.fi/integrations/dex/#1-contract-addresses)
- [2. Chain Information](https://docs.noxa.fi/integrations/dex/#2-chain-information)
- [3. Branding](https://docs.noxa.fi/integrations/dex/#3-branding)
- [4. Confirmation](https://docs.noxa.fi/integrations/dex/#4-confirmation)
- [Integration Process](https://docs.noxa.fi/integrations/dex/#integration-process)
- [Example: Monad Integration](https://docs.noxa.fi/integrations/dex/#example-monad-integration)
- [Benefits for Your DEX](https://docs.noxa.fi/integrations/dex/#benefits-for-your-dex)
- [Contact](https://docs.noxa.fi/integrations/dex/#contact)
- [fun.noxa.fi/monad](https://fun.noxa.fi/monad)
- [t.me/AmunPhantom](https://t.me/AmunPhantom)
