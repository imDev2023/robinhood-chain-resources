"""Build contracts/ADDRESSES.md from the contracts/ directories plus the EOAs and third-party forks seen on chain."""
import os, json, glob

BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/virtuals"
RAW = f"{BASE}/_raw"


def addr_json(a):
    p = f"{RAW}/blockscout/contracts/address-{a.lower()}.json"
    return json.load(open(p)) if os.path.exists(p) else {}


rows = []
for d in sorted(glob.glob(f"{BASE}/contracts/*-0x*")):
    name = os.path.basename(d)
    role, addr = name.rsplit("-0x", 1)
    addr = "0x" + addr
    meta = json.load(open(f"{d}/metadata.json"))
    ad = addr_json(addr)
    is_sc = "abi" in meta or "source_code" in meta
    cname = meta.get("name") if is_sc else (ad.get("name") or "")
    verified = "yes" if (is_sc and meta.get("is_verified")) else ("via implementation" if ad.get("implementations") and not is_sc else "no")
    impls = [i.get("address_hash") for i in (ad.get("implementations") or [])]
    if ad.get("proxy_type") and impls:
        proxy = f"{ad.get('proxy_type')} -> {', '.join(impls)}"
    elif "Impl" in role or "Implementation" in role:
        proxy = "implementation"
    else:
        proxy = "no"
    creator = ad.get("creator_address_hash") or ""
    tx = ad.get("creation_transaction_hash") or ""
    rows.append((addr, role, cname or "", verified, proxy, creator, tx, f"contracts/{name}/"))

# order: launch path first
order = ["VirtualToken", "CCIP", "BondingV5", "BondingConfig", "FFactoryV3", "FPairV2", "FRouterV3", "AgentTaxV2", "TaxAccounting", "AgentFactoryV7", "AgentTokenV4", "AgentVeTokenV2", "AgentDAO", "AgentNftV2", "ERC6551", "AccountV3", "TBA", "Multicall3", "SwapRouter", "UniswapV2", "UniswapV3", "Nonfungible", "USDG", "WETH", "ACP", "Example", "Helper"]


def rank(r):
    for i, k in enumerate(order):
        if r[1].startswith(k):
            return (i, r[1])
    return (99, r[1])


rows.sort(key=rank)

L = ["# Virtuals Protocol - contract addresses on Robinhood Chain (4663)", "",
     "Generated 2026-09-02 by `_raw/tools/mkaddresses.py` from the Blockscout records in `_raw/blockscout/contracts/`.",
     "Every row links to a directory with `metadata.json`, and with `abi.json` plus `sources/` when the contract is verified, or `bytecode.hex` when it is not.",
     "Proxies are OpenZeppelin TransparentUpgradeableProxy unless stated; the admin of every Virtuals proxy is the owner EOA `0xc31Cf1168b2f6745650d7B088774041A10D76d55` (BondingConfig.owner, BondingV5.owner, TaxAccountingAdapter.owner in `_raw/rpc/`).",
     "", "## Contracts", "",
     "| address | role | name | verified | proxy/impl | creator | creation tx | source dir |", "| --- | --- | --- | --- | --- | --- | --- | --- |"]
for r in rows:
    L.append("| " + " | ".join(f"`{r[0]}`" if i == 0 else (f"`{x}`" if i in (5, 6) and x else x) for i, x in enumerate(r)) + " |")

L += ["", "## Wallets and EOAs in the launch path (read from the contracts, `_raw/rpc/*.txt`)", "",
      "| address | role | evidence |", "| --- | --- | --- |",
      "| `0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F` | Virtuals deployer. Deployed VIRTUAL (CCIP) on 2026-06-23 and the whole launch stack on 2026-06-25 | `_raw/blockscout/deployer/all-txs.json` (159 txs, 28 contract creations) |",
      "| `0xc31Cf1168b2f6745650d7B088774041A10D76d55` | Owner and proxy admin of BondingV5, BondingConfig, TaxAccountingAdapter; deployed the three BondingV5 upgrades | `_raw/rpc/bondingconfig-reads.txt`, `_raw/blockscout/contracts/address-0x66fc...json` |",
      "| `0x86CbAC9d9Ac726F729eEf6627Dc4817BcBB03A9c` | BondingConfig.feeTo: receives the 10 VIRTUAL ACF launch fee | `_raw/rpc/bondingconfig-reads.txt` |",
      "| `0xb51C52d9E5E41937B0100840b6C3CBA6f7A57A0C` | AgentTaxV2.treasury: receives the 30 percent protocol share of every 1 percent trade tax, in USDG | `_raw/rpc/tax-factory-router-reads.txt` |",
      "| `0x32487287c65f11d53bbCa89c2472171eB09bf337` | FFactoryV3.antiSniperTaxVault: receives the decaying anti-sniper tax (99 percent to 1 percent) in VIRTUAL, used for buybacks | `_raw/rpc/ffactory-reads.txt` |",
      "| `0x81F7cA6AF86D1CA6335E44A2C28bC88807491415` | BondingConfig.teamTokenReservedWallet and privileged launcher: holds reserved ACF and airdrop supply and the creator's initial-buy tokens; calls `launch()` for 60 Days, X-launch, ACP-skill and fee-delegated tokens | `_raw/rpc/bondingconfig-reads.txt`, `_raw/blockscout/launches/launch-0xcee078...json` |",
      "| `0xAeA27856B6284Ae071E0685ed594C5B80aEA2aa9` | BondingConfig.graduationExcessBurnWallet: receives the curve tokens not needed to seed the Uniswap V2 pool at graduation (the Hyperboost reward supply) | `_raw/rpc/bondingconfig-reads.txt`, `contracts/BondingV5-Impl-current-*/sources/.../BondingV5.sol` `_openTradingOnUniswap` |",
      "| `0xE220329659D41B2a9F26E83816B424bDAcF62567` | AgentFactoryV7.defaultDelegatee and owner of every agent token clone | `_raw/rpc/tax-factory-router-reads.txt`, `_raw/rpc/agenttoken-vetoken-reads.txt` |",
      "| `0x32e7c4AFEA4f868A53EC51435C92eD80625EeB33` | founder recorded in the VEX veToken (sVEX) | `_raw/rpc/agenttoken-vetoken-reads.txt` |",
      "| `0x9701fb0adE1E269c8f64Ec0C7B3CFadb31A13a52` | Uniswap deployer on Robinhood Chain (V2 factory, V2 router, V3 factory, position manager) | `_raw/blockscout/contracts/address-0x8bce...json` |",
      "| `0x062f05CD6C835677B05a8658A351969476861316` | Chainlink CCIP deployer (TokenAdminRegistry, RegistryModuleOwnerCustom, OffRamp) | `_raw/blockscout/contracts/address-0x1912...json` |",
      "| `0x06fC836cf9839B1cd891C440A0a45242DA6Ae1c9` | Chainlink CCIP Router on Robinhood Chain (BurnMintTokenPool constructor arg) | `contracts/CCIP-BurnMintTokenPool-*/README.md` |",
      "| `0xe8464c353210Cc398A45dB2454FBc5BCd25fFf20` | Chainlink RMN proxy (BurnMintTokenPool constructor arg) | `contracts/CCIP-BurnMintTokenPool-*/README.md` |",
      "", "## Addresses in the whitepaper that are not contracts on this chain", "",
      "| address | whitepaper label | on Robinhood Chain |", "| --- | --- | --- |",
      "| `0xdAd686299FB562f89e55DA05F1D96FaBEb2A2E32` | Creator vault (locks pre-bonding tokens for creators) | EOA, no code, 0 balance (`_raw/blockscout/address-0xdAd6...json`) |",
      "| `0xe2890629EF31b32132003C02B29a50A025dEeE8a` | Sell wall wallet (disburses tokens for sell orders) | EOA, no code, 0.186 ETH (`_raw/blockscout/address-0xe289...json`) |",
      "| `0xF8DD39c71A278FE9F4377D009D7627EF140f809e` | Sell order (executes sell orders) | EOA, no code (`_raw/blockscout/address-0xF8DD...json`) |",
      "| `0x1A540088125d00dD3990f9dA45CA0859af4d3B01` | Bonding curve, Base Chain | Base address, not on 4663 |",
      "| `0x0b3e328455c4059EEb9e3f84b5543F74E24e7E1b` | VIRTUAL, Base Chain | Base address |",
      "| `0x44ff8620b8cA30902395A7bD3F2407e1A091BF73` | VIRTUAL, Ethereum | Ethereum address |",
      "", "## Third-party forks of the Virtuals code base on this chain (not Virtuals, listed so nobody confuses them)", "",
      "Blockscout name search returns these verified contracts with Virtuals class names, but none were deployed by the Virtuals deployer or owner and none are referenced by the live proxies.",
      "", "| address | name | creator |", "| --- | --- | --- |"]
forks = [("0x6ccA4A7A72df0fAA594A33fCab0a63b4c1C7b63A", "BondingV1"), ("0xE817E11df9b5Cc6918e7Ad97bBfAAB55c275e117", "FRouterV1"), ("0x618a5d55497f103e103DD5f5e64EED119388Fd8D", "AgentTaxV1"),
         ("0xa3C36aFf0232Be334FA9d4da0a7630f10aB5113b", "FFactory"), ("0xe7D6801a4C2aC1aB3779FE4413DB4c59eC2eff87", "FFactory"), ("0xB5A1dFC44727676Bb16D7b6dF664a09629cb4019", "FRouter"), ("0x8b8E5De51381CACeA69058d826754b7a4eC6ec77", "FRouter"),
         ("0xa92C2098E9B2dC1301ce2180355f3B77c6f8661A", "AgentFactory"), ("0x6573bc9090BbCae309d2A3D95fDAC05617914000", "AgentFactory"), ("0x1D89d915A366b42F64d6B262F9805B11320d8117", "AgentNFTv3"), ("0x8EB6F9234542609Cf65694dB954e1eF396e05d07", "AgentNFTv3"),
         ("0x5FC43Eda6A84d3d27f40e94F6fB6908c2CD41697", "virtualToken"), ("0x17b08130b47c885Bf5d451A11639B77A6b408e4f", "virtualToken")]
for a, n in forks:
    ad = addr_json(a)
    L.append(f"| `{a}` | {n} | `{ad.get('creator_address_hash') or 'see _raw/blockscout/search-*.json'}` |")
L.append("")
open(f"{BASE}/contracts/ADDRESSES.md", "w").write("\n".join(L))
print("rows", len(rows))
