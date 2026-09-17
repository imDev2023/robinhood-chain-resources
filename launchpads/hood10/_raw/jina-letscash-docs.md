Title: docs: how the contracts work · letscash.fun

URL Source: https://letscash.fun/docs

Markdown Content:
docs

## the machine,

opened up

How the letscash contracts actually work: launch modes, the fee lifecycle, self burns, bounties, and every function you can call yourself from a wallet, a script, or a bot. Everything here is verifiable on chain.

factory

The launcher. One transaction deploys the token, creates and seeds the Uniswap v4 pool, locks the liquidity, and runs your first buy. Upgradeable behind a proxy so new launch modes can ship. But it holds no funds and has no power over tokens already launched.

hook

The fee engine, riding inside every swap via Uniswap v4 hooks. Collects each pool's tax on every buy and sell in whatever that pool is priced in (ether or USDG, never the memecoin itself), and holds it until swept. It also rejects every attempt to remove pool liquidity, so the liquidity lock is enforced here, immutably, beyond any upgrade, including ours.

token

A fixed-supply ERC-20, ownerless after launch, with its logo, description, and socials stored on chain. Every address ends in "cc", enforced by the factory, whoever launches. Any holder can burn()their own tokens, which genuinely reduces total supply.

deployed n/a

one per launch · see any token page

self burner

Fee recipient for self-burn launches, registered at launch in place of a person, so the creator of a self-burn coin earns nothing and has nothing to claim. It market-buys the token on its own pool and destroys it. No owner, no withdrawal path, no way to redirect, and it pays a bounty to whoever triggers it.

revenue splitter

Where the platform's share of every trade lands. It divides what arrives three ways: a quarter buys CASHCAT on the open market and sends it to the dead address, a quarter buys CASHCAT for the treasury, and the rest pays for running the platform. Both buys are public functions that pay a bounty to whoever calls them, so the burning is driven by whoever wants the fee, not by us.

## launch modes

A launch mode is a config on the factory: picked at launch, burned into the pool forever. New modes are added as new configs, without redeploying anything or touching existing tokens.

standard · the tax token

A trading tax of 1%, 3%, 5% or 10%, chosen at launch and collected in whatever the pool is priced in: ether or USDG, never the coin itself, so nobody has to sell it to get paid. The creator's share accrues to the fee stream; the platform keeps 0.3% of the trade at every rate. The rate is public on the token page and on the card, and cannot be raised afterwards by anyone, including us.

self burn

A flat 1% with zero creator take, and no rate to choose: the creator's share buys the token on its own pool and destroys it, and the platform still keeps 0.3%. Total supply drops on chain, so explorers show it shrinking rather than a dead-address wallet growing. The fee stream is registered to the burner contract at launch, and this is the one mode where it can never be pointed anywhere else. The burner has no call that would move it.

### picking the rate

Four rungs, and the platform's cut is the same 0.3% of the trade on all of them. That is the part worth reading twice: the creator's share is not a fixed proportion of the fee, it is solved backwards from a constant platform slice, so every point of a higher rate belongs to the creator lane and none of it to us.

The ladder is the standard mode's. A self-burn launch is fixed at 1% and has no rate to pick: the share it would have chosen is not income to anybody, it is what the burner spends buying the coin back, and a coin that taxes its own traders harder to buy itself faster is a tradeoff nobody was asking to make.

A higher rate earns more per trade and gives traders more reason to trade something else; that trade-off is the creator's to make and it is made once. The ceiling is 10%, and it is enforced in the hook, a contract that cannot be upgraded. The old ceiling was 90%, in a contract that could be.

| rate | creator | platform | creatorFeeBps |
| --- | --- | --- | --- |
| 1% | 0.7% | 0.3% | 7000 |
| 3% | 2.7% | 0.3% | 9000 |
| 5% | 4.7% | 0.3% | 9400 |
| 10% | 9.7% | 0.3% | 9700 |

standard launches only. self burn is fixed at 1%

the live mode list is on chain. enumerate it yourself:

Two things about the ids. They begin at 1,000, because the factory address never moved and ids beginning at zero would have been reissued for entirely different launch modes. The original eighteen are retired and revert. And the tuple gained a`quote` at the front: a pool trades against ether or against USDG, and everything it reports (price, market cap, fees) is denominated in whichever it chose. Decoding it with the old shape does not throw. It returns the wrong fields.

// ids start at FIRST_CONFIG_ID, not at zero
factory.FIRST_CONFIG_ID() → uint256   // 1000
factory.configCount()     → uint256   // one past the last id

factory.getLaunchConfig(configId) → (
  moduleSetId, quote, supply, tickSpacing,
  startTick, creatorFeeBps, feeRate,
  enabled, selfBurn, exists)

// CAREFUL: a launch may name its own supply,
// so this row's `supply` is NOT necessarily
// what the coin minted. For that, read the
// token, or the event below.
token.totalSupply()                → uint256
TokenLaunchedSized(token, poolId,
  supply, startTick)

## airdrops you can check

beta version

Creators promise airdrops and then do not do them. There is no way for a buyer to tell an honest promise from a lie, so the market prices every promise the same way: at nothing. This is an attempt to make the honest version provable.

A creator can send an agreed share of their own first buy into a vault attached to the launch. Nobody can withdraw from it. Not the creator, not us. Tokens leave it one way only: along a recipient list published on chain in advance, after a 5-minute countdown, and the payment can then be triggered by anyone. If no list is ever published, everything in the vault is destroyed after 7 days.

what it does and does not promise

It guarantees **disclosure and irreversibility, not fairness.** A creator may publish a list naming a single wallet they own, wait out the countdown, and pay themselves. That is allowed, it cannot be prevented by any contract, and a system claiming otherwise would be selling a guarantee it does not have. What the vault removes is doing it _quietly_: the destination, the amounts, the recipient count and the countdown are all public before a single token moves, and the record is permanent. When a list names one address, the coin's page says so in those words rather than calling it an airdrop.

### the four stages

Every airdrop moves through the same four, and the coin's page shows which one it is at.

01 · locked

The share is taken out of the creator's first buy inside the launch transaction and lands in the vault. It is a share of that buy, not of total supply. This is the only irreversible decision, and it is made before the coin is tradable.

02 · list

The creator publishes who gets what. The entire list is committed in the first transaction as a single hash, so they cannot watch the market react to part of it and change the rest. Large lists arrive in numbered parts. Until the last part lands they can abandon the draft, and after it they cannot.

03 · notice

5 minutes in which the full list is public and nothing can move. Nobody can alter it during the wait, including the creator. This is the window in which a holder can read the list and decide what they think of it.

04 · payout

Anyone can pay it out. The creator has no special standing, nobody is paid for doing it, and the payment runs in batches of up to 500 recipients that can be run in any order by different people. A campaign nobody finishes is not a campaign its creator can quietly abandon.

### building the list

Bring the recipients however you have them. Give us another token's address and we read its holders at a named block, and that block and its hash go into the published record so anybody can check the list against an archive node afterwards. Or paste a list, upload a CSV, TSV or JSON export, or name a single address. Columns are worked out and shown back to you before anything is signed.

Amounts can be split in proportion to holdings or evenly, with an optional cap and floor per wallet, or taken from your own file. Addresses that cannot use a payout are found and excluded by default: **the largest holder of any traded token is its own liquidity pool,**and paying one is tokens added to an exchange's balance that nobody can withdraw, while the distribution reports success. Bridges, burn addresses and other vaults are caught the same way. You can put any of them back, but you have to choose to.

this is version one

The vault contract is fixed for every launch that uses it, and a coin launched today keeps exactly the rules it was born with, forever. But the design is new and the way we build lists, the tooling around it and the interface will change as we learn what creators actually do with it. Later versions may work differently. That does not reach back: an airdrop already published pays out under the terms it was published with, and nothing we deploy later can alter it.

## coins priced in dollars

A launch picks what its pool trades against: ether, or USDG, a dollar stablecoin. The choice is made once and cannot be changed. A pool's denomination is part of what a holder bought.

what changes

*   · The price is a dollar price. A USDG coin at $0.000005 means that, not an ether figure converted for display.
*   · Fees are taken in USDG and paid out in USDG. A creator on a USDG pool is paid dollars, not ether.
*   · The first buy is USDG, so the launch spends both assets: the launch fee is still ether, the buy is not.
*   · Launching is still one transaction. The creator signs an allowance rather than sending a separate approval, and the factory spends it in the same call.

what does not

*   · The platform still keeps 0.3% of every trade, at every rate, in both quotes.
*   · Liquidity is still locked at launch and can never be removed.
*   · Self-burn still works: the creator share buys the coin back and destroys it, paying in USDG instead of ether.
*   · The platform's own revenue still ends up as ether. A converter sells the collected USDG at a price checked against the pool's own time-weighted average, and the proceeds go to the treasury exactly as before.

One consequence worth stating plainly: a USDG coin's market cap and an ether coin's are not the same unit. Everywhere the board compares them (sorting, trending, filters), it converts first. What it shows you is dollars in both cases.

## fees that pay more than one person

A launch can name up to four recipients and the share each one takes. The shares are fixed when the coin launches and can never be changed afterwards: not by the creator, not by the other recipients, not by us. There is no admin function, because there is no admin.

how a recipient gets paid

1.   1 · divide.Anyone can call it, and the platform's keeper does on a timer. It pulls the coin's accrued fees out of the hook and credits each recipient their share. Nobody has to wait on anyone else.
2.   2 · collect. Each recipient takes their own balance, whenever they like, to whatever address they name. Only they can trigger it.

It is two steps rather than one because paying everyone automatically would let a single recipient block the rest: one address that cannot receive the asset, and every payout in the loop reverts. Pulling means a broken recipient breaks only themselves.

A recipient can also move their own slot to a new address, and their pending balance travels with it. Only the holder of that slot can do so. A creator who promised a charity 25% cannot take it back.

// params carries the size: params.supply is a
// whole number of coins from 1e9 to 1e15,
// or 0 to take the config row's own figure

// no split: the stream pays one address
factory.launch(params, configId,
  firstBuyIn, firstBuyMinOut, salt)

// one to four recipients, shares in bps,
// summing to 10000
factory.launchWithFeeSplit(params, configId,
  firstBuyIn, firstBuyMinOut, salt,
  recipients, shares)

// same, pulling a USDG first buy with a
// signed permit: one transaction, no approve
factory.launchWithPermit(params, configId,
  firstBuyIn, firstBuyMinOut, salt,
  recipients, shares, permit)

// anyone, any time: pulls this pool's fees
// out of the hook and credits every slot
launchSplitter.distribute()

// the holder of a slot, and only them
launchSplitter.owed(you)   → uint256
launchSplitter.collect()      // to yourself
launchSplitter.collect(to)    // anywhere
launchSplitter.rotate(newAddr) // hand the slot on
shares are basis points and must total 10,000 exactly. the contract refuses anything else, including a zero share and the same address twice.

## where every fee goes

1 · trade

Someone buys or sells, through any router or bot. The hook takes the pool's tax inside the swap itself, in whatever that pool is priced in: ether, or USDG. There is no way to trade around it.

2 · pending

It sits in the hook, per pool, publicly readable at hook.pending(poolId). Nothing has been paid to anybody yet.

3 · sweep

sweep(poolId) is callable by anyone, and splits the pot in two: the platform's 0.3% into its own lane, and the rest onto the pool's fee tab. Neither side can block the other. We call it to collect our cut exactly as anyone else can.

4 · pay out

The tab goes to whoever holds that pool's fee stream, and that is not always a creator. It is one of four, and the token page says which.

where the fee tab actually goes

Sweeping does not pay a creator. It banks the fee against whoever holds that pool's stream, and the holder is set at launch and can change afterwards. There are four kinds of holder.

the creator The ordinary launch. Whoever launched the coin claims it, in the pool's own asset, whenever they like.

a wallet the creator named Chosen in the launch call, before the token existed, so no fee ever accrued to the launcher first. It can still be handed on later by whoever holds it.

a launch splitter Two to four recipients on fixed shares. distribute() pulls the tab out of the hook and credits every slot at once; each holder then collects their own, to any address. One recipient who cannot receive the asset blocks only themselves.

the self burner Nobody is paid. The burner spends the tab buying the coin on its own pool and sending it to the dead address, so supply falls. This is the one holder that can never be changed.

on a USDG pool

The fee is taken in USDG, and the stream is paid in USDG. A creator of a dollar-quoted coin earns dollars and claims dollars: nothing converts on the way, and nobody has to accept a swap they did not ask for. The same is true of a split, where every slot collects in USDG.

The platform's 0.3% is the part that moves. It books against USDG in the hook, and a public`convert`call sells it for ether through a Uniswap v3 route, priced against that route's own TWAPs, and sends the ether to the treasury. So the treasury holds one asset and the revenue ledger stays denominated in one thing.

The conversion deliberately sits outside the swap. Converting during a trade would make every trade in one pool depend on the depth of another, and a thin moment over there would revert a trade over here. It books first and sells later, on its own schedule, and a stale or starved oracle stops the sale rather than the trading.

what the platform's 0.3% does

The same in every mode, on every token. It lands on the revenue splitter and divides three ways:

a quarter buys CASHCAT on the open market and burns it

a quarter buys CASHCAT for the treasury

the rest runs the platform: servers, infrastructure and development

the two CASHCAT buys are public functions that pay the caller a bounty, so anyone can trigger them and watch the tokens leave. see the[tokenomics page](https://letscash.fun/tokenomics)for the live numbers.

## the fee stream is an asset

On standard tokens, the creator's share isn't welded to the wallet that clicked launch. It's a transferable claim on future fees. One call hands the whole stream, including anything unclaimed, to a new address. Most launchpads don't let you do this; here it's a first-class part of the design:

*   Only the current recipient can move it, and the handoff is final: the new address takes full control, including the right to hand it on again.
*   It moves who gets paid, never what traders pay: the tax rate, the platform's 0.3%, and the locked liquidity are immutable no matter how many times the stream changes hands.
*   Every handoff is public the instant it happens: a CreatorUpdated event on chain, and the app follows it: the claim flow always keys on the current recipient, not launch history.

What it's for: launch from a hot wallet and park the revenue in your team multisig. Hand a project to new owners with its income attached. Let a community takeover actually take over: dead token, live fee stream, one transaction. Or point it at a contract: a splitter, a vault, a bot. Self-burn tokens are the exception: their stream is owned by the burner contract and locked to burning, forever.

naming the recipient before the coin exists

Handing the stream on afterwards and naming somebody at launch are not the same promise, and the difference is the window between them. Launch, then transfer, and fees accrue to the launcher until the transfer lands, and on a hyped launch that window is exactly when the volume is.Naming the destination in the launch call closes it: the stream belongs to that address from the first trade, and nothing was ever the launcher's to keep. A token raising for a charity can be a fact rather than an undertaking.

One named address goes straight into the hook and can still be handed on later. Two or more get a splitter, and those shares are the part nobody can edit afterwards.

claiming somewhere else

Claiming and holding are separate too. The recipient names where the money lands, which matters when the recipient is a contract that cannot receive ether, or a multisig you would rather not route every payout through. Holding the stream is what authorises the claim; it is not where the claim has to go.

// current recipient only
hook.updateCreator(poolId, newAddr)

// unclaimed fees travel with it
// newAddr can claim, or move it again
// the tax itself never changes// what is waiting, and where it can go
hook.pending(poolId)  → uint256
hook.tab(poolId)      → uint256

hook.claim(poolId)      // to yourself
hook.claim(poolId, to)  // anywhere// watch it happen
event CreatorUpdated(
  poolId,
  oldCreator,
  newCreator
)

## self burn, in detail

1.   01 · trading accrues the creator share as burn fuel in the hook, exactly like a standard token accrues creator fees.
2.   02 · anyone calls burn(poolId) on the burner. It claims the fuel, pays the caller a 1% bounty of the claim, and market-buys the token with the rest.
3.   03· the bought tokens are destroyed via the token's own burn(): total supply drops for real, visible on any explorer.
4.   04· the burn's own swap pays the pool's tax too, so a small residue re-arms the next burn and feeds the CASHCAT burn.

The bounty is what makes burns self-driving: the moment a pool's fuel covers gas plus profit, it's rational for anyone (keeper bots, traders, holders) to pull the trigger. Busier tokens burn more often, automatically. Every self-burn token page shows the accrued fuel and a burn button that pays the bounty to your wallet.

burner.burn(poolId)
  → claims accrued fuel
  → pays caller 1% bounty
  → buys token on its pool
  → token.burn(amount)
  → returns tokensBurned// watch it happen
event Burned(
  poolId, token,
  ethIn, tokensBurned,
  bounty
)

## we're hiring keeper bots

No employer, no application. The machine runs on public functions that pay their caller, and "hiring" means the bounties are real and yours to take. letscash runs its own keeper as a backstop, but it deliberately waits before acting on every newly available step, so independent keepers always get first claim.

the bounty board

*   Trigger self burns:burn(poolId) on the self burner pays 1% of every claim it converts. Busier tokens accrue faster, so the board refills itself.
*   Trigger CASHCAT buybacks:the revenue splitter's two buy functions each pay the caller 1% of the chunk they spend: one burns what it buys, one fills the treasury. The live tank sits on the[tokenomics page](https://letscash.fun/tokenomics).
*   Sweep any pool:sweep(poolId) is open to anyone. It pays no bounty, but it settles the split, worth knowing if you are waiting on a claim of your own.

A minimal keeper is a loop: read the pending fuel on the pools you care about, call the trigger when it clears your gas cost, collect the bounty. Gas on this chain costs a fraction of the bounties, and nothing here needs an allowlist, a key or our permission.

// self burns: is there fuel yet?
hook.pending(poolId)
burner.burn(poolId)   // pays you 1%// CASHCAT lanes, on the splitter
revenueSplitter.allocate()     // divide what has arrived
revenueSplitter.burnTank()     // fuel in the burn lane
revenueSplitter.buyAndBurn()             // pays you 1%
revenueSplitter.buyForCashcatTreasury()  // pays you 1%

## build on it

The site is one client. Everything it does, your script or bot can do directly against the contracts: launching, trading, claiming, sweeping, burning.

launch a token (with the …cc stamp)

// 1. find a salt whose address ends in "cc" (free view call)
(salt, token) = factory.mineSalt(params, configId, you, randomStart, 4096)

// 2. launch: msg.value must equal launchFee + firstBuyIn exactly
factory.launch{value: fee + firstBuy}(params, configId, firstBuy, minOut, salt)
// simulate via eth_call first: returns (token, poolId)

// params.creator must be the caller: creator identity is earned by
// signing the launch. Launching for someone else? You launch, then
// hand them the stream with updateCreator.
// the factory rejects any salt whose address lacks the stamp,
// and salts are bound to the sender, nobody can steal yours

collect fees, programmatically

hook.pending(poolId)   // accrued, unswept. anyone can read
hook.tab(poolId)       // swept and waiting for the stream holder
hook.sweep(poolId)     // anyone: bank it, and push the
                       // platform's share on. divides the fee
                       // between the two lanes, NOT between
                       // the recipients of a split
hook.claim(poolId)     // stream holder only: sweep, then pay
                       // the tab in the pool's own quote
hook.claim(poolId, to) // ...to an address of their choosing
hook.updateCreator(poolId, addr)  // stream holder only:
                                  // hand the whole stream on

Tokens trade on standard Uniswap v4 rails: any terminal, aggregator, or bot on the chain can trade them with zero integration, and the tax applies identically wherever the trade comes from. One rule for exotic flows: when the priced asset is the exactly-specified side of a swap, the tax is charged on that specified amount, so a tight price limit that would only partially fill reverts instead of overtaxing you. Fills are all-or-nothing.

## verify everything

Nothing on this site is self-reported. Every number is derived from chain events and checkable against the contracts' own state:

TokenLaunched every launch: token, creator, pool, config

TokenLaunchedSized what each launch actually minted, and where its pool opened

FeesSwept every settlement: creator + platform amounts

CreatorFeesClaimed every fee-stream payout, in the pool's own asset

CreatorUpdated every fee-stream handoff: old and new recipient

Burned every self burn: what was spent, tokens destroyed, bounty

Allocated every division of the platform's share into its lanes

Bought every CASHCAT buy: ETH spent, tokens out, where they went

Links/Buttons:
- [24](https://letscash.fun/profile/0x24da5e4417429f6cac34c1a09d65ebb4d6682864)
- [52](https://letscash.fun/profile/0x52ce7209888697aaf4bcc2a79a4a4dab500629f2)
- [77](https://letscash.fun/profile/0x774d1360e9ea45b23e64142395df6225d9ffee84)
- [96](https://letscash.fun/profile/0x96b1e87d39f3a0b35c764178f18539dc32d63374)
- [letscash.fun](https://letscash.fun/)
- [Profile](https://letscash.fun/my)
- [Leaderboard](https://letscash.fun/leaderboard)
- [Tokenomics](https://letscash.fun/tokenomics)
- [Docs](https://letscash.fun/docs)
- [Launch a coin](https://letscash.fun/launch)
- [HOOD10$2.37M▼19.4%](https://letscash.fun/token/0x0D257cA40d40090BE60C2d2Ed5bB3535392838cc)
- [CAT9$107.2K▲3,041%](https://letscash.fun/token/0x80D52Ae2de360a6608B8Ef80a086C2d4A4c99Dcc)
- [INTERN$195.3K▼21.5%](https://letscash.fun/token/0x3aE3faCC99F43D5A39254A0b9f5cc0291ECd39cc)
- [WINK$197.5K▲83.6%](https://letscash.fun/token/0x8ad5A580c4215086Dec828d8626b95A06D7D00cc)
- [PURRS$156.1K▲158%](https://letscash.fun/token/0x65FA36Fe3c0f4beB9d793cd9a79C7F53ef4b82cc)
- [9TO5$230.1K▼12.8%](https://letscash.fun/token/0x223E93B1beD7de244445dB2dea4c7900e8045Acc)
- [GATO$78.5K▲91.5%](https://letscash.fun/token/0x3b7157B6409380E09A131b631dFb8dFD2781D9cc)
- [LONGCAT$71.0K▲110%](https://letscash.fun/token/0xFD453d9bAB9F807165Cd3464aC6c9700ad9eE5cc)
- [PIT$3.6K▲7.1%](https://letscash.fun/token/0x566b25B7108F7D308cDaaB9Df32b1f4c444eDbcc)
- [BTCAT$8.9K▲154%](https://letscash.fun/token/0x781Cf79DA6137350b00b3f8c579aBBc756376fcc)
- [KILROY$3.3K▼9.7%](https://letscash.fun/token/0x192B358B5B91a6A8C5ECA1d8821BC422d42752cc)
- [VIBECAT$70.9K▲92.6%](https://letscash.fun/token/0xDCbAd959F69B6d2D04d46eBD2e17aA3DbFef16cc)
- [ROBINHOOD$97.1K▲59.2%](https://letscash.fun/token/0x3529E5B86e8749c8487a11ddc239C412228A40cc)
- [FEFI$115.6K▲38.0%](https://letscash.fun/token/0x6342e7fB1c98df507A8c846E49962D3E5e197ecc)
- [CHUDCAT$40.4K▲24.6%](https://letscash.fun/token/0xAa4BDcbcBaeb49D6b896caa82482850995ED72cc)
- [CryingCat$66.1K▲44.8%](https://letscash.fun/token/0x4F0d7ea112547Af5dAD59959d98B6A8ee3355Bcc)
- [↗](https://robinhoodchain.blockscout.com/address/0x67ccBfb238047D62736265b3093a5989836794B0)
- [explorer ↗](https://robinhoodchain.blockscout.com/)
- [how it works, in plain words](https://letscash.fun/about)
- [𝕏@letscashfun](https://x.com/letscashfun)
- [Legacy coins](https://legacy.letscash.fun/)
- [](https://letscash.fun/profile/0x272f44f9dd56000a4d74d69a7fc8d76c5df4ac50)
- [@ysolatetly](https://x.com/ysolatetly)
- [$CASHBIRD](https://letscash.fun/token/0x91554e79a17C18990034D1ec3C4f492086d7b2cc)
- [$CURSE](https://letscash.fun/token/0x9efE124ac1Ce5E54A011437AEDACFc12CbCDE9cc)
- [position$GAMBLINGCAT17,600,954 held▲65.5%in $60now $100+$40bought at $3.4K cap→now $3.4K](https://letscash.fun/token/0x0CB9a80eB2f32f4E8D51467bfBd2AF84AD59b7cc)
- [toAnindo](https://letscash.fun/profile/0xa8dc6238e3253b8270489630f5044be6f1c36542)
- [proof](https://robinhoodchain.blockscout.com/tx/0x0f7fb22745081d2e8e3e9132e7026f48dca48ea97e660d3d8ac221d113def618)
- [5e](https://letscash.fun/profile/0x5e58619761798f91f8df5b5715e3c1f51eed0f05)
- [@pogasour1](https://x.com/pogasour1)
- [f7](https://letscash.fun/profile/0xf7d352757f0518b955f7050f5f92df6ae656747d)
- [0xc81010400a5c140DDa0D93634A19940cf2d267cc](https://letscash.fun/token/0xc81010400a5c140DDa0D93634A19940cf2d267cc)
- [https://x.com/cursedcatmeow/status/2092385675924602959?s=20](https://x.com/cursedcatmeow/status/2092385675924602959?s=20)
- [on xcursed cat@cursedcatmeowCheck your portfolios, 1st $rivn payout is live! This is the 1st ever payout of $rivn stock from holding a memecoin on @RobinhoodCrypto. The technology from @TheIndexFi and $CASHCAT team/launchpad @letscashfun is amazing.@hellojintao how much rivn did you get!!!](https://x.com/cursedcatmeow/status/2092385675924602959)
- [@realAnindo13](https://x.com/realAnindo13)
- [0xC9d0DA9b65655d33D408c2A71e9F14642f1848cc](https://letscash.fun/token/0xC9d0DA9b65655d33D408c2A71e9F14642f1848cc)
- [0x170376E0622c077beF5Aa49EfeAe7EDC975f96cc](https://letscash.fun/token/0x170376E0622c077beF5Aa49EfeAe7EDC975f96cc)
- [a0](https://letscash.fun/profile/0xa06ea89c1ff61b6665811a12ffef7f10a7539bfc)
- [0x598ba26486ce3bf36e666b224134f15b52f73dcc](https://letscash.fun/token/0x598ba26486CE3Bf36e666b224134F15B52F73dcc)
- [d5](https://letscash.fun/profile/0xd53ef5112248a379532f3e05f1edfac965ea7b5c)
- [0xA21334e0553094670BD22e1AE4fF00F7f8d2C6cc](https://letscash.fun/token/0xA21334e0553094670BD22e1AE4fF00F7f8d2C6cc)
- [https://x.com/trenchfundbot/status/2092524611196063775?s=20](https://x.com/trenchfundbot/status/2092524611196063775?s=20)
- [on xTrench Fund Manager@trenchfundbot$TFM stats since live 0.993 ETH + 0.133 Unrealized gained including moon bags paid tips to callers reciept below all done publicly we are live just 12d ago, the stats is looking good let's fund the trenches](https://x.com/trenchfundbot/status/2092524611196063775)
- [$funcat](https://letscash.fun/token/0x1bE34E1446CB19E6794eE526727C9e63aDc4d0cc)
- [https://legacy.letscash.fun/token/](https://legacy.letscash.fun/token/)
- [0x6e17153e7B0AE7387d9B44F56291A4EF02CB14cc](https://letscash.fun/token/0x6e17153e7B0AE7387d9B44F56291A4EF02CB14cc)
- [8e](https://letscash.fun/profile/0x8e1f7a6315ab27b351055823a30168524b8c0f31)
- [$DOGMODE](https://letscash.fun/token/0x7b9eD6BcaCF63CB0360fE8655eA22575292F09cc)
- [$emocat](https://letscash.fun/token/0xFA9f6E1e2e1241dFF912cfD3c2992d75739840cc)
- [https://x.com/emocatRH/status/2093058350841737556](https://x.com/emocatRH/status/2093058350841737556)
- [https://x.com/emocatrh/status/2093203841604853895](https://x.com/emocatrh/status/2093203841604853895)
- [https://x.com/emocatRH/status/2093400676244070463](https://x.com/emocatRH/status/2093400676244070463)
- [bf](https://letscash.fun/profile/0xbf5c2b3f2b8e3c05867e83b67aa8b41ba0232132)
- [@1QaSupplyCoin](https://x.com/1QaSupplyCoin)
- [0xD0610B3EA09453136E6d307D5fAB4b7b1AfB5Bcc](https://letscash.fun/token/0xD0610B3EA09453136E6d307D5fAB4b7b1AfB5Bcc)
- [0xa5Eb5344CC1bD838562929FdEa2D8DECaE16d6cc](https://letscash.fun/token/0xa5Eb5344CC1bD838562929FdEa2D8DECaE16d6cc)
- [@soligxbt](https://x.com/soligxbt)
- [position$Anchor4,992,639 heldas held when posted](https://letscash.fun/token/0x1A299fd570DFCA4d9822aEe9Ab3D5444E99645cc)
- [position$PICKLECAT73,022 held▼1.0%in $0now $0−$0](https://letscash.fun/token/0x39F099a00C6a0d33EE1B6afF37251c79A4eF54cc)
- [$HOODR](https://letscash.fun/token/0xA13a3c92eE62545f304F4231062f0BF45CAfc8cc)
- [https://x.com/HoodRally/status/2094075395603644872](https://x.com/HoodRally/status/2094075395603644872)
- [https://x.com/HoodRally/status/2094129972814164042](https://x.com/HoodRally/status/2094129972814164042)
- [https://x.com/HoodRally/status/2094147217258938489](https://x.com/HoodRally/status/2094147217258938489)
- [0x344fa109b4c196db344c8f765a3c55e34c2c1ecc](https://letscash.fun/token/0x344Fa109B4c196DB344c8f765A3c55e34C2C1ecc)
- [https://x.com/HoodRally/status/2094303760650531248](https://x.com/HoodRally/status/2094303760650531248)
- [https://x.com/hoodrally/status/2094674601125069252](https://x.com/hoodrally/status/2094674601125069252)
- [@AtlasRobinHood](https://x.com/AtlasRobinHood)
- [0xc4f0592af27c3db862e23d5ee071a2f93c093bcc](https://letscash.fun/token/0xC4F0592Af27C3db862e23D5ee071A2F93c093Bcc)
- [https://x.com/Catdog_X/status/2094781091433635849](https://x.com/Catdog_X/status/2094781091433635849)
- [0x5b89cf296cde3d2c7e49fe9c026686e48ccd1bcc](https://letscash.fun/token/0x5b89CF296cDE3d2C7E49Fe9C026686e48CcD1bcc)
- [https://x.com/HoodRally/status/2094837583867945255](https://x.com/HoodRally/status/2094837583867945255)
- [https://x.com/HoodRally/status/2094876954788766194](https://x.com/HoodRally/status/2094876954788766194)
