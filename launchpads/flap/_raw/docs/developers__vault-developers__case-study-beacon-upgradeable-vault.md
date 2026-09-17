> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/vault-developers/case-study-beacon-upgradeable-vault.md).

# Building Upgradeable Vaults — Beacon Proxy Pattern

This guide explains how to build an upgradeable vault for the Flap protocol. The recommended pattern is **OpenZeppelin `BeaconProxy` + `UpgradeableBeacon`**, with the upgrade authority gated to the **Flap Guardian** for risk-control reasons.

The reference implementation lives in the [FlapVaultExample](https://github.com/flap-sh/FlapVaultExample) repository:

* Source: [`src/FreeCoinBeacon.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/src/FreeCoinBeacon.sol)
* Beacon-specific tests: [`test/FreeCoinBeacon.mainnet.t.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/test/FreeCoinBeacon.mainnet.t.sol)
* Bonding-curve and post-DEX dispatch tests (non-beacon variant, identical protocol surface): [`test/FreeCoin.mainnet.t.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/test/FreeCoin.mainnet.t.sol)
* Deployment scripts: [`script/mainnet/bnb/DeployFreeCoinBeacon.s.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/script/mainnet/bnb/DeployFreeCoinBeacon.s.sol), [`script/testnet/bnb/DeployFreeCoinBeacon.s.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/script/testnet/bnb/DeployFreeCoinBeacon.s.sol)

## Overview

For a new vault factory that will deploy more than a handful of vault instances, the recommended setup is:

1. Implement the vault as an **upgradeable implementation contract** with `_disableInitializers()` in the constructor and an `initialize(...)` function gated by the `initializer` modifier.
2. In the factory's constructor, deploy the implementation and an `UpgradeableBeacon` pointing at it. The factory becomes the beacon's owner.
3. In `newVault(...)`, deploy a `BeaconProxy` and pass `abi.encodeCall(YourVault.initialize, (...))` as the proxy's initialization calldata.
4. Expose `upgradeVaultImplementation(address)` and `lockVaultUpgrades()` on the factory, **gated to the Flap Guardian only**.
5. Cover bonding-curve dispatch, post-DEX dispatch, the Guardian-only upgrade path, and the irreversible lock with integration tests.

The rest of this guide walks through the rationale and the reference code.

## Why beacon proxies

For production vaults, deploy the vault implementation behind an **`UpgradeableBeacon`** and create one **`BeaconProxy`** per token. Compared with deploying many immutable vault instances:

1. **Operational flexibility** — if a bug or protocol change shows up after launch, upgrading a single beacon implementation rolls the fix out to every existing and future vault of this type. No redeployment, no migration ask of token creators.
2. **Cleaner factory design** — the factory ABI-encodes initialization data and hands it to a fresh `BeaconProxy`, rather than duplicating constructor logic into every deployment path.
3. **Consistent multi-vault upgrades** — one beacon coordinates upgrades across every vault instance of the same type.
4. **Smaller audit surface** — auditors and integrators reason about a single implementation contract plus a single beacon authority model.

If the vault is a one-instance-per-token, immutable-for-life design, inherit `VaultBaseV2` directly and skip the proxy. The beacon pattern in this guide is the default recommendation for **factories that deploy many vault instances**.

## Why upgrade authority stays with the Guardian

Once a vault is upgradeable, the implementation address becomes the highest-risk asset in the setup. Anyone who can swap it can drain the vault, rewrite its accounting, or break dispatch. Gating that authority exclusively to the Flap Guardian is a risk-control requirement:

* **Centralized incident response.** If a vulnerability is discovered post-launch — through monitoring, audit follow-up, or an incident on a sibling vault — the Guardian path enables an immediate fix without coordinating with each token creator.
* **Fewer privileged keys for vault developers to maintain.** No HSM, multisig, or deployer EOA needs to remain online for the lifetime of the token on the developer's side. The upgrade key cannot be lost or compromised by the vault developer.
* **Single trust assumption for users.** Users already trust the Flap protocol. A separate non-Guardian upgrade owner widens the trust surface without a corresponding benefit.
* **Optional irreversible immutability.** When the project is ready, the Guardian can call `lockVaultUpgrades()` to renounce beacon ownership permanently — making the immutability commitment on-chain and verifiable.

In practice this means: the factory must not retain a separate non-Guardian owner, proxy admin, beacon owner, upgrader role, deployer EOA, or external multisig with equivalent power. The factory should expose exactly two privileged entrypoints — `upgradeVaultImplementation` and `lockVaultUpgrades` — both gated to `_getGuardian()`.

{% hint style="warning" %}
A factory that keeps any additional upgrade authority alongside the Guardian will not pass Flap's verification. The risk-control posture described above relies on the Guardian being the only path that can swap the implementation.
{% endhint %}

## How to build it

### The implementation contract

The implementation is the logic contract that all `BeaconProxy` instances delegate to. It looks like a normal vault except for three upgradeable-pattern obligations:

```solidity
contract FreeCoinVaultUpgradeable is Initializable, VaultBaseV2, ReentrancyGuardUpgradeable {
    address public taxToken;
    uint256 public maxReward;
    uint256 public cooldown;
    // ...

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _taxToken, uint256 _maxReward, uint256 _cooldown) external initializer {
        __ReentrancyGuard_init();
        taxToken = _taxToken;
        maxReward = _maxReward;
        cooldown = _cooldown;
    }
```

Three things to check off:

* **`_disableInitializers()` in the constructor** — locks the bare implementation so nobody can call `initialize` on it directly. Only proxies pointing at it can be initialized.
* **`initialize(...)` replaces the constructor** — every freshly deployed `BeaconProxy` calls this exactly once with the configuration the factory chose. The `initializer` modifier (from OpenZeppelin's `Initializable`) makes the second call revert.
* **Use OpenZeppelin's upgradeable variants** — `ReentrancyGuardUpgradeable` instead of `ReentrancyGuard`, plus the matching `__*_init()` calls inside `initialize`.

The rest of the contract (`claim()`, `description()`, `vaultUISchema()`, etc.) is shaped exactly like a non-upgradeable vault. Full source is in [`src/FreeCoinBeacon.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/src/FreeCoinBeacon.sol).

### The beacon factory

The factory extends `VaultFactoryBaseV2` and owns the `UpgradeableBeacon` for this vault type:

```solidity
contract FreeCoinVaultBeaconFactory is VaultFactoryBaseV2 {
    address public immutable beacon;

    constructor() {
        FreeCoinVaultUpgradeable impl = new FreeCoinVaultUpgradeable();
        beacon = address(new UpgradeableBeacon(address(impl)));
    }

    function newVault(address taxToken, address /*quoteToken*/, address /*creator*/, bytes calldata vaultData)
        external
        override
        returns (address vault)
    {
        require(msg.sender == _getVaultPortal(), unicode"Only VaultPortal / 仅限 VaultPortal 调用");

        (uint256 maxReward, uint256 cooldown) = abi.decode(vaultData, (uint256, uint256));

        vault = address(
            new BeaconProxy(
                beacon,
                abi.encodeCall(FreeCoinVaultUpgradeable.initialize, (taxToken, maxReward, cooldown))
            )
        );
    }
```

What's happening:

1. **Constructor** deploys the implementation and an `UpgradeableBeacon` pointing at it. The factory becomes the beacon's owner — the only account that can later call `upgradeTo` on the underlying `Ownable` beacon.
2. **`newVault(...)`** is invoked by VaultPortal during token launch. It deploys a fresh `BeaconProxy`, passing `abi.encodeCall(initialize, (...))` as the proxy's initialization calldata. The proxy delegates to the beacon's current implementation.
3. **Quote-token whitelist** is enforced by `isQuoteTokenSupported` and the V2.2 validation hook `_validateBeforeLaunch` — this factory accepts native BNB only.

### Wiring the upgrade authority to the Guardian

Although the factory technically owns the beacon, the only externally callable upgrade path goes through Guardian-gated functions:

```solidity
function upgradeVaultImplementation(address newImplementation) external {
    require(msg.sender == _getGuardian(), unicode"Only Guardian / 仅限 Guardian");
    UpgradeableBeacon(beacon).upgradeTo(newImplementation);
}

function lockVaultUpgrades() external {
    require(msg.sender == _getGuardian(), unicode"Only Guardian / 仅限 Guardian");
    UpgradeableBeacon(beacon).renounceOwnership();
}

function isVaultUpgradesLocked() external view returns (bool locked) {
    locked = UpgradeableBeacon(beacon).owner() == address(0);
}
```

Two details worth highlighting:

* After `lockVaultUpgrades()`, the beacon's `owner()` is `address(0)`. From that point forward, **`upgradeTo` reverts at the beacon's own `onlyOwner` check** — even when the Guardian re-enters `upgradeVaultImplementation`, the call bottoms out in `Ownable: caller is not the owner`. The lock is on-chain irreversible.
* `isVaultUpgradesLocked()` derives from the beacon's owner, so it stays accurate even if the factory is later replaced or local tooling forgets state.

`_getGuardian()` is provided by `VaultFactoryBaseV2` and resolves to the Flap Guardian address per chain — the address does not need to be hardcoded. Any additional permissioned function added to the factory or vault later should be gated the same way.

### Deployment

Both reference scripts construct the factory; the implementation and beacon are deployed inline:

```solidity
// script/mainnet/bnb/DeployFreeCoinBeacon.s.sol
function run() external {
    vm.startBroadcast();
    FreeCoinVaultBeaconFactory factory = new FreeCoinVaultBeaconFactory();
    console.log("FreeCoinVaultBeaconFactory deployed at:", address(factory));
    console.log("UpgradeableBeacon deployed at:      ", factory.beacon());
    console.log("Beacon implementation deployed at:  ", factory.beaconImplementation());
    vm.stopBroadcast();
}
```

Run them with:

```bash
# Mainnet
forge script script/mainnet/bnb/DeployFreeCoinBeacon.s.sol:DeployFreeCoinBeacon \
    --rpc-url https://bsc-dataseed.bnbchain.org --broadcast --verify --private-key <KEY>

# Testnet
forge script script/testnet/bnb/DeployFreeCoinBeacon.s.sol:DeployFreeCoinBeacon \
    --rpc-url https://bsc-testnet-dataseed.bnbchain.org --broadcast --verify --private-key <KEY>
```

VaultPortal is permissionless, so the factory does not need to be registered anywhere after deployment. To clear the warning flag on Flap.sh, contact the Flap team to schedule the third-party audit.

## Required tests

For an upgradeable vault, the test surface is bigger than for a plain vault: alongside the usual logic and dispatch tests, the upgrade-authority model must be asserted directly.

The reference test file [`test/FreeCoinBeacon.mainnet.t.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/test/FreeCoinBeacon.mainnet.t.sol) covers the proxy / upgrade / lock surface. The bonding-curve and post-DEX dispatch tests are in [`test/FreeCoin.mainnet.t.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/test/FreeCoin.mainnet.t.sol) and apply unchanged here, because the integration surface is identical (same VaultPortal, same TaxProcessor dispatch).

Minimum coverage expected before audit:

| # | Scenario                                                                           | What to assert                                                                                                                                                                                 | Reference test                                                                                         |
| - | ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| 1 | **Registration** — factory deploys an initialized proxy when called by VaultPortal | `taxToken`, `maxReward`, `cooldown` set; non-VaultPortal callers rejected                                                                                                                      | `test_beaconFactoryDeploysInitializedProxyVault`, `test_factoryRejectsNonVaultPortalCaller`            |
| 2 | **Initializer is locked** — implementation cannot be re-initialized                | `initialize()` reverts on both proxy and bare implementation after first call                                                                                                                  | `test_beaconProxyClaimAndInitializerLock`                                                              |
| 3 | **Bonding-curve buy → dispatch → vault**                                           | Buy on BC, call `dispatch()`, assert vault BNB balance increased                                                                                                                               | `test_buyOnBCAndDispatch` (in `FreeCoin.mainnet.t.sol`)                                                |
| 4 | **DEX graduation → sell → dispatch → vault**                                       | Buy until graduation (`status == 4`), sell on DEX, dispatch, assert vault received BNB                                                                                                         | `test_graduateAndDispatchPostDEX` (in `FreeCoin.mainnet.t.sol`)                                        |
| 5 | **Guardian can upgrade the beacon**                                                | Non-Guardian callers revert; Guardian successfully changes `beaconImplementation()`                                                                                                            | `test_guardianCanUpgradeBeaconImplementation`, `test_nonGuardianCannotUpgradeBeaconImplementation`     |
| 6 | **Guardian can lock the beacon, and lock is irreversible**                         | After `lockVaultUpgrades()`, `isVaultUpgradesLocked() == true` and any further upgrade reverts at the beacon's `onlyOwner` check                                                               | `test_guardianCanLockVaultUpgrades`, `test_lockingIsIrreversibleAndIdempotentlyReverts`                |
| 7 | **Vault logic & gating**                                                           | Vault's own business rules (claim, cooldown, double-claim, failed transfer rollback, getters)                                                                                                  | `test_claimCooldownAndDoubleClaimReverts`, `test_claimRevertsWhenRecipientRejectsNativeTransfer`, etc. |
| 8 | **Schema sanity**                                                                  | `vaultUISchema()` and `vaultDataSchema()` return the shape the UI expects; `factorySpecVersion()` is `"v2.2"`; `onBeforeLaunch(bytes)` rejects non-native quote tokens with the correct reason | `test_vaultUISchemaMetadata`, `test_factoryMetadataAndValidationHelpers`                               |

### Why both bonding-curve and DEX tests are required

The vault's `receive()` is invoked indirectly through `TaxProcessor.dispatch()`. The dispatch pipeline behaves slightly differently in each phase:

* **Bonding curve.** Each buy or sell on Portal applies the buy or sell tax, accumulates BNB on the `TaxProcessor`, and `dispatch()` flushes it to the vault. Tests verify that dispatch reaches the vault and that `receive()` does not revert under that gas budget.
* **Post-DEX (graduated).** Once the bonding curve crosses the `FOUR_FIFTHS` threshold the token graduates to DEX. Sell-side tax is then collected through the token's own swap-and-distribute path, accumulated on the `TaxProcessor`, and dispatched. Tests verify that the same vault still receives BNB after graduation, since this is the path that runs for the entire post-launch lifetime of the token.

Both phases must be covered. A vault that handles bonding-curve dispatch correctly but reverts after DEX graduation is broken in production, and that bug is invisible without a graduation test.

A condensed sketch of the integration tests (full code in [`test/FreeCoin.mainnet.t.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/test/FreeCoin.mainnet.t.sol)):

```solidity
// 1. Bonding curve
function test_buyOnBCAndDispatch() public {
    uint256 vaultBefore = address(vault).balance;

    vm.startPrank(user1);
    _buyOnBC(token, 5 ether);
    vm.stopPrank();

    _dispatchTax(token);                // flush TaxProcessor → vault
    assertGt(address(vault).balance, vaultBefore);
}

// 2. Post-DEX
function test_graduateAndDispatchPostDEX() public {
    vm.startPrank(user1); _buyOnBC(token, 5 ether);  vm.stopPrank();
    _dispatchTax(token);
    vm.startPrank(user2); _buyOnBC(token, 15 ether); vm.stopPrank();
    // ...buy more if not yet graduated...
    assertEq(portal.getTokenV8Safe(token).status, 4, "should have graduated");

    uint256 vaultBefore = address(vault).balance;
    vm.startPrank(user1);
    require(IERC20(token).transfer(token, 400_000 * 1e18));   // seed liquidation threshold
    _sell(token, IERC20(token).balanceOf(user1) - 400_000 * 1e18);
    vm.stopPrank();

    _dispatchTax(token);
    assertGt(address(vault).balance, vaultBefore);
}
```

{% hint style="warning" %}
Always wrap multi-call helpers like `_sell()` and `_buyOnBC()` in `vm.startPrank(...)` / `vm.stopPrank()`. `vm.prank()` only covers the **next** external call, so the second internal call (e.g. `swapExactInput` after `approve`) silently runs as the wrong sender and produces confusing reverts. See the [FlapVaultExample README](https://github.com/flap-sh/FlapVaultExample#prank-convention-in-tests) for the full convention.
{% endhint %}

### Tests for the upgrade and lock authority

Excerpts from [`test/FreeCoinBeacon.mainnet.t.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/test/FreeCoinBeacon.mainnet.t.sol):

```solidity
function test_guardianCanUpgradeBeaconImplementation() public {
    FreeCoinVaultUpgradeable nextImplementation = new FreeCoinVaultUpgradeable();

    vm.prank(TESTNET_GUARDIAN);
    factory.upgradeVaultImplementation(address(nextImplementation));

    assertEq(factory.beaconImplementation(), address(nextImplementation));
}

function test_nonGuardianCannotUpgradeBeaconImplementation() public {
    FreeCoinVaultUpgradeable nextImplementation = new FreeCoinVaultUpgradeable();

    vm.expectRevert(bytes(unicode"Only Guardian / 仅限 Guardian"));
    vm.prank(USER);
    factory.upgradeVaultImplementation(address(nextImplementation));
}

function test_guardianCanLockVaultUpgrades() public {
    assertTrue(!factory.isVaultUpgradesLocked());

    vm.prank(TESTNET_GUARDIAN);
    factory.lockVaultUpgrades();
    assertTrue(factory.isVaultUpgradesLocked());

    // Further upgrades fail at the beacon's onlyOwner check, even when called by the Guardian
    FreeCoinVaultUpgradeable nextImplementation = new FreeCoinVaultUpgradeable();
    vm.expectRevert(bytes("Ownable: caller is not the owner"));
    vm.prank(TESTNET_GUARDIAN);
    factory.upgradeVaultImplementation(address(nextImplementation));
}
```

These three tests are the minimum set demonstrating that the authority model holds: the Guardian is the only path in, non-Guardian callers are rejected, and locking is genuinely irreversible.

## Pre-audit checklist

* [ ] Implementation calls `_disableInitializers()` in its constructor.
* [ ] `initialize(...)` is the only place that sets vault state, and it has the `initializer` modifier.
* [ ] Factory deploys the implementation and `UpgradeableBeacon` in its own constructor; the beacon owner is the factory itself.
* [ ] `upgradeVaultImplementation(address)` is gated to `_getGuardian()` — no other caller passes.
* [ ] `lockVaultUpgrades()` is gated to `_getGuardian()` and renounces beacon ownership.
* [ ] No other upgrade path exists on the factory (no admin EOA, no proxy admin, no extra owner, no parallel multisig).
* [ ] Tests assert: registration via VaultPortal, initializer lockdown, bonding-curve dispatch, post-DEX dispatch, Guardian upgrade success, non-Guardian upgrade rejection, lock irreversibility.
* [ ] All tests pass against a BSC fork (`forge test --fork-url https://bsc-dataseed.bnbchain.org`).
* [ ] The [`flap-vault-spec-checker`](https://github.com/flap-sh/FlapVaultExample/tree/main/.agents/skills/flap-vault-spec-checker) Copilot skill reports no ❌ findings.

Once those are green, contact the Flap team to schedule the third-party audit and clear the warning flag on Flap.sh. See the [Vault & VaultFactory specification](/flap/developers/vault-developers/vault-and-vaultfactory-specification.md#get-your-vault-verified) page for the verification process.
