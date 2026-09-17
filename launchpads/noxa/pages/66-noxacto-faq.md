# Noxa - noxacto faq

> Source: https://noxacto.xyz/faq
> Retrieved: 2026-09-02 (Jina Reader)

---

Title: NOXACTO — The NOXA Bridge

URL Source: https://noxacto.xyz/faq

Markdown Content:
How does the bridge work?
You lock NOXA on DBK Chain and receive **wNOXA** on the destination chain you pick, backed **1:1**. If the community burn fee is switched on, a small slice of each deposit is burned first, and the transfer card always shows the exact amount you will receive. Every wNOXA is a claim on real NOXA sitting in the lockbox, nothing is minted out of thin air. Whenever you want, burn your wNOXA and the same amount of NOXA is released back to you on DBK Chain, with no fee on the way out. Live backing is shown on the [bridge page](https://noxacto.xyz/) under Proof of Reserves.

Is this an official NOXA bridge?
No. This is a **community effort** by the merrymen. It is not built, run, or endorsed by NOXA or by Robinhood or Stable. It is experimental software, do your own research and only bridge what you are comfortable with.

What is wNOXA?
wNOXA (“wrapped NOXA”) is NOXA mirrored onto another chain. One wNOXA is always backed by one NOXA locked on DBK Chain, and it mirrors NOXA’s 25,000 max-wallet cap. Redeem it any time to get your NOXA back on DBK Chain. Each destination chain has its own wNOXA and its own vault, so one route can never spend another’s backing.

How does providing liquidity (LP) work?
Two ways. **wNOXA only** (the default): your wNOXA is placed as a sell band just above the current price and converts to the other token as NOXA rises, earning the 1% fee on every fill. Or **wNOXA + the pool's other token** (WETH on Robinhood, USDT0 on Stable): a classic two-sided position across the whole range. Either way you get a position NFT you can withdraw any time. Because the price moves, LPs can end up worth less than simply holding, so only provide what you can afford to lose. Start on the [Add Liquidity](https://noxacto.xyz/pool) page. New to Uniswap V3? Their docs explain [concentrated liquidity](https://docs.uniswap.org/concepts/protocol/concentrated-liquidity).

What fees are there?
Redeeming (wNOXA back to NOXA) is always free, you pay only network gas. Bridging in is free today; the community can switch on a **bridge burn fee** of at most 2% (the ceiling is enforced by the contract and cannot be raised), and every token of it is burned, none of it is kept. The transfer card always shows the exact amount you will receive. The wNOXA pools charge the standard 1% swap fee; the seeded pool’s liquidity is permanently locked.

Why does the token scanner show warnings on wNOXA?

Automated scanners (the “Quick Intel” panel on DEX Screener and similar) flag wNOXA on five points. Four are real and deliberate, one is a misread. The source is verified, so you can check every claim here yourself: [wNOXA on Robinhood ↗](https://robinhoodchain.blockscout.com/address/0x4eA5eEfF68A6F0848A9d5ab3a21F4Fe1b20ECcDc) · [wNOXA on Stable ↗](https://stablescan.xyz/address/0x9Fe50e7f1445aB592D768810Ad19d50f4cC7DE51) · [wNOXA on Arc ↗](https://noxacto.xyz/address/0x9c4C5421faebeF19C18e056519a4d7d5CA12F103).

**“Mintable” and “hidden owner”** — both describe the bridge itself. wNOXA is minted when you lock NOXA on DBK, so a mint function is not optional; the “hidden owner” is the relayer’s minter key, which lives in a public `isMinter` mapping and emits an event every time it changes. Minting is bounded three ways: the role is revocable, the total supply is capped in the contract and cannot be raised, and every wNOXA must be matched by real NOXA in the vault — which the [Proof of Reserves](https://noxacto.xyz/) card checks live, per chain.

**“Transfer pausable”** — true. Pausing freezes all movement, including transfers. It is the emergency brake for a discovered exploit or a compromised relayer key, and it is the reason a bridge should not be ownerless.

**“Ownership not renounced”** — true, and permanent: the renounce function is disabled in the contract and always reverts. Renouncing would leave nobody able to revoke a leaked relayer key, pause during an incident, or settle locks already in flight — anyone mid-bridge at that moment would be stranded. Ownership can only be handed over, in two steps, never dropped.

**“Has blacklist” is wrong.** No function in wNOXA can block an address, and none exists to be added without deploying a new token. What the scanner is reading is the **25,000 wallet cap** that wNOXA mirrors from NOXA itself, plus the list of addresses exempt from it (the pools, the fee burner). That list grants exemptions, it does not deny anyone.

**What the owner can actually do:** grant or revoke the minter role, pause and unpause, exempt an address from the wallet cap, and change the cap value. That last one is a real power — the cap cannot be set to zero, but a low value would throttle transfers, much as pausing does. The owner can never seize, redirect, or block a specific person’s tokens, and can never mint past the supply cap. Ownership is a **2-of-3 Safe multisig** — the same Safe address on every chain, so every owner action takes two independent signatures. Verify it yourself: [DBK](https://scan.dbkchain.io/address/0x254E4000977d02e2938ce61D866d9c2834338174), [Robinhood](https://robinhoodchain.blockscout.com/address/0x254E4000977d02e2938ce61D866d9c2834338174), [Stable](https://stablescan.xyz/address/0x254E4000977d02e2938ce61D866d9c2834338174).

What is the bridge burn fee?
The community’s burn engine. When it is active, a slice of every NOXA bridged in (at most 2%, the contract enforces the ceiling) is sent straight to the **dead address** on DBK Chain in the same transaction, permanently removing it from circulation. Nothing goes to a treasury, none of it is kept, and every burn makes the remaining NOXA scarcer. The 1:1 backing of wNOXA is never touched, burns come out of circulating supply, not out of the collateral, and the transfer card always shows the exact amount you will receive.

Links/Buttons:
- [NOXA BridgeDBK ⇄ ROBINHOOD · STABLE · ARC](https://noxacto.xyz/)
- [Launchpad](https://noxacto.xyz/launchpad)
- [Add LP](https://noxacto.xyz/pool)
- [$wNOXA](https://noxacto.xyz/wnoxa)
- [FAQ](https://noxacto.xyz/faq)
- [Team](https://noxacto.xyz/team)
- [concentrated liquidity](https://docs.uniswap.org/concepts/protocol/concentrated-liquidity)
- [wNOXA on Robinhood ↗](https://robinhoodchain.blockscout.com/address/0x4eA5eEfF68A6F0848A9d5ab3a21F4Fe1b20ECcDc)
- [wNOXA on Stable ↗](https://stablescan.xyz/address/0x9Fe50e7f1445aB592D768810Ad19d50f4cC7DE51)
- [wNOXA on Arc ↗](https://noxacto.xyz/address/0x9c4C5421faebeF19C18e056519a4d7d5CA12F103)
- [DBK](https://scan.dbkchain.io/address/0x254E4000977d02e2938ce61D866d9c2834338174)
- [Robinhood](https://robinhoodchain.blockscout.com/address/0x254E4000977d02e2938ce61D866d9c2834338174)
- [Stable](https://stablescan.xyz/address/0x254E4000977d02e2938ce61D866d9c2834338174)
- [merrymen](https://merrymen.wtf/)
- [Terms of Use](https://noxacto.xyz/terms)
- [Privacy Policy](https://noxacto.xyz/privacy)
