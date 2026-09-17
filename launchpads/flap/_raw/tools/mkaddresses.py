#!/usr/bin/env python3
import json, os
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "contracts")
SHORT = {
 "FlapCore": ("Portal, protocol entry point", "launch and trade"),
 "PortalImpl": ("Portal implementation", "launch and trade"),
 "PortalDispatchTrade": ("Portal trade dispatch module", "launch and trade"),
 "PortalDispatchCurve": ("Portal curve dispatch module, takes the 1% fee", "launch and trade"),
 "PortalQuoteSwapModule": ("Portal non-ETH quote swap module", "launch and trade"),
 "VaultPortal": ("VaultPortal, vault-backed launch entry point", "launch and trade"),
 "VaultPortalImpl": ("VaultPortal implementation, carries IPortal.sol", "launch and trade"),
 "PairFactory": ("FlapCurvePairFactory", "bonding curve"),
 "PairImpl": ("FlapCurvePair beacon implementation", "bonding curve"),
 "FlapCurvePair-PRISM-example": ("Curve pair for $PRISM, example", "bonding curve"),
 "Pair-ETF": ("Curve pair, example", "bonding curve"),
 "StandardTokenImpl": ("FlapNonTaxToken implementation, vanity 8888", "token"),
 "FlapTaxTokenV3": ("FlapTaxTokenV3 implementation, vanity 7777", "token"),
 "Token-mooncat-example": ("$moon, live Tax Token V3 clone", "token"),
 "TaxProcessor": ("TaxProcessor clone for one tax token", "tax"),
 "TaxProcessorUniV2Impl": ("TaxProcessor implementation, the tax split", "tax"),
 "TaxTokenHelper": ("TaxTokenHelper", "tax"),
 "TaxTokenHelperImpl": ("TaxTokenHelper implementation", "tax"),
 "DividendTracker": ("Dividend clone for one tax token", "tax"),
 "DividendImpl": ("Dividend implementation", "tax"),
 "DividendClaimHelper": ("DividendClaimHelper", "tax"),
 "DividendClaimHelperImpl": ("DividendClaimHelper implementation", "tax"),
 "SwapRegistry": ("SwapRegistry", "tax"),
 "SwapRegistryImpl": ("SwapRegistry implementation", "tax"),
 "SwapRouter02": ("Uniswap SwapRouter02, used by the tax path", "tax"),
 "TriggerService": ("TriggerService automation", "automation"),
 "TriggerServiceImpl": ("TriggerService implementation", "automation"),
 "UniswapV2Factory": ("Uniswap V2 factory, graduation destination", "graduation"),
 "UniswapV2Pool-MOON": ("Graduated $moon pair, 99.93% LP burned", "graduation"),
 "FeeSafe": ("Flap fee Safe, 2 of 3, and Portal DEFAULT_ADMIN", "governance"),
 "ProxyAdmin-Core": ("ProxyAdmin for Portal, VaultPortal, SwapRegistry, TaxTokenHelper", "governance"),
 "ProxyAdmin-Aux": ("ProxyAdmin for TriggerService and DividendClaimHelper", "governance"),
 "UpgradeSafe": ("Owner of ProxyAdmin-Core, Safe 2 of 5", "governance"),
 "Portal": ("SinjohFlapAdapter clone, third-party launcher (misnamed dir)", "third party"),
 "SinjohFlapAdapterImpl": ("SinjohFlapAdapter implementation", "third party"),
 "SinjohFlapAdapterFactory": ("SinjohFlapAdapterFactory", "third party"),
 "HOODon": ("HOODon quote token, Ondo-tokenized HOOD", "quote asset"),
 "WETH": ("Wrapped ETH", "chain"),
 "WETHImpl": ("aeWETH implementation", "chain"),
}
rows = []
for d in sorted(os.listdir(ROOT)):
    p = os.path.join(ROOT, d)
    if not os.path.isdir(p):
        continue
    prefix, addr = d.rsplit("-0x", 1)
    addr = "0x" + addr
    a = json.load(open(os.path.join(p, "address.json")))
    m = json.load(open(os.path.join(p, "metadata.json")))
    role, group = SHORT.get(prefix, ("", "other"))
    impls = [i.get("address_hash") or i.get("address") for i in (a.get("implementations") or [])]
    proxy = a.get("proxy_type") or ""
    px = f"{proxy} to `{impls[0]}`" if impls else (proxy or "no")
    rows.append((group, prefix, addr, role,
                 a.get("name") or m.get("name") or "unnamed",
                 "yes" if a.get("is_verified") else "no",
                 px, a.get("creator_address_hash") or "", a.get("creation_transaction_hash") or "", d))
order = ["launch and trade", "bonding curve", "token", "tax", "automation", "graduation",
         "governance", "third party", "quote asset", "chain", "other"]
rows.sort(key=lambda r: (order.index(r[0]), r[1]))
out = []
out.append("# Flap contract addresses on Robinhood Chain (chain id 4663)\n")
out.append("Captured 2026-09-02 and 2026-09-03 from `https://robinhoodchain.blockscout.com/api/v2` and live `eth_call`.\n")
out.append("Grouped by role. Every row has a directory under `contracts/` with a `README.md`, and either verified `sources/` or `bytecode.hex` plus a decoded selector list.\n")
cur = None
for g, prefix, addr, role, name, ver, px, cre, tx, d in rows:
    if g != cur:
        cur = g
        out.append(f"\n## {g.capitalize()}\n")
        out.append("| address | role | contract name | verified | proxy / impl | creator | creation tx | source dir |")
        out.append("| --- | --- | --- | --- | --- | --- | --- | --- |")
    out.append(f"| `{addr}` | {role} | `{name}` | {ver} | {px} | `{cre}` | `{tx}` | `contracts/{d}/` |")
open(os.path.join(ROOT, "ADDRESSES.md"), "w").write("\n".join(out) + "\n")
print("rows", len(rows))
