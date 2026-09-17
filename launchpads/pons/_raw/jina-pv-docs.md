Title: Docs · PonsVault V2

URL Source: https://www.ponsvault.com/docs

Markdown Content:
## What problem this solves

When a pons token launches, the trading fees earned by its liquidity position accrue to a creator. That is good for the creator and neutral at best for everyone else: the value leaves the token the moment it is claimed.

A vault changes the destination. Instead of paying a wallet, the fees pay a contract with one job — the job you picked when you launched. That might be buying the token back and burning it, funding a prize pool, or paying stakers who lock up the token. The result is a launch where the rules are enforced by code rather than by the founder's word.

The short version

Trades create fees. Fees flow to your vault. The vault does what you told it to, every time. Anyone can press the button, and nobody can stop it.

## Contracts

Everything PonsVault V2 does happens in these contracts, on Robinhood Chain (4663). They are deployed once and reused by every launch — the only thing created per token is a small vault of your chosen template.

| Contract | What it does | Address |
| --- | --- | --- |
| `PonsV2VaultLauncher` | Launches a pons v2 token and attaches a vault, then points creator fees at that vault. | [0x1770…3dBA](https://robinhoodchain.blockscout.com/address/0x1770c356eB9312079b9A00e26a8CF4b0a1473dBA) |
| `PonsV2VaultRegistry` | Maps a template id to the factory that builds it. | [0xaA9C…46D5](https://robinhoodchain.blockscout.com/address/0xaA9C86049A258D4A076d3eF367F69C231C9746D5) |
| `PonsV2BuybackBurnVaultFactory` | Deploys one Buyback & Burn vault per token. | [0xdE46…62aB](https://robinhoodchain.blockscout.com/address/0xdE4670A2Be85Baa3f6a2C1F6443101EA041362aB) |
| `PonsV2StakingVaultFactory` | Deploys one Staking vault per token. | [0x1488…E7EB](https://robinhoodchain.blockscout.com/address/0x1488473464F2C6E6c5C412f05d805c619322E7EB) |
| `PonsV2RwaVaultFactory` | Deploys one RWA Dividend vault per token and fixes the distributor that posts round roots. | [0xE3Dd…C164](https://robinhoodchain.blockscout.com/address/0xE3Dd55a527D7408d21f6Cc2aA66A488a0177C164) |
| `PonsV2StakeBurnVaultFactory` | Deploys one Stake & Burn vault per token for the himgajria desk, and stamps the immutable payout asset. | [0x5374…B047](https://robinhoodchain.blockscout.com/address/0x537483c5B33e2192CfB202d7C50d58975524B047) |

Your own vault's address is shown on your token's page, and is also readable from the launcher by calling `vaultOf` with your token address. The source for all of them is on[GitHub](https://github.com/ponsvault/PonsVault).

### What we build on

These belong to pons and the chain. PonsVault calls them and cannot change them.

| Contract | What it does | Address |
| --- | --- | --- |
| `pons v2 factory` | Open launch factory. PonsVault calls it rather than replacing it. | [0x7eD5…EC7e](https://robinhoodchain.blockscout.com/address/0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e) |
| `pons fee escrow` | Holds claimable creator balances in the launch quote asset. | [0xd3AF…Ac9e](https://robinhoodchain.blockscout.com/address/0xd3AFEB2a57f70eF218Aa82451c51B2fb0416Ac9e) |
| `Uniswap v4 PoolManager` | Where graduated launches trade after the bonding curve. | [0x8366…0951](https://robinhoodchain.blockscout.com/address/0x8366a39CC670B4001A1121B8F6A443A643e40951) |

## How a vault earns

Every pons launch has its liquidity position held by a **locker** contract. The locker tracks a per-token `feeRedirect` address and pays the creator share of collected fees there, after deducting the pons protocol share.

Attaching a vault means setting that redirect to the vault's address. From then on, collected fees arrive at the vault as **WETH** — an ordinary ERC-20 transfer, not native ETH. When the pool has also accrued fees on the token side, the vault receives some of your token too.

That much is the same for every template. What happens next is the part you choose. Buyback & Burn, one of the two templates available today, runs this cycle:

```
// Buyback & Burn — one template, when triggered
1. sweep pending fees out of the pons locker
2. split the WETH by the configured burn share
3. swap the burn share for your token
4. send every token it holds to 0x…dEaD
5. forward any remainder to the treasury
```

This is the part worth understanding, because it explains why PonsVault performs your launch for you rather than bolting a vault onto it afterwards.

Receiving fees and _collecting_ them are two different permissions on the pons locker. The payout follows the fee redirect, but the call that sweeps fees out of the locker is only accepted from the token's on-chain `deployer`or from pons's own protocol fee recipient. A redirect target is not authorised — even though it is exactly where the money lands.

So a vault can receive fees but can never sweep them by itself. PonsVault closes that gap by launching the token through its own launcher contract, which therefore becomes the deployer. The launcher exposes an open sweep function, and that is what lets the whole cycle run without any privileged operator.

In practice you should not have to press anything. PonsVault runs a bot that checks every live vault every few minutes and triggers a run once the accrued fees clear your minimum and are worth more than the gas. It is a convenience, not a dependency: it has no special permission, and if it stopped tomorrow any holder could keep the vault running from the button on your token's page.

Attaching a vault to an existing token

Possible, but not fully automatic. The token's original deployer can point the redirect at a vault, and the vault will still distribute permissionlessly — but the sweep itself will keep needing that deployer's signature.

## Templates

A template is a vault contract with one job. You choose one at launch and configure it; the configuration is then fixed for the life of the vault.

### Buyback & Burn — available now

Spends a fixed share of incoming fees on a market buy and burns the result immediately, forwarding the remainder to a treasury address you nominate. Set the burn share to 100% and there is no treasury at all.

### Staking — available now

Pays incoming fees out to holders who stake the token, in proportion to how much each has staked. Rewards are WETH the pool actually earned, so nothing is minted and no supply is burned — and because staked tokens sit in the vault, supply leaves circulation for as long as people keep earning on it.

Staking is a deliberate deposit rather than an automatic dividend to every holder. Paying holders passively would need the token to notify the vault on every transfer, and pons tokens are plain ERC-20s whose fees come from the Uniswap pool rather than a transfer tax, so no such hook exists. Requiring a deposit is what makes the payout computable without one.

The creator may set a lock period at launch, counted from each staker's most recent deposit. It applies to principal only: rewards can be claimed at any time, lock or no lock. Like every other parameter, it cannot be changed afterwards.

### RWA Dividend

Converts creator fees (in the pairing asset) into a tokenized stock via Uniswap V3, which the vault holds until holders claim it. Holders earn by holding — there is nothing to stake and nothing to opt into. The token side of the fees is burned, as with Buyback & Burn.

Each purchase opens a round. Your share of a round is worked out from what you held at the moment it opened, so buying in afterwards does not dilute anyone already there. Rounds stay claimable for a fixed window; anything unclaimed after that rolls into the next round rather than being stranded.

The stock is chosen from a short list — GameStop, NVIDIA and SpaceX — and fixed forever at launch. The list is short because most tokenized stocks on this chain are barely traded on-chain: their pools exist but hold almost nothing, so converting fees into them would lose most of the value to price impact. Only assets with enough liquidity to convert a round at a fair price are offered, and each one is re-checked against the chain when you launch.

## Vault Seats

Separate from bonding-curve launches on[Launch](https://www.ponsvault.com/launch). Each **series** is an NFT collection plus its own fuel $TOKEN, with a shop, activation, fee pot, and loans. Product UI:[/seats](https://www.ponsvault.com/seats).

**Seat = NFT.****Fuel = that series’ $TOKEN** (ERC-20). Loop: Get $TOKEN · Trade · Activate · Distribute.

### What a series is made of

*   **Seat NFT** — numbered collectible; uploaded art is the NFT image.
*   **Seat wallet** — built-in wallet per NFT; rewards land here and move with the NFT on sale. Its address is fixed from the moment the series exists and can receive rewards straight away; the wallet contract itself is deployed the first time the owner spends from it.
*   **Fuel $TOKEN** — ERC-20 for buying seats and paying activation, never ETH. Every series launches its own on a pons v2 bonding curve in the same transaction that creates the series, so anyone can buy fuel with ETH (or an approved ERC-20 such as USDG) and the series has a real market from the first block. An ETH-paired curve takes the quote as transaction value, so buying fuel needs no approval first. A creator can buy the first fuel in that same transaction, which is the only way to hold any before the series is live.
*   **Shop (AMM)** — fixed $TOKEN price per seat, and the only contract that can mint one. Buy next, snipe a #, or sell back; seats sold back are resold before any new one is minted. Every trade also carries ETH, and all of it goes to the reward pot with no protocol cut: 10% of what a seat is worth to buy or sell, 15% to snipe. The contract cannot know what a seat is worth, so it enforces those percentages against a 0.01 ETH seat as a floor and the desk prices the real thing off the fuel curve.

### How to get a seat

1.   Hold the series fuel $TOKEN. Buy it on the series' own curve, straight from the desk — with ETH, or with the ERC-20 the curve is paired against.
2.   On the series desk: **Buy next** for the next NFT in line, or type a number and **Snipe** that exact # if nobody owns it yet (same $TOKEN price, higher ETH fee).
3.   Seats are minted as they sell, not up front, so you pay the gas for your own NFT (roughly 175k gas) and the creator never pays for seats nobody bought. It also means any series size launches for the same cost.
4.   **Activate** with $TOKEN (tiered) to join the payroll. Transfer clears activation.
5.   When the ETH pot bar is full, anyone can **Distribute** (pay gas). Activated seats share by tier; use **Deliver** to claim a seat’s share into its wallet.

### Desk features

*   **Buy / Snipe / Sell** — trade seat NFTs against $TOKEN + ETH fee.
*   **Activate** — stake a seat on the distribution payroll (tier weighted).
*   **Distribute / Deliver** — open a payout when the pot is full; push rewards to seat wallets.
*   **Borrow / Repay** — lock a seat NFT, borrow $TOKEN principal against it; repay or face liquidation after due. Borrowing carries the same ETH fee as buying a seat, split between the reward pot and the protocol.

### Who gets paid, and when

A payout round freezes its share table the moment it opens. Only seats already activated at that point can claim it, so activating after a round opens does not dilute anyone who was there first — you are simply in line for the next one. Changing your tier re-dates your seat for the same reason, so upgrade between rounds rather than during one. A round can never pay out more than the pot it was opened with, and whatever nobody claims within seven days rolls into the next pot instead of sitting stranded in the contract.

### Borrowing against a seat

A loan pays out **70% of the seat's shop price** in $TOKEN and locks the NFT in the loan vault for the term. Repay the principal and the seat comes back. Miss the deadline and anyone can liquidate it — but a liquidator has to pay the principal into the vault to take the seat, so they are buying a seat worth full price for 70% of it. That discount is the incentive to liquidate, and it is why defaulting costs you the seat rather than paying you.

### PonsVault Originals

The house art pack, for creators who do not want to make their own art. Twelve animals rendered in eight light grades: _Golden Hour_, _Sunrise_,_Overcast_ and _Dusk_ stay photographic, while _Moonlit_,_Ash_, _Aurora_ and _Prism_ get progressively rarer and more stylised. An Originals run is a fixed **1111 seats** — the rarity table allocates exact counts for that number, so it is not configurable.

Rarity is dealt by exact allocation, not per-seat dice rolls: 333 Golden Hour, 222 Sunrise, 178 Overcast, 155 Dusk, 111 Moonlit, 56 Ash, 44 Aurora, 11 Prism, and a single **1 of 1**, shuffled with a random per-series salt. Every series deals a different hand from the same deck. The artwork is pinned once and shared by every Originals series, so launching on it needs no upload and no wait; only the per-series metadata folder is written at launch.

The 1 of 1 sits outside the animal × light grid and is never colour graded, so it has no near-misses: exactly one seat in the run holds it. It is also the image the series itself leads with.

### Visible from the first sale

Every series is created against its real metadata folder, so `tokenURI`returns a seat’s own art the moment it is minted. There is no placeholder card and no reveal step: a buyer sees exactly what they are buying as they buy it.

The tradeoff is worth stating plainly. Because the pack is public before the first sale, so is the number holding the 1 of 1, and `snipe` lets anyone buy that exact seat for the ordinary price plus the 15% snipe fee. Expect the rarest seat in an Originals run to go early and on purpose.

The collection can still sell sealed — pass a `provenanceHash` to`createSeries` and it holds a placeholder until `reveal` is given a URI that hashes to it. Nothing launched from this app does, so the reveal path only matters for a series created by calling the factory directly.

### For developers

Create from[/seats/create](https://www.ponsvault.com/seats/create): name, ticker, art (Originals or your own image), supply, $TOKEN seat price, and where fuel comes from. `createSeries` deploys the NFT collection, shop, activation, booster pot, and loan vault in one call.

A series has to point at fuel that already exists, so creating one is naturally two calls. Wallet batching can sign two calls as one confirmation, but only on chains the wallet has enabled it for, which is why `PonsSeatLauncher`does both inside a single contract call instead: it launches the fuel, buys the creator's first fuel on the curve it just made, and calls `createSeries` with the real address. One confirmation on every wallet, all of it or none of it, and no half-finished launch to recover from. Only an ERC-20 pair adds a second prompt, for the approval.

Nothing that carries rights is attributed to the launcher: the fuel token's creator fees point at the caller, the first buy is delivered to them, and the series is registered in their name through `createSeriesFor`, which the factory accepts from that one address. pons' own `deployer` field is the exception — it is whoever called `launchToken`, and only pons' configured forwarder may name someone else. It carries no rights: the factory records it and never checks it, while fees and every creator action are gated on the creator fee recipient, which is the creator.`npm run seats:check-batch` runs it on a fork and asserts each of those. Addresses live in `src/lib/seats/deployments.ts`, updated after`DeployPonsSeats`. Set `PONS_ORIGINALS_ART_CID` after`npm run originals:pin` so Originals launches skip the art upload.

## Parameters

Every template exposes its own settings, named here as they appear in the launch form. They are written once, when the vault is created. None of them has a setter, so none of them can be changed later — not by you, and not by us.

There is no schedule to set

A vault has no timer. A run spends everything it is holding, so the next one cannot happen until trading has refilled it past your minimum. That single number is what sets the pace — busy tokens act often, quiet ones rarely, and neither needs a clock.

### Buyback & Burn

| Setting | What it controls |
| --- | --- |
| Burn share | How much of each batch of fees is spent buying and burning. At 100% there is no treasury at all. |
| Treasury | Where anything not burned is sent. Required unless the burn share is 100%. |
| Minimum fees before a run | How much has to build up before a buyback can happen. The only thing pacing the vault: set it higher and it buys less often, in bigger amounts. |

### Staking

| Setting | What it controls |
| --- | --- |
| Lock period | How long a stake is held, counted from each staker's most recent deposit. Zero means people can withdraw whenever they want. Rewards are never locked. |
| Minimum fees before a payout | How much has to build up before stakers are paid. Set it higher and payouts come less often, in bigger amounts. |

## Security model

Making the trigger public is what makes a vault credible, and it is also what makes it attackable. Any template that trades on demand is an invitation to move the pool first and sell into it. Using Buyback & Burn as the worked example, here is exactly where that leaves you.

*   **The buyback has no price check.** It buys at whatever the pool quotes in that block, with no average to compare against and no floor of its own. A buyback that lands alongside a large trade — including one placed deliberately to bait it — will buy at that price.
*   **A caller-supplied floor, if you want one.** Whoever triggers the run may pass a minimum number of tokens the swap must return, which aborts the whole run instead of accepting a bad fill. This site and our bot pass none.
*   **A bounded loss.** A run can only ever spend fees that have actually accrued, so the most at stake in any single run is one batch of fees — never the treasury, and never the liquidity.

Your harvest minimum is therefore doing double duty: it sets how much of a target each run represents. A larger minimum means fewer, larger buybacks, and a larger prize for anyone willing to try for it.

Beyond the swap itself, the vault never takes custody of anything it can misdirect. It holds no launch funds, cannot touch the liquidity position, and has no function that transfers assets to an address you did not configure at creation.

### Upgrades

Vaults are deployed behind a shared beacon, so a defect can be fixed for every existing vault at once without asking anyone to migrate. That is real power, and it is deliberately removable: the beacon's owner can renounce control permanently, after which no vault can ever be changed again.

## Limits & caveats

Things worth knowing before you launch, including a few sharp edges we found while testing against the live chain.

*   **A buyback moves the price it buys at.** On a thin pool, spending a batch of fees in one swap pushes the price up as it fills, so the tokens burned are worth less than the WETH spent. Larger, less frequent runs feel efficient but suffer this more, not less.
*   **Burning is a two-step move.**In Buyback & Burn, pons tokens reject a swap that delivers straight to the burn address, so the vault buys into itself first and then transfers out. The end state is identical; it just costs slightly more gas.
*   **Fresh launches have trading limits.** pons applies per-transaction and per-wallet caps for a window after launch. Very early buybacks can bounce off those caps until the window closes.
*   **A vault is not a price guarantee.** Burning supply does not create demand. Whichever template you pick, it is funded by trading — if nothing trades, no fees accrue and the vault does nothing.
*   **Audit status.** The vault contracts are tested against live chain state but have not yet completed a third-party audit. Treat early launches accordingly.

Never share your seed phrase

PonsVault will never ask for it. Launching only ever requires a signature from your own wallet — review the token address and transaction preview before you sign.

## Next steps

[Launch a token with a vault](https://www.ponsvault.com/launch)[Explore launches](https://www.ponsvault.com/explore)

Links/Buttons:
- [Home](https://www.ponsvault.com/)
- [Explore](https://www.ponsvault.com/explore)
- [Stats](https://www.ponsvault.com/stats)
- [Seats](https://www.ponsvault.com/seats)
- [Launch](https://www.ponsvault.com/launch)
- [Docs](https://www.ponsvault.com/docs)
- [X](https://x.com/ponsvault)
- [pons v2](https://docs.ponsfamily.com/v2)
- [Overview](https://www.ponsvault.com/docs#overview)
- [Contracts](https://www.ponsvault.com/docs#contracts)
- [How a vault earns](https://www.ponsvault.com/docs#vaults)
- [Who can trigger it](https://www.ponsvault.com/docs#authority)
- [Templates](https://www.ponsvault.com/docs#templates)
- [Vault Seats](https://www.ponsvault.com/docs#vault-seats)
- [Parameters](https://www.ponsvault.com/docs#parameters)
- [Security model](https://www.ponsvault.com/docs#security)
- [Limits & caveats](https://www.ponsvault.com/docs#limits)
- [0x1770…3dBA](https://robinhoodchain.blockscout.com/address/0x1770c356eB9312079b9A00e26a8CF4b0a1473dBA)
- [0xaA9C…46D5](https://robinhoodchain.blockscout.com/address/0xaA9C86049A258D4A076d3eF367F69C231C9746D5)
- [0xdE46…62aB](https://robinhoodchain.blockscout.com/address/0xdE4670A2Be85Baa3f6a2C1F6443101EA041362aB)
- [0x1488…E7EB](https://robinhoodchain.blockscout.com/address/0x1488473464F2C6E6c5C412f05d805c619322E7EB)
- [0xE3Dd…C164](https://robinhoodchain.blockscout.com/address/0xE3Dd55a527D7408d21f6Cc2aA66A488a0177C164)
- [0x5374…B047](https://robinhoodchain.blockscout.com/address/0x537483c5B33e2192CfB202d7C50d58975524B047)
- [GitHub](https://github.com/ponsvault/PonsVault)
- [0x7eD5…EC7e](https://robinhoodchain.blockscout.com/address/0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e)
- [0xd3AF…Ac9e](https://robinhoodchain.blockscout.com/address/0xd3AFEB2a57f70eF218Aa82451c51B2fb0416Ac9e)
- [0x8366…0951](https://robinhoodchain.blockscout.com/address/0x8366a39CC670B4001A1121B8F6A443A643e40951)
- [/seats/create](https://www.ponsvault.com/seats/create)
