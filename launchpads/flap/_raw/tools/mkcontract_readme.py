#!/usr/bin/env python3
"""Generate contracts/<dir>/README.md for the Flap archive.

Role text is curated in ROLES; everything else is read back out of the
Blockscout responses already on disk.
"""
import json, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "contracts")

# dir prefix -> (role headline, prose)
ROLES = {
"FlapCore": ("Portal, the protocol entry point (proxy)",
 """This is the contract the Flap docs and the app both call `Portal`.
The archive directory is named `FlapCore` from an earlier guess; the address is the one the Robinhood integration guide lists as `Portal (proxy)` and the one `robinhood-chain-config.js` sets as `portal`.

Everything a creator or a trader does goes through here: `newTokenV5` (non-tax launch), `newTokenV6` (tax launch), `swapExactInput` (buy and sell on the curve), `claim` (revenue share), `getTokenV8Safe` (token state), `getQuoteTokenConfiguration` (which quote assets are enabled).
It is a `TransparentUpgradeableProxy` over `PortalImpl-0xa3b96df56f254b926b17d5f7fb6cd858c216ff44`, which is **not verified**; the callable surface is recovered from a PUSH4 selector scan in that directory.

Live reads on 2026-09-02 (`_raw/rpc/portal-config.txt`):

| call | value |
| --- | --- |
| `version()` | `v5.21.2` |
| `getFeeRate()` | `(100, 100)`, that is 1% buy and 1% sell on the bonding curve |
| `SALT_LOCK_FEE()` | `3000000000000000` wei, 0.003 ETH |
| `flapCurvePairFactory()` | `0x0d1eBb179cdbcA88D74C923C4255Cb2B17474AfD` |
| `VAULT_PORTAL()` | `0xe9F7AB7DE8FB8756acbB6a1cd13316a43308197B` |
| `nonce()` | `295537` |
| `hasRole(DEFAULT_ADMIN_ROLE, FeeSafe)` | `true` |
"""),
"PortalImpl": ("Portal implementation, unverified",
 """The logic behind the Portal proxy. Blockscout has no source for it, so `selectors.txt` is a PUSH4 scan of the runtime code and `selectors-decoded.txt` resolves 96 selectors through openchain.
That decoded list is what makes the rest of this archive possible: it names `newTokenV5`, `newTokenV6`, `newTokenV7`, `commitNewTokenV5`, `stageNewTokenV5`, `swapExactInput`, `getQuoteTokenConfiguration`, `getTokenV8Safe`, `getFeeRate`, `SALT_LOCK_FEE`, `claim`, `delegateClaim` and `setTokenBeneficiary`.

Argument types for those calls come from `IPortal.sol`, which ships verified inside `VaultPortalImpl` and `TaxProcessorUniV2Impl`.
"""),
"PortalDispatchTrade": ("Portal trade dispatch module, unverified",
 """Delegatecall target of the Portal on every `swapExactInput`.
Seen in `_raw/blockscout/txinternal-0x0c7e01c9...json`: `Portal -> PortalImpl -> 0xA90B476c...`.
Deployed by `0x3bfC05a8b9e48FdFd6A443657caC5D983B664a05`, the same deployer as the Portal proxy admin and the other dispatch modules.
"""),
"PortalDispatchCurve": ("Portal bonding-curve dispatch module, unverified",
 """Second delegatecall target on a native-ETH buy.
`_raw/blockscout/txinternal-0xec60221a...json` shows `Portal -> PortalImpl -> 0x0C84dD8B...`, and immediately after it the Portal sends exactly 1% of the trade to the FeeSafe.
This is where the bonding-curve fee split executes.
"""),
"PortalQuoteSwapModule": ("Portal quote-swap module, unverified",
 """Called by the Portal on trades whose quote token is not native ETH (the HOODon trade in `_raw/blockscout/txinternal-0x0c7e01c9...json`).
It is the `nativeToQuoteSwapType` path from `QuoteTokenConfiguration`, which is set to `7` for most of the enabled stock-token quotes.
"""),
"PairFactory": ("FlapCurvePairFactory, unverified",
 """Confirmed as the curve-pair factory by `Portal.flapCurvePairFactory()`.
It deploys one beacon-proxy `FlapCurvePair` per launched token, so `allPairsLength()` is the exact count of tokens ever launched on this chain through Flap.

Live reads on 2026-09-02 (`_raw/rpc/ecosystem-counts.txt`):

| call | value |
| --- | --- |
| `allPairsLength()` | `173798` |
| `allPairs(0)` | `0x936937eebbc581b9baf5d542497dccf6648759fe` |
| `allPairs(173797)` | `0xa057908591c047bb9db816abbd7c5868b940cd2a` |

Sampling `graduated()` over 3,000 evenly spaced pairs returned 2 true (`_raw/rpc/graduation-sample.txt`).
"""),
"PairImpl": ("FlapCurvePair beacon implementation, unverified",
 """Every curve pair is a `BeaconProxy` onto this address.
Decoded selectors include `token0()`, `token1()`, `getReserves()`, `graduated()`, `portal()`, `initialize(address,address,address)` and `recoverToken(address)`.
`graduated()` is the cheapest per-token graduation check on this chain.
"""),
"FlapCurvePair-PRISM-example": ("Bonding-curve pair for $PRISM, example",
 "A live `BeaconProxy` curve pair, kept as a worked example of what `PairFactory` deploys."),
"Pair-ETF": ("Bonding-curve pair, example",
 "A second live `BeaconProxy` curve pair kept as an example."),
"Portal": ("SinjohFlapAdapter clone, NOT the Flap Portal",
 """The directory name is wrong and is kept only because earlier captures referenced it.
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
"""),
"SinjohFlapAdapterImpl": ("SinjohFlapAdapter implementation, verified",
 """A third-party launcher that wraps `Portal.newTokenV6`.
It hardcodes the Flap constants it expects (`flapFeeRate` 300, `flapCommissionBps` 60) and exposes `feeRoutingIntact()` so an integrator can check that Flap has not changed them underneath it.
Useful as an independent confirmation of the tax-side protocol rates.
"""),
"SinjohFlapAdapterFactory": ("SinjohFlapAdapterFactory, verified",
 "Deploys the EIP-1167 adapter clones. Evidence that launching on top of the Flap Portal is permissionless."),
"VaultPortal": ("VaultPortal (proxy), verified",
 """The second launch entry point. It creates a tax token and a Vault in one transaction, then forwards into `Portal.newTokenV6`.
Address matches the Robinhood table in the docs and `Portal.VAULT_PORTAL()`.
"""),
"VaultPortalImpl": ("VaultPortal implementation, verified",
 """Verified sources include `src/interfaces/IPortal.sol`, which is the only published copy of the Portal ABI: `NewTokenV5Params`, `NewTokenV6Params`, `NewTokenV7Params`, `TokenStateV8`, `TokenStateV8Safe`, `QuoteTokenConfiguration`, `CurveType`, `DexThreshType`, `MigratorType`, `TokenVersion` and `TokenStatus`.
Read this file rather than guessing at the unverified Portal.
"""),
"TaxProcessor": ("TaxProcessor clone for one tax token",
 """EIP-1167 clone of `TaxProcessorUniV2Impl`. One is deployed per tax token, and it is where the tax is split.

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
"""),
"TaxProcessorUniV2Impl": ("TaxProcessor implementation, verified",
 """`TaxProcessorBase._processFeeQuote` is the exact split:

```solidity
uint256 fee = (quoteAmount * config.feeRate) / 10000;
uint256 commission = (quoteAmount * config.commissionBps) / 10000;
uint256 remaining = quoteAmount - fee - commission;
// market / deflation / lp / dividend are taken as bps of `remaining`
if (distributed < remaining) { fee += remaining - distributed; }
```

The last line matters: **any part of the tax the creator does not allocate is added to Flap's fee bucket**, not returned to the trader or the creator.
The app validates that the four buckets total 100%, but nothing on chain requires it.
"""),
"TaxTokenHelper": ("TaxTokenHelper (proxy), verified",
 "Read helper the app and third-party terminals use to inspect a tax token in one call. Address matches the Robinhood table in the docs."),
"TaxTokenHelperImpl": ("TaxTokenHelper implementation, verified", "Logic behind the helper proxy."),
"FlapTaxTokenV3": ("Tax Token V3 implementation, verified",
 """One of the two token implementations Robinhood Chain accepts, reached through `Portal.newTokenV6` with `tokenVersion = TOKEN_TAXED_V3` (enum value 6).
Vanity suffix `7777`: every clone's address is mined to end in 7777.
Supports asymmetric buy and sell tax, a commission receiver, and a dividend token that can be the quote token, the tax token itself, or an arbitrary ERC-20.
"""),
"StandardTokenImpl": ("Non-tax token implementation (FlapNonTaxToken), verified",
 """The other accepted token type, reached through `Portal.newTokenV5`. Vanity suffix `8888`.
`maxSupply()` is 1,000,000,000 ether for every launch.
Anti-farmer enforcement here is a hard revert on transfers to or from registered pools, not a fee: all pool transfers are blocked before graduation, and after graduation only `mainPool` is exempt until `antiFarmerExpirationTime`.
"""),
"Token-mooncat-example": ("$moon, a live Tax Token V3 clone",
 """EIP-1167 clone of `FlapTaxTokenV3`, kept as a worked example of a graduated launch.
`Portal.getTokenV8Safe` for it (`_raw/rpc/lp-and-token-state.txt`): status 4 (DEX), tokenVersion 6, r `1.9189797e18`, h `1.07036752e26`, k `2.1243810542419344e27`, `dexSupplyThresh` 800,000,000e18, quote token the zero address, buy and sell tax 500 bps, pool `0x55aED1a1...`, progress `1e18`.
"""),
"UniswapV2Pool-MOON": ("Graduated Uniswap V2 pair for $moon, verified",
 """The destination of a Robinhood-chain graduation.
`totalSupply()` is `44821502752390679081447` and `balanceOf(0x...dEaD)` is `44790004104703970611336`, so **99.93% of the LP is burned** (`_raw/rpc/lp-and-token-state.txt`).
Nothing on this chain locks LP for the creator to claim from; the position is destroyed.
"""),
"UniswapV2Factory": ("Uniswap V2 factory, migration destination, verified",
 """`V2_MIGRATOR` is the only migrator Robinhood Chain accepts, and this is the factory it uses.
`allPairsLength()` was `40431` on 2026-09-02. Sampling 3,000 of those pairs, 27 had a Flap vanity token on one side, implying roughly 364 graduated Flap tokens (`_raw/rpc/graduation-sample.txt`).
"""),
"SwapRegistry": ("SwapRegistry (proxy), verified",
 "Routes quote-token and dividend-token swaps for the tax machinery. Address matches `swapRegistry` in `robinhood-chain-config.js`."),
"SwapRegistryImpl": ("SwapRegistry implementation, unverified", "Selector scan only."),
"SwapRouter02": ("Uniswap SwapRouter02, verified",
 "The router the TaxProcessor calls when it converts collected tax into the dividend or quote asset. Not a Flap contract; it is chain infrastructure."),
"TriggerService": ("TriggerService (proxy), verified",
 "Automation service listed in the Robinhood docs table. Its proxy admin is `ProxyAdmin-Aux`, whose owner is the FeeSafe."),
"TriggerServiceImpl": ("TriggerService implementation, unverified", "Selector scan only."),
"DividendTracker": ("Dividend clone for one tax token",
 "EIP-1167 clone of `DividendImpl`. Deployed per tax token that allocates a dividend bucket."),
"DividendImpl": ("Dividend implementation, verified",
 "Holds the dividend accounting for a tax token: eligible balances, minimum share balance, and claimable amounts."),
"DividendClaimHelper": ("DividendClaimHelper (proxy), verified",
 "Batch claim helper. Address matches `profileDividendClaimHelperAddress` in `robinhood-chain-config.js`."),
"DividendClaimHelperImpl": ("DividendClaimHelper implementation, unverified", "Selector scan only."),
"FeeSafe": ("Flap fee recipient and Portal admin, a Gnosis Safe",
 """Safe v1.4.1, **2 of 3** (`_raw/rpc/feesafe-and-roles.txt`), owners `0xa85c06f5...`, `0x01db3757...`, `0x29a64981...`.

Two roles, both material:

1. It receives the 1% bonding-curve fee directly. `_raw/blockscout/txinternal-0xec60221a...json` shows a `37053982898397` wei buy sending `370539828983` wei, exactly 1%, to this address in the same transaction.
2. `Portal.hasRole(DEFAULT_ADMIN_ROLE, FeeSafe)` returns `true`, so the same 2-of-3 can change quote-token configuration, fee rates, token beneficiaries and blocked tokens.
"""),
"ProxyAdmin-Core": ("ProxyAdmin for Portal, VaultPortal, SwapRegistry and TaxTokenHelper, verified",
 """Read from the EIP-1967 admin slot of each of those four proxies (`_raw/rpc/proxy-admins.txt`).
`owner()` is `0xc68f29bfe2f6c3d95adb5685592b9f86680968f2`, the `UpgradeSafe`.
Whoever controls that Safe can replace the Portal implementation, and the Portal custodies every bonding curve's reserve.
"""),
"ProxyAdmin-Aux": ("ProxyAdmin for TriggerService and DividendClaimHelper, verified",
 "`owner()` is the FeeSafe `0xa4A727E0...`."),
"UpgradeSafe": ("Owner of ProxyAdmin-Core, a Gnosis Safe",
 """Safe v1.4.1, **2 of 5**, owners `0x0806d392...`, `0x01db3757...`, `0x29a64981...`, `0xa85c06f5...`, `0x705163cf...` (`_raw/rpc/feesafe-and-roles.txt`).
Two of its owners are also FeeSafe owners, so the upgrade key and the fee key are not independent.
"""),
"HOODon": ("HOODon, an enabled quote token",
 """`name()` is `Robinhood Markets (Ondo Tokenized)`, `symbol()` is `HOODon`, 18 decimals, `totalSupply()` `3563983464298770878748` on 2026-09-02.
`Portal.getQuoteTokenConfiguration(HOODon)` returns `enabled = 1` with curve index 31 and `nativeToQuoteSwapType = 7`, and 10 of the 200 tokens on the board are quoted in it.
Not a Flap contract; included because it is a launch parameter.
"""),
"WETH": ("Wrapped ETH on Robinhood Chain (proxy)",
 "Chain infrastructure, `aeWETH` behind its own proxy admin. The TaxProcessor holds quote balances in it (`isWeth = true`)."),
"WETHImpl": ("aeWETH implementation, verified", "Chain infrastructure."),
}

def fn_lines(abi, wanted):
    out = []
    for f in abi or []:
        if f.get("type") != "function":
            continue
        n = f.get("name", "")
        if wanted and not any(w.lower() in n.lower() for w in wanted):
            continue
        sig = f"{n}({','.join(i['type'] for i in f.get('inputs', []))})"
        ret = ",".join(i["type"] for i in f.get("outputs", []))
        out.append(f"- `{sig}`" + (f" returns `({ret})`" if ret else "") + f"  [{f.get('stateMutability','')}]")
    return out

WANT = ["create", "newtoken", "launch", "buy", "sell", "swap", "graduat", "migrat",
        "claim", "fee", "tax", "quote", "curve", "beneficiar", "dividend", "lock",
        "owner", "role", "upgrade", "admin", "pair", "initialize", "version", "vault"]

def main():
    for d in sorted(os.listdir(ROOT)):
        p = os.path.join(ROOT, d)
        if not os.path.isdir(p):
            continue
        prefix = d.rsplit("-0x", 1)[0]
        role, prose = ROLES.get(prefix, ("", ""))
        addr = "0x" + d.rsplit("-0x", 1)[1]
        m = json.load(open(os.path.join(p, "metadata.json")))
        a = json.load(open(os.path.join(p, "address.json")))
        abi = None
        if os.path.exists(os.path.join(p, "abi.json")):
            abi = json.load(open(os.path.join(p, "abi.json")))
        verified = bool(a.get("is_verified"))
        impls = [i.get("address_hash") or i.get("address") for i in (a.get("implementations") or [])]
        L = []
        L.append(f"# {d}\n")
        L.append(f"**{role or 'Contract in the Flap deployment on Robinhood Chain'}**\n")
        L.append(f"- Address: `{addr}`")
        L.append(f"- Contract name on Blockscout: `{a.get('name') or m.get('name') or 'unnamed'}`")
        L.append(f"- Verified: {'yes' if verified else 'no'}")
        L.append(f"- Proxy type: `{a.get('proxy_type') or 'none'}`" + (f", implementation `{impls[0]}`" if impls else ""))
        L.append(f"- Creator: `{a.get('creator_address_hash')}`")
        L.append(f"- Creation tx: `{a.get('creation_transaction_hash')}`")
        if m.get("compiler_version"):
            L.append(f"- Compiler: `{m.get('compiler_version')}`, optimizer "
                     f"{'on' if m.get('optimization_enabled') else 'off'}"
                     + (f" ({m.get('optimization_runs')} runs)" if m.get("optimization_runs") else "")
                     + (f", EVM `{m.get('evm_version')}`" if m.get("evm_version") else ""))
        if m.get("license_type"):
            L.append(f"- License: `{m.get('license_type')}`")
        L.append(f"- Explorer: <https://robinhoodchain.blockscout.com/address/{addr}>")
        L.append("")
        if prose:
            L.append(prose.strip() + "\n")
        ca = m.get("decoded_constructor_args")
        if ca:
            L.append("## Constructor arguments\n")
            for v, meta in ca:
                L.append(f"- `{meta.get('name') or '?'}` (`{meta.get('type')}`): `{v}`")
            L.append("")
        if abi:
            fns = fn_lines(abi, WANT)
            if fns:
                L.append("## Functions that matter for launching\n")
                L.extend(fns)
                L.append("")
            evs = [e for e in abi if e.get("type") == "event"]
            if evs:
                L.append("## Events\n")
                for e in evs:
                    L.append(f"- `{e['name']}({','.join(i['type'] for i in e.get('inputs', []))})`")
                L.append("")
        else:
            L.append("## Callable surface\n")
            L.append("No verified source. `bytecode.hex` holds the runtime code, `selectors.txt` is a PUSH4 scan of it, and `selectors-decoded.txt` resolves those selectors through openchain.\n")
        L.append("## Files in this directory\n")
        for f in sorted(os.listdir(p)):
            if f == "README.md":
                continue
            L.append(f"- `{f}`" + ("/" if os.path.isdir(os.path.join(p, f)) else ""))
        L.append("")
        open(os.path.join(p, "README.md"), "w").write("\n".join(L))
        print("wrote", d, "role" if role else "NO ROLE TEXT")

main()
