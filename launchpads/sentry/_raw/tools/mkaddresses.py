import os, json, glob, re
BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/sentry"
groups = [
    ("The live launch path, Robinhood Chain", [
        "LaunchFactoryWeth", "LaunchFactoryV4Impl", "LaunchFactoryStock", "FeeHookWeth",
        "FeeHookWethReflections", "FeeHookStock", "DynamicFeeHookDefault", "LPVault",
        "TreasurySplitter", "PoolManagerV4", "WETH9"]),
    ("The retired Uniswap V3 generation", [
        "LaunchFactoryLegacyV3", "LaunchFactoryLegacyImpl", "FeeHookStockLegacyV2",
        "UniswapV3Factory", "UniswapV3PositionManager", "UniswapV3SwapRouter02"]),
    ("Routers, locker and the platform token", [
        "SwapRouterV2", "SwapRouterV4", "SwapRouterStockMultihop", "SwapRouterPancakeV3",
        "TokenLocker", "SentryToken", "SentryFeeHook", "RelaunchLauncher", "TreasurySafe",
        "USDG", "ZNSConnectHood"]),
    ("Example launches and stock base tokens", [
        "ExampleLaunchWeth", "ExampleLaunchWethReflections", "ExampleLaunchStock",
        "ExampleLaunchStockChill", "StockBaseSLV", "StockBaseNFLX"]),
    ("Quotrons, the sibling Mavrk product", None),
]
dirs = {}
for d in sorted(glob.glob(BASE + "/contracts/*/")):
    base = os.path.basename(d.rstrip("/"))
    role, addr = base.rsplit("-", 1)
    dirs[role] = (base, addr, d)

notes = {}
for line in open(BASE + "/_raw/tools/contracts.list"):
    p = line.strip().split("|")
    if len(p) >= 3:
        notes[p[0]] = p[2]

rows_done = set()
L = ["# Sentry contract addresses, Robinhood Chain (chain id 4663)", "",
     "Captured 2026-09-02 from `https://robinhoodchain.blockscout.com/api/v2` plus live `eth_call` reads.",
     "Every row has a directory under `contracts/` with `metadata.json`, `abi.json` where verified, `sources/` at their original paths, and a generated `README.md` listing constructor arguments, events and functions.",
     "Unverified contracts carry `bytecode.hex` instead of sources.",
     "Ink addresses (chain id 57073) are listed in `pages/45-guide-chains-contracts.md` and were not fetched, because this archive exists to pick a Robinhood Chain launch venue.",
     ""]


def row(role):
    base, addr, d = dirs[role]
    sc = json.load(open(d + "metadata.json"))
    ad_path = BASE + "/_raw/blockscout/addresses-%s.json" % addr
    ad = json.load(open(ad_path)) if os.path.exists(ad_path) else {}
    name = sc.get("name") or ad.get("name") or "-"
    ver = "yes" if ad.get("is_verified") or sc.get("is_verified") else "no"
    impls = [i.get("address_hash") or i.get("address") for i in (ad.get("implementations") or [])]
    proxy = ad.get("proxy_type") or "-"
    pi = proxy if proxy != "-" else "-"
    if impls and impls[0]:
        pi = "%s -> `%s`" % (proxy, impls[0])
    creator = ad.get("creator_address_hash") or "-"
    tx = ad.get("creation_transaction_hash") or "-"
    tx = ("`%s`" % tx[:14] + "..." ) if tx != "-" else "-"
    rows_done.add(role)
    return "| `%s` | %s | %s | %s | %s | `%s` | %s | `contracts/%s/` |" % (
        addr, role, name, ver, pi, creator, tx, base)


for title, roles in groups:
    if roles is None:
        roles = sorted(r for r in dirs if r.startswith("Quotron"))
    L += ["## " + title, "",
          "| address | role | contract name | verified | proxy | creator | creation tx | source dir |",
          "| --- | --- | --- | --- | --- | --- | --- | --- |"]
    for r in roles:
        if r in dirs:
            L.append(row(r))
    L.append("")

missing = [r for r in dirs if r not in rows_done]
if missing:
    L += ["## Not grouped", "", "| address | role | contract name | verified | proxy | creator | creation tx | source dir |",
          "| --- | --- | --- | --- | --- | --- | --- | --- |"] + [row(r) for r in sorted(missing)] + [""]

L += ["## Live state read from these contracts on 2026-09-02", "",
      "Full dumps: `_raw/rpc/derived-state-2026-09-02.txt`, `_raw/rpc/derived-poolkeys-2026-09-02.txt`, `_raw/rpc/derived-sentry-token-2026-09-02.txt`.", "",
      "| contract | call | value |",
      "| --- | --- | --- |",
      "| LaunchFactoryWeth | `owner()` | `0xbf551eed83c7eaee63854a2013eb94f18600b7c5` |",
      "| LaunchFactoryWeth | `treasury()` | `0x75450496fe333a93e1327368aa3c4130bf008697`, the splitter |",
      "| LaunchFactoryWeth | `vault()` | `0x0f0e601041ec765b8bab8c166840e291253f2df0` |",
      "| LaunchFactoryWeth | `hook()` | `0x35c0098836fa0d10a015a95bf02c16387814f0cc` |",
      "| LaunchFactoryWeth | `reflectionHook()` | `0x730abadbb4f328520e5350f59126fbe1d67f70cc` |",
      "| LaunchFactoryWeth | `creatorFeeBps()` | 7000 |",
      "| LaunchFactoryWeth | `totalTokensDeployed()` | 76 |",
      "| LaunchFactoryWeth | `TICK_SPACING()` | 200 |",
      "| LaunchFactoryWeth | `getSupportedBaseTokens()` | one entry, WETH |",
      "| LaunchFactoryStock | `hook()` | `0x3b778ccff74c2f21e771e1e951b1343108fc7080`, SentryDynamicFeeHook |",
      "| LaunchFactoryStock | `baseTokenToHook(SLV/NFLX/AAPL)` | `0x5daa88b65bd47199ec92d3cde01b56348e1270cc` for all three |",
      "| LaunchFactoryStock | `totalTokensDeployed()` | 16 |",
      "| LaunchFactoryStock | `getSupportedBaseTokens()` | 88 tokenised stocks |",
      "| LaunchFactoryLegacyV3 | `CREATOR_FEE_BPS()` | 7000 |",
      "| LaunchFactoryLegacyV3 | `FEE_TIER()` | 10000, the Uniswap V3 1% tier |",
      "| LaunchFactoryLegacyV3 | `totalTokensDeployed()` | 93 |",
      "| LaunchFactoryLegacyV3 | `treasury()` | `0xcaafcf8e55f3b5e3d5f7957987db232f08d2367c`, the treasury wallet directly |",
      "| FeeHookWeth | `startFee()` / `endFee()` | 400000 / 17000 pips, so 40% decaying to 1.7% |",
      "| FeeHookWeth | `holdDuration()` / `halfLife()` | 180 / 180 seconds |",
      "| FeeHookWeth | `earlyCreatorBps()` / `earlyTreasuryBps()` | 5882 / 0 |",
      "| FeeHookWeth | `lateCreatorBps()` / `lateLpBps()` / `lateReflectionBps()` | 5882 / 1176 / 0 |",
      "| FeeHookWethReflections | `reflectionStartDelay()` | 600 seconds |",
      "| FeeHookWethReflections | early bps | creator 5000, treasury 2500, remainder to LP |",
      "| FeeHookWethReflections | late bps | creator 2941, LP 1176, reflections 4706, remainder 1177 to treasury |",
      "| FeeHookStock | all of the above | identical to FeeHookWethReflections, `factory()` points at the stock factory |",
      "| SentryFeeHook | `startFee()` / `endFee()` | 400000 / 20000 pips, so 40% decaying to 2% |",
      "| SentryFeeHook | `earlyExitFee()` | 800000 pips, 80%, on migration-locked sellers only |",
      "| SentryFeeHook | `lpShareBps()` / `reflectionShareBps()` / `treasuryShareBps()` | 3750 / 3750 / 2500 |",
      "| TreasurySplitter | `forwardBps()` | 6000 to `treasuryWallet()`, remainder compounded into SENTRY liquidity |",
      "| TreasurySplitter | `keeper()` | the zero address |",
      "| LPVault | `creatorFeeBps()` | 7000 |",
      "| LPVault | `v4FactoryWeth()` / `v4FactoryStock()` / `v3Factory()` | the three factories above |",
      "| TokenLocker | `lockCount()` | 509 |",
      "| SentryToken | `totalSupply()` | 1,000,000,000 with 18 decimals |",
      "| SentryToken | `TREASURY_CUT()` / `FOUNDER_CUT()` | 100,000,000 and 30,000,000, so 10% and 3% |",
      "| SentryToken | `founder()` | `0x7171e64e979265aed6588577d1c6b60a701d7866`, the Quotrons deployer |",
      "| SentryToken | `unlockTime()` | 1790985600, 2026-10-03, extended from 2026-08-03 by holder vote |",
      "| SentryToken | `yesVotes()` / `noVotes()` | 291,961,250 vs 70,397,328 SENTRY, `extensionPassing() = true` |",
      "",
      "## Pool keys of three example launches", "",
      "Every live pool is a Uniswap v4 dynamic-fee pool: the `fee` field is `0x800000` (8388608) and `tickSpacing` is 200.", "",
      "| token | base | hook | pool id |",
      "| --- | --- | --- | --- |",
      "| Hood Of Meme, plain WETH launch | WETH | `0x35c0098836fa0d10a015a95bf02c16387814f0cc` | `0x6b0fe4e9fe262f88759bb184f967bcbfd248e35332505d5c8de2ae426f93c66c` |",
      "| Baby Sentry, WETH with reflections | WETH | `0x730abadbb4f328520e5350f59126fbe1d67f70cc` | `0xc18e89099bb91e1823f2914e3d34242dc51a50bbb61134609fc6adda4218b591` |",
      "| Silver Inu, stock pair | SLV | `0x5daa88b65bd47199ec92d3cde01b56348e1270cc` | `0x057efd834864a0e92dbe44800c086e995908f3404c80ae6fcbe2941e4661ca4a` |",
      ""]
open(BASE + "/contracts/ADDRESSES.md", "w").write("\n".join(L) + "\n")
print("rows:", len(rows_done), "of", len(dirs))
