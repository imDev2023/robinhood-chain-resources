> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/vault-developers/vault-and-vaultfactory-specification.md).

# Vault & VaultFactory Specification

## Table of Contents

* [Quick start](#quick-start)
* [Overview](#overview)
* [The Vault Specification](#the-vault-specification)
  * [VaultBase / VaultBaseV2 / VaultBaseV3 (current interface)](#vaultbase--vaultbasev2--vaultbasev3-current-interface)
  * [Implementation requirements](#implementation-requirements)
  * [The Flap Guardian](#the-flap-guardian)
  * [Why the Beacon Proxy pattern matters](#why-the-beacon-proxy-pattern-matters)
  * [Adapter for legacy vaults](#adapter-for-legacy-vaults)
  * [VaultBaseV3 — ERC20 quote token support](#vaultbasev3--erc20-quote-token-support)
    * [How the ping works](#how-the-ping-works)
    * [Normative accounting model](#normative-accounting-model)
    * [Implementing a V3 vault — checklist](#implementing-a-v3-vault--checklist)
* [VaultFactory Specification](#vaultfactory-specification)
  * [IVaultFactory / VaultFactoryBaseV2 (current interface)](#ivaultfactory--vaultfactorybasev2-current-interface)
  * [Generic validation hook — `onBeforeLaunch(bytes)`](#generic-validation-hook--onbeforelaunchbytes)
  * [Spec version discovery — `factorySpecVersion()`](#spec-version-discovery--factoryspecversion)
  * [Policy discovery — `tokenCreationPolicies()`](#policy-discovery--tokencreationpolicies)
  * [v2.3: Computed dividend tokens — `resolveDividendToken`](#v23-computed-dividend-tokens--resolvedividendtoken)
  * [Recommended commission fee structure](#recommended-commission-fee-structure)
* [UI Schema Reference (IVaultSchemasV1)](#ui-schema-reference-ivaultschemasv1)
* [Get your vault verified](#get-your-vault-verified)
* [Appendix: Older spec versions](#appendix-older-spec-versions)

## Quick start

1. **Follow the example** — Work through the [FlapVaultExample repository](https://github.com/flap-sh/FlapVaultExample) to see a complete, working vault and vault factory implementation. It is the fastest way to understand the patterns you need to follow.
2. **Verify your implementation** — Once you have written your vault, use the [Vault spec checker](https://github.com/flap-sh/FlapVaultExample/blob/main/.agents/skills/flap-vault-spec-checker/SKILL.md) to automatically check that your implementation correctly follows this specification before deploying.

See the [Quick start for Vault Developers](/flap/developers/vault-developers/quick-start-vault-developers.md) page for the full onboarding checklist.

## Overview

Flap's vault system allows anyone to build smart contracts for managing and distributing BNB revenue generated from tax tokens. Vaults can be customized to fit various use cases — splitting revenue among multiple recipients, routing funds based on social proof, funding a game treasury, or anything else you can imagine.

{% hint style="info" %}
**Permissionless vault creation** — You can create and deploy your own vaults and vault factories **without any permission or registration**. Vault factories no longer need to be registered in the VaultPortal before they can be used to launch tokens. Users can use any vault they want when launching tokens.
{% endhint %}

{% hint style="warning" %}
For a complete working example of a vault and vault factory implementation, check out the [FlapVaultExample repository](https://github.com/flap-sh/FlapVaultExample).
{% endhint %}

This page documents the **current** vault and vault factory interfaces — `VaultBaseV3` (which extends `VaultBaseV2`, which extends `VaultBase`) and `VaultFactoryBaseV2` targeting spec `v2.3`. **We recommend all new vaults and factories target these latest interfaces** — `VaultBaseV3` (not `VaultBaseV2`) and factory spec `v2.3` (not `v2.2`) — even if your vault only ever handles the native gas token today: declaring `vaultQuoteToken() == address(0)` costs nothing and future-proofs the vault for ERC20 quote support. Older revisions (`VaultBase`/V1, `VaultBaseV2`, and the `v2.1`/`v2.2` factory validation surfaces) are fully backwards-compatible and are summarized in the [Appendix](#appendix-older-spec-versions) at the end of this page — they remain supported, but new vaults and factories should target the interfaces documented below, not the legacy ones.

## The Vault Specification

### VaultBase / VaultBaseV2 / VaultBaseV3 (current interface)

To be compatible with the VaultPortal system, your vault smart contract must inherit `VaultBaseV3` (which extends `VaultBaseV2`, which extends `VaultBase`) — this is the **recommended, latest interface** for all new vaults, regardless of whether your vault handles native or ERC20 quote revenue. This is the complete, current interface chain, pulled directly from [`FlapVaultExample`](https://github.com/flap-sh/FlapVaultExample/blob/main/src/flap/VaultBase.sol) and [`VaultBaseV3.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/src/flap/VaultBaseV3.sol) — including the current per-chain Portal and Guardian addresses (BNB mainnet, BNB testnet, and **Robinhood Chain**):

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

/// @title VaultBase
/// @notice Abstract base contract for all vault implementations
/// @author The Flap Team
abstract contract VaultBase {
    /// @notice Error thrown when the current chain is not supported
    error UnsupportedChain(uint256 chainId);

    /// @notice Get the Portal address for the current chain
    /// @dev Currently supports BNB Chain (56), BNB Testnet (97), and Robinhood Chain (4663)
    /// @return portal The Portal contract address
    function _getPortal() internal view returns (address portal) {
        uint256 chainId = block.chainid;
        if (chainId == 56) {
            // BNB Chain Portal
            return 0xe2cE6ab80874Fa9Fa2aAE65D277Dd6B8e65C9De0;
        } else if (chainId == 97) {
            // BNB Testnet Portal
            return 0x5bEacaF7ABCbB3aB280e80D007FD31fcE26510e9;
        } else if (chainId == 4663) {
            // Robinhood Chain Portal
            return 0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09;
        }
        revert UnsupportedChain(chainId);
    }

    /// @notice Get the Guardian address for the current chain
    /// @dev Currently supports BNB Chain (56), BNB Testnet (97), and Robinhood Chain (4663)
    /// @return guardian The Guardian contract address
    function _getGuardian() internal view returns (address guardian) {
        uint256 chainId = block.chainid;
        if (chainId == 56) {
            // BNB Chain Guardian address
            return 0x9e27098dcD8844bcc6287a557E0b4D09C86B8a4b;
        } else if (chainId == 97) {
            // BNB Testnet Guardian address
            return 0x76Fa8C526f8Bc27ba6958B76DeEf92a0dbE46950;
        } else if (chainId == 4663) {
            // Robinhood Chain Guardian address
            return 0x0000b48720d3B4ED6BC5031768B07F2b59270000;
        }
        revert UnsupportedChain(chainId);
    }

    /// @notice Returns a description of the vault
    /// @dev Must be overridden to provide a dynamic description based on the vault's current state
    /// @return A string describing the vault's current state and configuration
    function description() public view virtual returns (string memory);
}

/// @title VaultBaseV2
/// @author The Flap Team
/// @notice Extended abstract base contract for vault implementations that adds
///         on-chain UI schema discovery via `vaultUISchema()`.
/// @dev    Inherits all `VaultBase` obligations (`description()`, `_getPortal()`,
///         `_getGuardian()`, the Guardian mandate). New vault implementations
///         should extend `VaultBaseV2` instead of `VaultBase` directly, to gain
///         automatic UI generation.
abstract contract VaultBaseV2 is VaultBase {
    /// @notice Returns the UI schema describing which methods the UI should
    ///         render for this vault.
    /// @dev Each vault implementation **must** override this to describe its
    ///      own user-facing methods. See the UI Schema Reference section below
    ///      for the full `VaultUISchema` struct definition and rendering algorithm.
    /// @return schema The complete UI schema for this vault.
    function vaultUISchema() public pure virtual returns (VaultUISchema memory schema);
}

/// @title VaultBaseV3
/// @author The Flap Team
/// @notice Extended abstract base contract for vault implementations that adds
///         support for ERC20 quote tokens (stablecoins, tokenized equities / RWA)
///         as the vault's revenue currency, via `vaultQuoteToken()` discovery and
///         a normative balance-delta accounting model. See "VaultBaseV3 — ERC20
///         quote token support" below for the full spec (the ping mechanism and
///         the accounting rules a V3 vault must implement).
abstract contract VaultBaseV3 is VaultBaseV2 {
    /// @notice The revenue currency this vault accounts for.
    /// @dev MUST equal the quote token of the tax token this vault serves:
    ///      `address(0)` for the native gas token, the ERC20 address
    ///      otherwise. MUST be stable for the life of the vault and MUST NOT
    ///      revert. Consumed by the VaultPortal launch cross-check and by
    ///      lens/UI discovery.
    /// @return quoteToken The revenue currency (`address(0)` = native).
    function vaultQuoteToken() public view virtual returns (address quoteToken);

    /// @notice The vault-side spec revision this implementation conforms to.
    /// @dev Distinct from the factory-side `factorySpecVersion()` ("v2.x"
    ///      series): this string versions the VAULT contract surface.
    ///      Lenses read it to distinguish V3 vaults from legacy ones (which
    ///      implement neither this method nor `vaultQuoteToken()`).
    /// @return The spec version string, "v3" for this revision.
    function vaultSpecVersion() public pure virtual returns (string memory) {
        return "v3";
    }
}
```

{% hint style="success" %}
**Recommended: always inherit `VaultBaseV3`, not `VaultBaseV2`.** Even for native-only vaults, declaring `vaultQuoteToken()` to return `address(0)` costs nothing and future-proofs the vault — see [VaultBaseV3 — ERC20 quote token support](#vaultbasev3--erc20-quote-token-support) below for the full spec (motivation, the ping mechanism, the balance-delta accounting model, and the implementation checklist). `VaultBaseV2` remains fully supported for existing vaults, but new vaults should target `VaultBaseV3`.
{% endhint %}

### Implementation requirements

1. **Implement `description()`** — Return a dynamic string that describes the vault's current state. The description should change based on the vault's state (e.g. balance, streaming status, etc.).
2. **Implement `receive()`** — Accept revenue (BNB, or an ERC20 quote token if using `VaultBaseV3`) and process it according to your vault's logic. For `VaultBaseV3` vaults, `receive()` must follow the [balance-delta accounting model](#normative-accounting-model) described below.
3. **Implement `vaultUISchema()`** — Return a `VaultUISchema` describing every user-facing method your vault exposes, so the UI can automatically render an interaction page without custom code. See the [UI Schema Reference](#ui-schema-reference-ivaultschemasv1) section for the full struct definitions and worked examples.
4. **Guardian mandate** — If you have any permissioned functions that should be triggered by an external address, and it is not suitable to make them public (e.g. buyback which may be sandwich attacked), you **must** also give the Guardian address the permissions alongside other allowed addresses as a backup. See the [Flap Guardian](#the-flap-guardian) section for details.
5. **If inheriting `VaultBaseV3`** (recommended for all new vaults) — **override `vaultQuoteToken()`** to declare your revenue currency (`address(0)` for native), and follow the [balance-delta accounting model](#normative-accounting-model) in `receive()`. See [VaultBaseV3 — ERC20 quote token support](#vaultbasev3--erc20-quote-token-support) below for the full checklist.

### The Flap Guardian

The Flap Guardian is a privileged address that can always call permissioned functions in vault contracts that implement the Vault Specification. The Guardian serves as a backup mechanism to ensure that critical functions can be executed even if the primary authorized addresses are unable to do so.

At this moment, the Guardian is an empty but upgradeable contract managed by Flap:

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

/// @title FlapGuardian
/// @notice Guardian contract for vault emergency management and CTO cases
/// @dev Currently does nothing, but this contract is upgradeable.
contract FlapGuardian {
    function version() external pure returns (string memory) {
        return "0.0.1";
    }
}
```

Ideally, we don't need to implement any functionality in the Guardian contract. It just serves as a trusted address that can step in when necessary to protect users' funds.

{% hint style="warning" %}
If your vault has permissioned functions, you **must** grant the Guardian the same permissions. The Guardian's access **must not** be revocable by any other account — only the Guardian itself may renounce its own access.

When using OpenZeppelin's `AccessControl`, override `revokeRole()`:

```solidity
function revokeRole(bytes32 role, address account)
    public
    override
    onlyRole(getRoleAdmin(role))
{
    address guardian = _getGuardian();
    if (account == guardian) {
        revert CannotRevokeGuardianRole();
    }
    super.revokeRole(role, account);
}
```

{% endhint %}

### Why the Beacon Proxy pattern matters

For any factory that will deploy more than a handful of vault instances, we recommend building on the **Beacon Proxy pattern** (`UpgradeableBeacon` + `BeaconProxy`, upgrade authority gated to the Flap Guardian). See [Building Upgradeable Vaults — Beacon Proxy Pattern](/flap/developers/vault-developers/case-study-beacon-upgradeable-vault.md) for the full implementation guide.

{% hint style="warning" %}
**The beacon proxy pattern is mandatory if you want the low-risk verification badge** — see [Get your vault verified](#get-your-vault-verified) below. Flap must reserve the ability to upgrade a verified vault if the audit (or a later production issue) finds a bug; that's only possible if upgrade authority sits behind a beacon, held exclusively by the Flap Guardian. It remains fully optional if you don't intend to pursue verification.
{% endhint %}

The beacon proxy pattern serves **two** distinct purposes:

1. **Launch before audit, fix after.** An audit is not required to launch a token (see [Get your vault verified](#get-your-vault-verified) below) — but it, and the beacon, are both required if you want the low-risk badge. If you launch on a beacon proxy and later decide to pursue an audit — or your audit turns up a bug — the implementation behind the beacon can be upgraded to ship the fix, without redeploying or migrating any already-launched token. Without a beacon, a discovered bug means the vault is stuck as-is, and the vault cannot be verified in the first place.
2. **Static analysis has blind spots.** An audit is fundamentally a static analysis of the code as written — it does not catch every issue that only manifests at runtime under real market conditions (unexpected call patterns, edge-case reentrancy, gas griefing under specific mempool conditions, etc.). The beacon proxy gives Flap a way to "save the day" and patch a vault that passed audit but still hit an issue in production, again without asking every token creator to migrate.

{% hint style="info" %}
If your vault is a one-instance-per-token, immutable-for-life design and you don't intend to pursue verification, you can skip the proxy and inherit `VaultBaseV3` directly. The beacon pattern is required for **any vault pursuing the low-risk verification badge**, and is the default recommendation for **factories that will deploy many vault instances** or anyone who wants to launch before completing an audit.
{% endhint %}

### Adapter for legacy vaults

If you have built a vault to receive tax token revenue before the Vault Specification was introduced, you can still make your vault compatible with the VaultPortal system by creating an adapter contract that inherits from `VaultBase` and wraps around your existing vault. The adapter will implement the `description()` method and forward calls to your legacy vault as needed. This way, you can leverage VaultPortal features without modifying your original vault contract.

Please reach out to our team for assistance in creating an adapter for your legacy vault.

### VaultBaseV3 — ERC20 quote token support

Historically, vaults only supported the native gas token (BNB / ETH) as the revenue currency. That's a consequence of how `receive()` gets triggered: a native value transfer invokes the recipient's `receive()`, but an ERC20 `transfer` executes the **token contract's** code, not the recipient's — the vault would receive the funds but never get a chance to run its own logic.

**`VaultBaseV3`** (extends `VaultBaseV2`) lifts that restriction so tokens quoted in an ERC20 — stablecoins, tokenized equities / RWA, or any other ERC20 — can use vaults too. It adds exactly two members on top of `VaultBaseV2` — `vaultQuoteToken()` and `vaultSpecVersion()` — shown in the [current interface](#vaultbase--vaultbasev2--vaultbasev3-current-interface) above.

{% hint style="success" %}
**`VaultBaseV3` is the recommended interface for all new vaults** — including native-only ones. Existing vaults that extend `VaultBase` or `VaultBaseV2` are unaffected and keep working unchanged (fully backwards-compatible), but new or upgraded vault implementations should extend `VaultBaseV3` rather than `VaultBaseV2`. Native-only vaults simply declare `vaultQuoteToken()` as `address(0)` to gain the explicit currency declaration at no cost.
{% endhint %}

#### How the ping works

An ERC20 `transfer` never invokes the recipient's code, so a vault receiving ERC20 tax revenue would otherwise have no way to know new funds arrived. V3 closes that gap with a **wake call ("ping"), sent by the protocol**: after every ERC20 quote payout, the TaxProcessor follows up with `wallet.call{value: 0}("")` — an empty-calldata, zero-value call to the vault. This invokes the vault's `receive()` exactly like a native transfer would, giving the vault a chance to run its accounting logic even though no value accompanies the call itself.

The TaxProcessor's dispatch upholds four invariants — design your vault against them:

1. **Transfer first, ping after.** By the time your `receive()` runs, the ERC20 revenue is already sitting in your balance. The ping is purely a wake-up signal, not the transfer itself.
2. **Ping failures are ignored.** If your `receive()` reverts, dispatch proceeds without you — the funds still arrive, but your logic did not run, and you will only recognize the revenue on the next wake. Do not rely on reverting to refuse revenue.
3. **Ping gas is the dispatcher's, not yours.** The protocol does not cap the wake call — it forwards the dispatch caller's remaining gas (EIP-150), and dispatch is permissionless. The protocol's keeper runs the **entire** dispatch (swaps, dividends, burn, up to four wallet payouts) under one fixed gas budget; a heavy `receive()` makes the keeper's dispatch of your token fail until someone re-dispatches with a higher gas limit. Keep `receive()` lightweight — update accounting, emit an event, return. Put heavy work (swaps, staking, buybacks) behind explicit public functions driven by your own automation or the protocol's keeper/trigger services.
4. **You may be pinged spuriously.** The same wallet can occupy several payout slots and get pinged more than once per dispatch, and anyone can call your `receive()` at any time. A wake that finds no new revenue **must** be a silent no-op.

Native revenue is unchanged — it still arrives as a plain value transfer invoking `receive()`. A V3 vault handles both currencies through the same code path; the accounting model below is currency-agnostic.

{% hint style="warning" %}
Because the ping carries no value, `msg.value` is useless for recognizing ERC20 revenue. The vault must instead compare its **current quote balance** against a stored baseline — see the accounting model below.
{% endhint %}

#### Normative accounting model

Since a ping never carries an amount, a V3 vault must track revenue by **balance-delta accounting**: compare the vault's current quote-token balance against a stored baseline, and treat any increase as newly-recognized revenue.

```solidity
uint256 public accountedQuote; // recognized-and-not-yet-spent revenue

receive() external payable { _syncRevenue(); }

function _syncRevenue() internal {
    address quoteToken = vaultQuoteToken();
    uint256 bal = quoteToken == address(0)
        ? address(this).balance
        : IERC20(quoteToken).balanceOf(address(this));
    if (bal <= accountedQuote) return;            // rule 2: idempotent no-op
    uint256 newRevenue = bal - accountedQuote;
    accountedQuote = bal;                          // rule 1: advance baseline
    _onRevenue(newRevenue);                        // lightweight only (ping law 3)
}
```

Rules:

1. **Recognize by delta, never by raw balance.** Crediting `balanceOf(this)` as "new revenue" double-counts everything already recognized. Only `balance - accountedQuote` is new.
2. **Zero-delta wakes are silent no-ops.** Required by ping law 4 above.
3. **Every outflow MUST decrement `accountedQuote`** by the amount spent, in the same transaction. Forgetting this leaves the baseline above the real balance, and `bal <= accountedQuote` then suppresses revenue recognition forever — the vault deadlocks. This is the single most dangerous mistake a V3 vault can make.
4. **Direct transfers are credited late, and that is fine.** Funds sent to the vault outside dispatch (donations, airdrops, misdirected transfers) trigger no ping; they are recognized on the next wake and are indistinguishable from revenue. Treat them as donations.
5. **Recognize before you act.** Any function whose behavior depends on available revenue — spending it, paying it out, or gating on it — **must** run the sync routine first, so its outcome never depends on whether a ping happened to arrive beforehand. Exposing a permissionless `sync()` wrapper is **recommended**: it is the neutral, side-effect-free recognition entry point for keepers and UIs, and the recovery path when revenue arrives without a wake call (direct transfers, or pings administratively disabled on the processor).

{% hint style="danger" %}
Rule 3 is the most common way a V3 vault breaks in production. If an outflow function forgets to decrement `accountedQuote`, the baseline permanently exceeds the real balance and the vault stops recognizing new revenue forever — with no error, no revert, just silent deadlock.
{% endhint %}

#### Implementing a V3 vault — checklist

1. **Inherit from `VaultBaseV3`.** All obligations from `VaultBase` and `VaultBaseV2` still apply (implement `description()` and `vaultUISchema()`, use `_getPortal()` / `_getGuardian()`, honor the Guardian mandate).
2. **Override `vaultQuoteToken()`** to return the revenue currency this vault instance accounts for — `address(0)` for the native gas token, the ERC20 address otherwise. It **must** equal the quote token of the tax token this vault serves, **must** be immutable for the life of the vault (set it once at initialization from the factory's `newVault` parameters), and **must not** revert. VaultPortal cross-checks it at launch; lenses and UIs read it to label the vault and to warn when a vault is wired to a token with a different quote.
3. **Implement `receive()` with the balance-delta accounting model above.** This is required even if your quote is an ERC20 — the wake call lands there.
4. **Keep `vaultSpecVersion()` at the default** (`"v3"`) unless a later spec revision instructs otherwise.
5. **On the factory side** (see [`VaultFactoryBaseV2`](#ivaultfactory--vaultfactorybasev2-current-interface) below):
   * `isQuoteTokenSupported(quote)` **must** answer truthfully for your vault implementation. This is enforced on-chain at launch — the VaultPortal rejects any launch whose quote your factory does not support. Misdeclaring support strands your users' tax revenue in a vault that ignores it.
   * `factorySpecVersion()` **must** return `"v2.3"` (or higher) so the VaultPortal applies the V3 validation flow.
   * `newVault(taxToken, quoteToken, creator, vaultData)` receives the launch quote token — pass it into your vault's initializer.
   * Creation-time first buys in an ERC20 quote are funded by the launcher, not the vault: the VaultPortal pulls `quoteAmt` from the launching user (via an EIP-2612 permit signed with the VaultPortal as spender, or a prior approval) and refunds any partial fill. Frontends integrating your factory should request that approval or permit; the vault itself plays no part in launch funding.

{% hint style="success" %}
See [`VaultBaseV3`](https://github.com/flap-sh/FlapVaultExample/blob/main/src/flap/VaultBaseV3.sol) in the `FlapVaultExample` repository for the full NatSpec (this is the normative spec) and [`FreeCoinV3Beacon.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/src/FreeCoinV3Beacon.sol) for a quote-agnostic reference implementation that handles native and ERC20 revenue through the same code path.
{% endhint %}

## VaultFactory Specification

A vault factory deploys vault instances for new tax tokens. When a user launches a token through the `VaultPortal`, the portal calls your factory's `newVault()` method to create the vault.

{% hint style="info" %}
**No registration required** — Any contract that implements `VaultFactoryBaseV2` can be passed to the VaultPortal to launch tokens. You do not need to register your factory on-chain.
{% endhint %}

### IVaultFactory / VaultFactoryBaseV2 (current interface)

This is the complete, current factory interface, pulled directly from [`FlapVaultExample`](https://github.com/flap-sh/FlapVaultExample/blob/main/src/flap/VaultFactoryBaseV2.sol) — including the current per-chain VaultPortal and Guardian addresses (BNB mainnet, BNB testnet, and **Robinhood Chain**). **We recommend all new factories override `factorySpecVersion()` to return `"v2.3"`** (not the `"v2.2"` shown as the abstract base's default below) and implement `IVaultFactoryDividendV23` — see [Spec version discovery](#spec-version-discovery--factoryspecversion) below:

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

/// @title IVaultFactory
/// @notice Interface that all vault factory contracts must implement
interface IVaultFactory {
    error OnlyVaultPortal();
    error ZeroAddress();

    /// @notice Creates a new vault instance for a tax token
    /// @dev IMPORTANT: The taxToken does not exist yet when this method is called.
    ///      The VaultPortal predicts the token address and passes it here.
    ///      The actual token will be created AFTER the vault is created.
    /// @param taxToken The predicted address of the tax token (not yet deployed)
    /// @param quoteToken The quote token address (e.g., address(0) for native BNB)
    /// @param creator The original msg.sender to VaultPortal who initiated token creation
    /// @param vaultData Custom encoded data specific to this vault type
    /// @return vault The address of the newly created vault
    function newVault(address taxToken, address quoteToken, address creator, bytes calldata vaultData)
        external
        returns (address vault);

    /// @notice Checks if a quote token is supported by this vault factory
    /// @param quoteToken The quote token address to check
    /// @return supported True if the quote token is supported, false otherwise
    function isQuoteTokenSupported(address quoteToken) external view returns (bool supported);
}

/// @title IVaultFactoryValidationV2
/// @notice Wrapper-agnostic pre-launch validation hook (spec v2.2+).
interface IVaultFactoryValidationV2 {
    /// @notice Normalized launch payload used by VaultPortal when talking to v2.2+ factories.
    struct LaunchValidationDataV1 {
        IPortalTypes.TokenVersion tokenVersion;
        address quoteToken;
        uint16 buyTaxRate;
        uint16 sellTaxRate;
        uint16 vaultBps;
        uint16 deflationBps;
        uint16 dividendBps;
        uint16 lpBps;
        address dividendToken;
        uint256 minimumShareBalance;
    }

    /// @notice Generic pre-launch validation hook.
    /// @param validationData ABI-encoded normalized launch payload.
    /// @return success True when the launch satisfies this factory's product constraints.
    /// @return reason Human-readable explanation when `success` is false.
    function onBeforeLaunch(bytes calldata validationData) external view returns (bool success, string memory reason);
}

/// @title IVaultFactoryDividendV23
/// @notice Optional factory-spec v2.3 extension for computed dividend-token resolution.
/// @dev    Only factories that explicitly opt into v2.3 need to implement this interface.
interface IVaultFactoryDividendV23 {
    /// @notice Resolve the dividend token for a predicted (not yet deployed) tax token.
    /// @dev    VaultPortal calls this only when the launcher supplied MAGIC_DIVIDEND_COMPUTED.
    /// @param predictedToken The CREATE2-predicted tax-token address.
    /// @param launchVersion `DIVIDEND_TOKEN_LAUNCH_VERSION_V6` or `DIVIDEND_TOKEN_LAUNCH_VERSION_V7`.
    /// @param launchParams ABI-encoded `NewTokenV6WithVaultParams` or `NewTokenV7WithVaultParams`.
    /// @return dividendToken The actual dividend token to forward into Portal.
    function resolveDividendToken(address predictedToken, uint8 launchVersion, bytes calldata launchParams)
        external
        view
        returns (address dividendToken);
}

/// @title VaultFactoryBaseV2
/// @author The Flap Team
/// @notice Extended abstract base contract for vault factory implementations that adds:
///           1. On-chain UI schema discovery via `vaultDataSchema()`
///           2. A `_getGuardian()` / `_getVaultPortal()` helper (mirrors VaultBase's pattern)
///           3. Policy discovery via `tokenCreationPolicies()`
///           4. `factorySpecVersion()` to identify the spec revision (default `"v2.2"`)
///           5. `onBeforeLaunch(bytes)` for wrapper-agnostic pre-launch validation
abstract contract VaultFactoryBaseV2 is IVaultFactory, IVaultFactoryValidationV2 {
    error UnsupportedChain(uint256 chainId);
    error LegacyV6ValidationHookNotImplemented();

    /// @notice Returns the schema describing the `vaultData` bytes expected by `newVault()`.
    /// @dev Each factory implementation **must** override this. See the UI Schema Reference
    ///      section for the full `VaultDataSchema` struct definition.
    function vaultDataSchema() public pure virtual returns (VaultDataSchema memory schema);

    /// @notice Deprecated legacy hook, kept only for factories that intentionally stay on the
    ///         legacy v2.1 validation surface. Reverts by default — see the Appendix for details.
    function onBeforeNewTokenV6WithVault(IVaultPortalTypes.NewTokenV6WithVaultParams calldata params)
        external
        virtual
        returns (bool, string memory)
    {
        params = params;
        revert LegacyV6ValidationHookNotImplemented();
    }

    /// @notice Wrapper-agnostic pre-launch validation hook (spec v2.2+). Default implementation
    ///         decodes the normalized payload and forwards it to `_validateBeforeLaunch(...)`.
    function onBeforeLaunch(bytes calldata validationData)
        external
        view
        virtual
        override
        returns (bool success, string memory reason)
    {
        IVaultFactoryValidationV2.LaunchValidationDataV1 memory data =
            abi.decode(validationData, (IVaultFactoryValidationV2.LaunchValidationDataV1));
        return _validateBeforeLaunch(data);
    }

    /// @notice Internal validation hook for spec-v2.2+ factories. Override this, not
    ///         `onBeforeLaunch` directly, to enforce your factory's product rules.
    function _validateBeforeLaunch(IVaultFactoryValidationV2.LaunchValidationDataV1 memory data)
        internal
        view
        virtual
        returns (bool success, string memory reason)
    {
        data = data;
        return (true, "");
    }

    /// @notice Returns the version of the VaultFactoryBaseV2 specification this contract
    ///         conforms to. Defaults to `"v2.2"` for backwards compatibility, but new
    ///         factories should override this to return `"v2.3"` — required to opt into
    ///         computed dividend tokens (also requires implementing `IVaultFactoryDividendV23`)
    ///         and to opt into ERC20 quote token support for `VaultBaseV3` vaults. Override to
    ///         `"v2.1"` only to intentionally stay on the legacy V6-only validation path.
    function factorySpecVersion() public pure virtual returns (string memory) {
        return "v2.2";
    }

    /// @notice Returns machine-readable UI hints describing the constraints this factory
    ///         enforces. Informational only — see the Policy Discovery section below.
    function tokenCreationPolicies() public pure virtual returns (FactoryPolicy[] memory policies) {
        return new FactoryPolicy[](0);
    }

    /// @notice Get the VaultPortal address for the current chain.
    /// @dev Currently supports BNB Chain (56), BNB Testnet (97), and Robinhood Chain (4663).
    function _getVaultPortal() internal view returns (address vaultPortal) {
        uint256 chainId = block.chainid;
        if (chainId == 56) {
            return 0x90497450f2a706f1951b5bdda52B4E5d16f34C06;
        } else if (chainId == 97) {
            return 0x027e3704fC5C16522e9393d04C60A3ac5c0d775f;
        } else if (chainId == 4663) {
            // Robinhood Chain — VaultPortal address
            return 0xe9F7AB7DE8FB8756acbB6a1cd13316a43308197B;
        }
        revert UnsupportedChain(chainId);
    }

    /// @notice Get the Guardian address for the current chain.
    /// @dev Currently supports BNB Chain (56), BNB Testnet (97), and Robinhood Chain (4663).
    function _getGuardian() internal view returns (address guardian) {
        uint256 chainId = block.chainid;
        if (chainId == 56) {
            return 0x9e27098dcD8844bcc6287a557E0b4D09C86B8a4b;
        } else if (chainId == 97) {
            return 0x76Fa8C526f8Bc27ba6958B76DeEf92a0dbE46950;
        } else if (chainId == 4663) {
            // Robinhood Chain Guardian address
            return 0x0000b48720d3B4ED6BC5031768B07F2b59270000;
        }
        revert UnsupportedChain(chainId);
    }
}
```

**Implementation requirements:**

* Implement `newVault()` and `isQuoteTokenSupported()` (from `IVaultFactory`).
* Override `vaultDataSchema()` to describe the fields your factory expects in `vaultData`. See the [UI Schema Reference](#ui-schema-reference-ivaultschemasv1) section.
* Override `_validateBeforeLaunch(...)` (not `onBeforeLaunch` directly) to enforce your factory's product rules.
* If your factory (or the vaults it creates) exposes any privileged / role-gated functions, the Guardian **must** also be granted the required role(s) — see the [Flap Guardian](#the-flap-guardian) mandate above; the same rule applies to factories.

### Generic validation hook — `onBeforeLaunch(bytes)`

`VaultPortal` normalizes launch parameters from whichever entrypoint the user called (`newTokenV6WithVault`, `newTokenV7WithVault`, ...) into the shared `LaunchValidationDataV1` payload and calls `onBeforeLaunch(bytes)` via `staticcall`. In most cases you should override `_validateBeforeLaunch(...)`, not `onBeforeLaunch` directly — the default `onBeforeLaunch` already handles decoding.

**Return value contract:**

| Outcome                             | Meaning                                                      | VaultPortal action                              |
| ----------------------------------- | ------------------------------------------------------------ | ----------------------------------------------- |
| Returns `(true, "")`                | Params are accepted                                          | Continue with token creation                    |
| Returns `(false, reason)`           | Params rejected                                              | Revert with `reason`                            |
| Reverts with error data             | Unexpected validation error                                  | Bubble up the revert                            |
| Selector missing / empty returndata | Factory claimed v2.2+ but does not expose the hook correctly | Revert with `"Factory validation hook missing"` |

{% hint style="info" %}
`onBeforeLaunch(bytes)` is **read-only**. It is called via `staticcall`, so it should only inspect inputs and return pass/fail + reason. Any stateful setup still belongs in `newVault()`.
{% endhint %}

**Concrete example — `GiftV4VaultFactoryV2`** (from the current `FlapTaxVaults` repo) enforces:

```solidity
function _validateBeforeLaunch(LaunchValidationDataV1 memory data)
    internal
    pure
    override
    returns (bool success, string memory reason)
{
    if (data.tokenVersion != IPortalTypes.TokenVersion.TOKEN_V3_PERMIT) {
        return (false, "Gift V4 requires TOKEN_V3_PERMIT.");
    }
    if (data.quoteToken != address(0)) {
        return (false, "Gift V4 currently supports native BNB only.");
    }
    if (data.dividendBps != 0) {
        return (false, "Use tracker-only dividend mode. The vault decides when to deposit rewards.");
    }
    if (data.dividendToken != address(0)) {
        return (false, "Dividend claims should be paid in native BNB (wrapped internally by the Dividend contract).");
    }
    if (data.buyTaxRate != 0 || data.sellTaxRate != 0) {
        return (false, "Gift V4 requires buyTaxRate = sellTaxRate = 0%.");
    }
    return (true, "");
}
```

### Spec version discovery — `factorySpecVersion()`

`factorySpecVersion()` tells `VaultPortal` which validation generation the factory belongs to:

* `v2.2`, `v2.3`, `v3.0`, etc. → use the generic `onBeforeLaunch(bytes)` path
* `v2.1` and below → treat as legacy / probe `onBeforeNewTokenV6WithVault(...)`
* missing / reverting selector → probe for the legacy V6 hook directly

The parser uses **major/minor semantics**, so anything `v2.2+` counts as part of the normalized pre-launch validation generation.

{% hint style="success" %}
**Recommendation: return `"v2.3"`, not `"v2.2"`, for all new factories.** Beyond the generic `onBeforeLaunch(bytes)` path shared by both, `"v2.3"` is required if you ever want to support computed dividend tokens or launch `VaultBaseV3` vaults with an ERC20 quote token — both are gated on `factorySpecVersion() >= "v2.3"`. There is no downside to declaring `"v2.3"` even if your factory doesn't use either feature today; implementing `IVaultFactoryDividendV23` itself remains optional.
{% endhint %}

{% hint style="warning" %}
Do not return a version string unless your factory actually supports the corresponding path. If `VaultPortal` detects `v2.2+`, it will call `onBeforeLaunch(bytes)` and expect a valid `(bool,string)` response. If it detects `v2.3+`, it may also call `resolveDividendToken(...)` — see below.
{% endhint %}

### Policy discovery — `tokenCreationPolicies()`

Policies are **machine-readable UI hints** that mirror whichever validation hook the factory actually uses — they let the UI show inline validation before a transaction is sent, but they enforce nothing on-chain by themselves.

```solidity
function tokenCreationPolicies() public pure virtual returns (FactoryPolicy[] memory policies) {
    return new FactoryPolicy[](0);
}
```

**`FactoryPolicy` struct:**

```solidity
struct FactoryPolicy {
    string target;      // Field name in normalized launch params (e.g. "dividendToken")
    string operator;    // Comparison operator (see table below)
    bytes  value;       // ABI-encoded expected value
    string description; // Human-readable hint shown in the UI
}
```

**Supported operators:**

| Operator  | Meaning                                        |
| --------- | ---------------------------------------------- |
| `"eq"`    | Field must equal `value`                       |
| `"neq"`   | Field must not equal `value`                   |
| `"gt"`    | Field must be strictly greater than `value`    |
| `"gte"`   | Field must be ≥ `value`                        |
| `"lt"`    | Field must be strictly less than `value`       |
| `"lte"`   | Field must be ≤ `value`                        |
| `"in"`    | Field must be one of a set (ABI-encoded array) |
| `"notIn"` | Field must not be any of a set                 |

Unknown operators must be **ignored** by the UI (forward-compatible).

**Worked example:**

```solidity
function tokenCreationPolicies() public pure returns (FactoryPolicy[] memory policies) {
    policies = new FactoryPolicy[](2);

    // dividendToken must equal a specific address (WBNB)
    policies[0] = FactoryPolicy({
        target:      "dividendToken",
        operator:    "eq",
        value:       abi.encode(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)),
        description: "Dividend token must equal the quote token (WBNB)."
    });

    // dividendBps must be at least 100 (1%)
    policies[1] = FactoryPolicy({
        target:      "dividendBps",
        operator:    "gte",
        value:       abi.encode(uint256(100)),
        description: "Dividend BPS must be at least 100 (1%) for this vault type."
    });
}
```

{% hint style="warning" %}
Policies are **informational only**. Always implement the actual enforcement in `_validateBeforeLaunch(...)`. Policies without a corresponding validation check have no effect on-chain.
{% endhint %}

### v2.3: Computed dividend tokens — `resolveDividendToken`

Factory spec **v2.3** adds support for a **computed dividend token** — a dividend token whose address cannot be known before the tax token is deployed, such as a Uniswap/PancakeSwap LP pair or a child token deployed deterministically from the tax token address.

At launch time, the caller passes the sentinel value `MAGIC_DIVIDEND_COMPUTED` as `dividendToken`. `VaultPortal` then checks that the factory declares `factorySpecVersion() >= "v2.3"`, calls `resolveDividendToken(predictedToken, launchVersion, launchParams)` on the factory, and substitutes the returned address as the real `dividendToken` before forwarding to Portal.

This is a fully optional, opt-in extension — factories that don't need computed dividend tokens can ignore `resolveDividendToken`/`IVaultFactoryDividendV23` entirely. However, **we still recommend declaring `factorySpecVersion() = "v2.3"`** (rather than staying on `"v2.2"`) even if you don't need computed dividend tokens, because `factorySpecVersion() >= "v2.3"` is also the gate `VaultPortal` checks before allowing a factory to launch `VaultBaseV3` vaults with an ERC20 quote token — see [VaultBaseV3 — ERC20 quote token support](#vaultbasev3--erc20-quote-token-support) above. See [Using an LP Token or Child Token as the Dividend Token](/flap/developers/vault-developers/tutorials/lp-token-as-dividend.md) for the full implementation guide, including the `IVaultFactoryDividendV23` interface, worked examples for LP-pair and child-token resolution, the on-chain flow diagram, and the version-gating table.

### Recommended commission fee structure

Vault factories can charge a commission fee from the tax revenue. The fee structure must be clearly described in the vault's `description()` method. The recommended fee calculation is based on the tax rate (`taxRateBps`) and the received tax revenue (`msg.value`):

* If `taxRate` ≤ 1% (100 bps), the fee is **6%** of `msg.value`.
* If `taxRate` > 1%, the fee is `(msg.value * 6) / taxRateBps`.

```solidity
receive() external payable {
    if (msg.value == 0) return;

    if (taxRateBps == 0) {
        try ITaxToken(taxToken).taxRate() returns (uint256 _taxRate) {
            if (_taxRate > 0) {
                taxRateBps = _taxRate;
            }
        } catch {}
    }

    uint256 fee = 0;
    if (taxRateBps <= 100) {
        // 6% of msg.value if taxRate <= 1%
        fee = msg.value * 600 / 10000;
    } else {
        // Examples:
        //   1% (100 bps)  → 6%
        //   2% (200 bps)  → 3%
        //   3% (300 bps)  → 2%
        //  10% (1000 bps) → 0.6%
        fee = (msg.value * 6) / taxRateBps;
    }

    // your main logic — accumulate fee or send fee
}
```

## UI Schema Reference (IVaultSchemasV1)

The shared struct definitions in `IVaultSchemasV1.sol` power the automatic UI generation for both vault factories (token launch forms) and vaults (vault interaction pages). This is the complete, current file:

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

/// @notice Describes a single field (parameter, return value, or vault-data component).
/// @param name        Machine-readable name, e.g. "recipient", "bps", "amount".
/// @param fieldType   Solidity ABI type string, e.g. "string", "address", "uint256".
///                    The special value "time" is an alias for "uint256" whose encoded value
///                    is a Unix timestamp in seconds; the UI renders a date/time picker for
///                    inputs and a human-readable time string / countdown for outputs.
///                    The special value "msg.value" indicates the field is the native
///                    currency amount (wei) sent with the transaction — NOT ABI-encoded into
///                    calldata. Only valid for write-method inputs; at most one per method.
/// @param description Human-readable explanation shown as a label or tooltip.
/// @param decimals    Decimal precision hint for numeric fields. For factory encoding
///                    (inputs), the UI multiplies user input by 10^decimals before
///                    ABI-encoding. For vault display (outputs), the UI divides the raw
///                    on-chain value by 10^decimals for display. Always 0 for non-numeric
///                    fields.
struct FieldDescriptor {
    string name;
    string fieldType;
    string description;
    uint8 decimals;
}

/// @notice Describes the shape of the `vaultData` bytes expected by a factory's `newVault()`.
/// @dev    Supports two shapes: a single tuple (`isArray == false`) or an array of tuples
///         (`isArray == true`). If `fields` is empty and `isArray` is false, the factory
///         ignores `vaultData` entirely.
struct VaultDataSchema {
    string description;
    FieldDescriptor[] fields;
    bool isArray;
}

/// @notice An ERC-20 `approve` action the UI must execute before calling a write method.
/// @dev    The spender is always the vault contract itself. Known `tokenType` values:
///         "taxToken" (resolved via vault.taxToken()), "lpToken" (via vault.lpToken()).
///         The UI MUST ignore any `tokenType` it does not recognize (forward-compatible).
struct ApproveAction {
    string tokenType;
    string amountFieldName;
}

/// @notice Describes a single view or write method the UI should render for a vault.
/// @param name          Solidity method name, e.g. "claim", "stats", "dispatch".
/// @param description   Human-readable explanation, shown as subtitle/tooltip.
/// @param inputs        Ordered input parameters. Empty for no-arg methods.
/// @param outputs       Ordered return values. Empty for write methods.
/// @param approvals     ERC-20 approvals the UI must execute before sending a write tx.
/// @param isInputArray  True if the method's input is tuple[].
/// @param isOutputArray True if the method's return value is tuple[].
/// @param isWriteMethod True = state-changing (send tx); false = view (display result).
struct VaultMethodSchema {
    string name;
    string description;
    FieldDescriptor[] inputs;
    FieldDescriptor[] outputs;
    ApproveAction[] approvals;
    bool isInputArray;
    bool isOutputArray;
    bool isWriteMethod;
}

/// @notice Top-level schema describing the vault's entire UI surface. Returned by
///         `VaultBaseV2.vaultUISchema()`.
/// @param vaultType    Human-readable vault type identifier, e.g. "FlapXVault", "SplitVault".
/// @param description  Overall explanation of the vault for the UI.
/// @param methods      All methods the UI should render, in display order.
struct VaultUISchema {
    string vaultType;
    string description;
    VaultMethodSchema[] methods;
}

/// @notice A single constraint the factory enforces on the normalized launch validation
///         payload. Inspired by AWS IAM policy conditions — informational only, see
///         "Policy discovery" above for the operator table and enforcement rules.
/// @param target      Field name in the normalized launch params, e.g. "dividendToken".
/// @param operator    "eq" | "neq" | "gt" | "gte" | "lt" | "lte" | "in" | "notIn".
/// @param value       ABI-encoded expected value (type inferred from `target`).
/// @param description Human-readable hint shown in the UI.
struct FactoryPolicy {
    string target;
    string operator;
    bytes value;
    string description;
}
```

**How the UI uses `VaultDataSchema` (factory side):**

1. UI calls `factory.vaultDataSchema()` to get the schema.
2. For each field in `fields`, render the appropriate input widget based on `fieldType` (`"string"` → text, `"address"` → address input with checksum, `"uint16"`/`"uint256"`/`"uint128"` → number input, `"bool"` → checkbox, `"bytes"`/`"bytes32"` → hex input, `"time"` → date/time picker).
3. If `isArray == true`, render an "Add Item" button for dynamic array entries.
4. Encode the user input: `abi.encode(tuple[])` if `isArray`, else `abi.encode(tuple)`. Pass the result as `vaultData` in `NewTaxTokenWithVaultParams`.

**Example — Single tuple schema:**

```solidity
function vaultDataSchema() public pure override returns (VaultDataSchema memory schema) {
    schema.description = "Creates a staking vault. Specify a reward rate and lock duration.";
    schema.fields = new FieldDescriptor[](2);
    schema.fields[0] = FieldDescriptor("rewardRateBps", "uint16", "Annual reward rate in basis points", 0);
    schema.fields[1] = FieldDescriptor("lockDuration", "uint256", "Lock duration in seconds", 0);
    schema.isArray = false;
}
```

**Example — Array of tuples schema:**

```solidity
function vaultDataSchema() public pure override returns (VaultDataSchema memory schema) {
    schema.description = "Creates a vault that distributes received BNB "
        "among a dynamic set of payees by basis-point shares.";
    schema.fields = new FieldDescriptor[](2);
    schema.fields[0] = FieldDescriptor("payee", "address", "Payee wallet address", 0);
    schema.fields[1] = FieldDescriptor("bps", "uint16", "Basis points share (10000 = 100%)", 0);
    schema.isArray = true;  // vaultData = abi.encode((address,uint16)[])
}
```

**Example — Factory that ignores vaultData:**

```solidity
function vaultDataSchema() public pure override returns (VaultDataSchema memory schema) {
    schema.description = "Creates a vault with no configurable parameters. "
        "No user input is required — vaultData is ignored.";
    schema.fields = new FieldDescriptor[](0);
    schema.isArray = false;
}
```

**How the UI uses `VaultUISchema` (vault side):**

1. Display `vaultType` as a badge/header and `description` as subtitle.
2. Always call `vault.description()` and display the result as a dynamic status banner (polled periodically).
3. For each method: **view methods** (`isWriteMethod == false`) call immediately if no inputs, otherwise render input fields with a "Query" button. **Write methods** render a form with inputs; if `approvals` is non-empty, execute each `ApproveAction` (resolve token via `tokenType`, check allowance, call `approve` if needed) before sending the write transaction.
4. Methods are displayed in the order returned.

**Example — Hypothetical DonationVault:**

```solidity
function vaultUISchema() public pure override returns (VaultUISchema memory schema) {
    schema.vaultType = "DonationVault";
    schema.description = "Collects BNB donations and lets a designated charity withdraw.";
    schema.methods = new VaultMethodSchema[](3);

    // View: totalDonated() — no inputs, one uint256 output
    schema.methods[0].name        = "totalDonated";
    schema.methods[0].description = "Returns the total BNB donated so far.";
    schema.methods[0].outputs     = new FieldDescriptor[](1);
    schema.methods[0].outputs[0]  = FieldDescriptor("total", "uint256", "Total BNB donated", 18);
    schema.methods[0].approvals   = new ApproveAction[](0);

    // Write: donate() — msg.value input
    // fieldType "msg.value": the UI sets tx.value on the transaction instead of
    // ABI-encoding the amount as a calldata parameter. Only valid on write methods.
    schema.methods[1].name          = "donate";
    schema.methods[1].description   = "Send BNB as a donation.";
    schema.methods[1].inputs        = new FieldDescriptor[](1);
    schema.methods[1].inputs[0]     = FieldDescriptor("amount", "msg.value", "BNB to donate", 18);
    schema.methods[1].outputs       = new FieldDescriptor[](0);
    schema.methods[1].approvals     = new ApproveAction[](0);
    schema.methods[1].isWriteMethod = true;

    // Write: withdraw() — no inputs
    schema.methods[2].name          = "withdraw";
    schema.methods[2].description   = "Withdraws accumulated donations to the charity address.";
    schema.methods[2].inputs        = new FieldDescriptor[](0);
    schema.methods[2].outputs       = new FieldDescriptor[](0);
    schema.methods[2].approvals     = new ApproveAction[](0);
    schema.methods[2].isWriteMethod = true;
}
```

**Example — StakingVault with approve actions:**

```solidity
function vaultUISchema() public pure override returns (VaultUISchema memory schema) {
    schema.vaultType = "StakingVault";
    schema.description = "Stakes tax tokens or LP tokens to earn rewards.";
    schema.methods = new VaultMethodSchema[](2);

    // View: stakedBalance(address)
    schema.methods[0].name = "stakedBalance";
    schema.methods[0].description = "Returns the staked balance for a given user.";
    schema.methods[0].inputs = new FieldDescriptor[](1);
    schema.methods[0].inputs[0] = FieldDescriptor("user", "address", "The user address to query", 0);
    schema.methods[0].outputs = new FieldDescriptor[](1);
    schema.methods[0].outputs[0] = FieldDescriptor("balance", "uint256", "Staked token balance", 18);

    // Write: deposit(uint256) — requires ERC-20 approval of the tax token
    schema.methods[1].name = "deposit";
    schema.methods[1].description = "Stake tax tokens into the vault to earn rewards.";
    schema.methods[1].inputs = new FieldDescriptor[](1);
    schema.methods[1].inputs[0] = FieldDescriptor("amount", "uint256", "Amount of tax tokens to stake", 18);
    schema.methods[1].approvals = new ApproveAction[](1);
    schema.methods[1].approvals[0] = ApproveAction("taxToken", "amount");
    schema.methods[1].isWriteMethod = true;
}
```

**Example — NoteVault (string input, paginated array output):**

```solidity
function vaultUISchema() public pure override returns (VaultUISchema memory schema) {
    schema.vaultType   = "NoteVault";
    schema.description = "A public on-chain diary. Anyone can submit a note with an optional BNB tip. "
                         "All entries are stored on-chain and readable page-by-page.";

    schema.methods = new VaultMethodSchema[](3);

    // View: noteCount() — no inputs, plain uint256 output (raw count, decimals = 0)
    schema.methods[0].name        = "noteCount";
    schema.methods[0].description = "Total number of notes submitted.";
    schema.methods[0].inputs      = new FieldDescriptor[](0);
    schema.methods[0].outputs     = new FieldDescriptor[](1);
    schema.methods[0].outputs[0]  = FieldDescriptor("count", "uint256", "Total notes", 0);
    schema.methods[0].approvals   = new ApproveAction[](0);

    // View: getNotes(uint256 offset, uint256 limit) — paginated, returns Note[]
    // isOutputArray = true: outputs describe the fields of *each tuple* in the returned array,
    // not a single return value. The UI renders a table with one row per Note.
    schema.methods[1].name           = "getNotes";
    schema.methods[1].description    = "Fetch a page of notes. Use offset + limit to paginate.";
    schema.methods[1].inputs         = new FieldDescriptor[](2);
    schema.methods[1].inputs[0]      = FieldDescriptor("offset", "uint256", "Start index (0-based)", 0);
    schema.methods[1].inputs[1]      = FieldDescriptor("limit",  "uint256", "Max items to return",   0);
    schema.methods[1].outputs        = new FieldDescriptor[](3);
    schema.methods[1].outputs[0]     = FieldDescriptor("author",    "address", "Author address", 0);
    schema.methods[1].outputs[1]     = FieldDescriptor("createdAt", "time",    "Submitted at",   0);
    schema.methods[1].outputs[2]     = FieldDescriptor("content",   "string",  "Note content",   0);
    schema.methods[1].isOutputArray  = true;   // ← output is Note[], not a single tuple
    schema.methods[1].approvals      = new ApproveAction[](0);

    // Write: submitNote(string content) — string input + optional msg.value tip
    schema.methods[2].name          = "submitNote";
    schema.methods[2].description   = "Submit a note. Attach a BNB tip (optional, set 0 to skip).";
    schema.methods[2].inputs        = new FieldDescriptor[](2);
    schema.methods[2].inputs[0]     = FieldDescriptor("content", "string",    "Note content",      0);
    schema.methods[2].inputs[1]     = FieldDescriptor("tip",     "msg.value", "Optional BNB tip", 18);
    schema.methods[2].outputs       = new FieldDescriptor[](0);
    schema.methods[2].approvals     = new ApproveAction[](0);
    schema.methods[2].isWriteMethod = true;
}
```

## Get your vault verified

{% hint style="info" %}
Getting your vault verified is **optional**. You can launch a token with your vault today without any audit or verification — see the [Quick start for Vault Developers](/flap/developers/vault-developers/quick-start-vault-developers.md) guide. Verification only matters if you want the **low-risk badge** shown on Flap's website and partner sites.
{% endhint %}

To get your vault or vault factory verified, you must **pass an audit from our partner audit company** (current cost: 0.5 BNB / 0.16 ETH per factory). Please reach out to our team to schedule this.

{% hint style="warning" %}
**The** [**beacon proxy pattern**](/flap/developers/vault-developers/case-study-beacon-upgradeable-vault.md) **is mandatory to get verified — it is not optional for the low-risk badge.** Flap must be able to actually fix any issue the audit finds, and the only way to do that without asking every token creator to migrate is upgrade authority behind a beacon, held by the Flap Guardian. A non-upgradeable vault/factory cannot be verified, full stop — see [Why the Beacon Proxy pattern matters](#why-the-beacon-proxy-pattern-matters) above for the full rationale.

This also means you don't need to complete the audit before launch: you can launch first on the beacon and pursue the audit afterwards. If the audit surfaces an issue, the vault is upgraded through the beacon to fix it — that upgrade path is precisely what Flap reserves the Guardian's authority for.
{% endhint %}

Before reaching out, make sure:

* You have correctly implemented the Vault Specification (the `description()` method, the Guardian access to permissioned functions, and `vaultUISchema()` / `vaultDataSchema()`).
* Your vault and factory contracts are deployed behind the beacon proxy pattern, with upgrade authority gated **exclusively** to the Flap Guardian. This is a **hard requirement for verification** — Flap reserves the right to upgrade the vault if the audit (or a later production issue) surfaces a bug, so that a fix can ship without asking every token creator to migrate. A non-upgradeable factory/vault, or one where upgrade authority sits with any address other than the Guardian, cannot be verified. If you need to change a non-beacon factory in the future, you must deploy a new factory contract and get it verified again.
* The commission fee structure is clearly described in the vault's `description()` method.

## Appendix: Older spec versions

The current interface (`VaultBaseV3` and `VaultFactoryBaseV2` targeting spec `v2.3`, documented above) is **fully backwards-compatible** with everything below. Existing vaults built against these older revisions continue to work unmodified — this section exists purely for historical reference. New vaults and factories should target `VaultBaseV3` and factory spec `v2.3`, documented earlier on this page, not these older revisions.

| Version | Vault base contract                   | Factory base contract                                        | Key addition                                                                                                                                                                               |
| ------- | ------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| V1      | `VaultBase`                           | `IVaultFactory`                                              | Core spec — `description()`, Guardian mandate                                                                                                                                              |
| V2      | `VaultBaseV2` (extends `VaultBase`)   | `VaultFactoryBaseV2` (implements `IVaultFactory`)            | On-chain UI schema for automatic UI generation                                                                                                                                             |
| V2.1    | *(no change)*                         | `VaultFactoryBaseV2` (updated)                               | Legacy V6 validation hook (`onBeforeNewTokenV6WithVault`) + machine-readable policy discovery                                                                                              |
| V2.2    | *(no change)*                         | `VaultFactoryBaseV2` (updated)                               | Wrapper-agnostic validation via `onBeforeLaunch(bytes)` and normalized launch payloads — this became the default                                                                           |
| V2.3    | *(no change)*                         | `VaultFactoryBaseV2` + `IVaultFactoryDividendV23` (optional) | Computed dividend tokens via `resolveDividendToken` — see [dedicated tutorial](/flap/developers/vault-developers/tutorials/lp-token-as-dividend.md)                                        |
| V3      | `VaultBaseV3` (extends `VaultBaseV2`) | `VaultFactoryBaseV2` (`factorySpecVersion() >= "v2.3"`)      | ERC20 quote token support via `vaultQuoteToken()` + the ping/balance-delta accounting model — see [VaultBaseV3 — ERC20 quote token support](#vaultbasev3--erc20-quote-token-support) above |

**V1 — `VaultBase` / `IVaultFactory`:** The original spec. Vaults implement `description()` and the Guardian mandate; factories implement `newVault()` and `isQuoteTokenSupported()`. No UI schema discovery — every new vault type needed a hand-built UI.

**V2.1 — legacy validation hook:** Before the wrapper-agnostic `onBeforeLaunch(bytes)` hook existed, factories that wanted to validate launch parameters had to override `onBeforeNewTokenV6WithVault(NewTokenV6WithVaultParams calldata params)`, called by `VaultPortal` only for V6-style launches:

```solidity
function onBeforeNewTokenV6WithVault(IVaultPortalTypes.NewTokenV6WithVaultParams calldata params)
    external
    virtual
    returns (bool success, string memory reason)
{
    revert LegacyV6ValidationHookNotImplemented();
}
```

`VaultPortal` interprets the low-level call result as: `(true, "")` → accept and continue; `(false, reason)` → revert with `reason`; revert with error data → propagate; selector missing / empty returndata → treat as "no legacy hook present". This path is still reachable today by overriding `factorySpecVersion()` to return `"v2.1"`, for factories that intentionally stay on the legacy V6-only validation surface instead of adopting `onBeforeLaunch(bytes)`.

**Migrating from V1 to the current spec:** extend `VaultBaseV2` / `VaultFactoryBaseV2` instead of `VaultBase` / `IVaultFactory` directly, then implement `vaultUISchema()` / `vaultDataSchema()`. No other changes are required — all V1 obligations still apply unchanged.
