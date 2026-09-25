# Launch sources on Robinhood Chain (4663), measured

> Original writing, measured 2026-09-25 for the meme-sniper project over L2 blocks 71,330,338 to 72,187,338 (24 h), read-only.
> Where new tokens come from (v4, v3, each launchpad), which of them get traded, how each is bought, what a safety checker must reject, and what the public RPC supports for simulation.
> Complements `45-v4-pools-and-liquidity.md` (pool census), `48-hook-census.md` (hooks) and `52-swap-throughput-and-head-following.md` (swap flow and head-following).
> Addresses marked unverified in section 9 are candidates for their launchpad archives and have not been written there yet.
## 0. Window and method

Window: L2 blocks 71,330,338 to 72,187,338 (857,000 blocks).
Timestamps 1790248945 to 1790335333, which is 2026-09-24 11:22 UTC to 2026-09-25 11:22 UTC, 86,388 s.
Measured block time over the window: 0.1008 s per block, so 1 hour is about 35,714 blocks.
All logs came from the public RPC `https://rpc.mainnet.chain.robinhood.com` with a custom User-Agent.
`eth_getLogs` over 100,000-block windows worked for Initialize and PoolCreated.
A single query that matches more than 10,000 logs is rejected with "logs matched by query exceeds limit of 10000".
v4 Swap on the PoolManager exceeds 10,000 logs per 10,000 blocks, so the chain does more than 850k v4 swaps a day and a full Swap scan needs about 1,000-block windows.
JSON-RPC batches of 25 work, but sustained batching returns HTTP 429, so throttle to a few requests per second.
Contract names came from Blockscout v2 (`/api/v2/addresses/<a>`) with a `Referer: https://robinhoodchain.blockscout.com/` header.
Launchpad event signatures and topics came from the verified sources in the knowledge base (`resources/launchpads/*/contracts`), with topics computed by `cast keccak`.

## 1. Uniswap v4 Initialize (PoolManager 0x8366a39cc670b4001a1121b8f6a443a643e40951)

Topic0 `0xdd466e674ea557f56295e2d0218a125ea4b4f0f6f3307b95f85e6110838d6438`.
Layout: topics = [id, currency0, currency1], data = [fee uint24, tickSpacing int24, hooks address, sqrtPriceX96, tick].

**8,345 new v4 pools in 24 h, with 270 distinct hooks.**
5,528 (66%) are hookless, and 2,047 (25%) use the Doppler hook.

### By quote side

| Quote | Pools |
| --- | ---: |
| native ETH (address 0) | 4,069 |
| USDG 0x5fc5...1d168 | 1,680 |
| WETH 0x0bd7...cad73 | 950 |
| other (a stock token, AI, or another meme) | 1,646 |

Among the "other" quotes the most common are AI `0x2e8c31162b855a2ffa90f6f8634643ad6f111e18` (214, Long's anchor), `0x1937cad42b17d43bb2b347ce16d5288887c46c33` (133), SPCX `0x4a0e65a3eccec6dbe60ae065f2e7bb85fae35eea` (129), GOOGL, TSLA and SPY.

### By LP fee

| LP fee | Pools |
| --- | ---: |
| 3% or less | 3,130 |
| dynamic (`0x800000` flag) | 2,157 |
| 3% to 10% | 354 |
| 10% to 50% | 270 |
| **50% or more** | **2,434** |

**The 2,434 pools with an LP fee of 50% or more are all hookless, and they are traps.**
Common fees are 880238, 808670, 810000, 800000 and 991200 pips, which means 80% to 99%.
They come from only 183 senders; the top three are `0x511a69dab088f1885260882e12b0354fed3fac0c` (474), `0x851f7af1e585c3fe00156d622d0235f639f53339` (400) and `0xd1df06767842f9222746facaa191446c9f473cc9` (348).
They are opened through `PositionManager.multicall` (`0xac9650d8`) against tokens that already trade elsewhere, for example MUSEINU, Gloob and FLOOR.
628 of the 1,561 in the first-12 h cohort took at least one swap, which is a bot or router routing into an 80% fee.
A sniper must reject any pool whose LP fee is above a small ceiling, and must treat "first pool seen for a token" as unreliable.

### Top hooks, mapped

| Hook | New pools | What it is |
| --- | ---: | --- |
| none | 5,528 | See the sender table below |
| `0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544` | 2,047 | Doppler `DopplerHookInitializer`, used by Long, Bankr and other Doppler integrators |
| `0xe5e702641ea86f4ae6cc3cdaed2b886f976be044` | 82 | Pons v2 `PonsV2MemeHook`. These are **graduations**, not launches (see section 3) |
| `0x4eb1976978756bd56802d8162f2271844924e0cc` | 59 | "Lunch" `LunchTaxHookPair`, an ERC1967 proxy. Not in the KB. Sender `0x6fda94aceedc5a97171469a8873d00fb9983bb8c` = `LunchV4PairLauncher` proxy |
| `0x33c96078007de1804cc59d8a989e336f5a284080` | 33 | Unverified. All 33 from one EOA `0xb6bd2fdf...`, one token RLHOOD at many fee tiers |
| `0xe693a6978cae40520c1aa040ab0ff2d44454f8cc` | 27 | Unverified. Sender `0xa0ce0291c181f800e7a5096b433685c37cfbf4df` (unverified) |
| `0x0310cfebe1d7a69f2414f6595bbe9d17c5342acc` | 24 | o1 Launchpad `LaunchHook`, factory `0xce9c48cfa068947f77738c81be406b53338e5b0d` |
| `0x903b81677d566eb0eb848d084c80ff1d75a860cc` | 24 | Unverified. Sender `0x651873e5d4942500a9e2ba29c74764d633d0ae9c` (ERC1967 proxy, implementation unverified) |
| `0xcabb6081f158b06392d317f2e6c10489d4868080` | 23 | Unverified |
| `0x11cccf5ef6b9fae3b2858a557d817058a40e0080` | 20 | Unverified |
| `0x725fe66409586d56200c257e99b40e1246ea0080` | 17 | Unverified |
| `0x665c52d02ddc506dfb3158c100edc77fe412a8c0` | 12 | `MofoHook` (verified, not in KB) |
| `0x6ced377de5910592e59402786f088e8aaa3700c0` | 9 | `V4IndexEngine` (verified, not in KB) |
| `0x918366044a424ee54fc27084eb416a13882340cc` | 8 | `IndexFeeHook` (verified, not in KB) |
| `0xf7521cf0bb7c11e2d2794189412614cf2e29a0cc` | 7 | "Lunch" `LunchTaxHook`, the native-ETH variant, ERC1967 proxy |
| `0x75a54357d9c78a2db19004a5fdc76c50f9242aec` | 5 | LetsCash / CashCat `CashCatHookV2` (KB: `hood10/`) |

Most hooks outside the top three are one-off, unverified CREATE2 deployments through `0x4e59b44847b379578588920cA78FbF26c0B4956C`.
The 12 largest new pools by ETH volume are mostly on such single-pool hooks with LP fee 500 to 3000.

### Who sends the Initialize transaction (tx.to)

| tx.to | Pools | Identity |
| --- | ---: | --- |
| `0x58daec3116aae6d93017baaea7749052e8a04fa7` | 4,236 | v4 PositionManager, `multicall` `0xac9650d8`. Manual pools, bots and the fee traps; 1,251 distinct senders |
| `0x1eef016f22a943abc7dd11422edee9d235942104` | 1,081 | **`LongLaunchFactory`** (ERC1967 proxy), selector `0x60956835`. **Not in the KB**, which still lists LongLauncher `0x22e99278...` |
| `0x5ff137d4b0fdcd49dca30c7cf57e578a026d2789` | 410 | ERC-4337 EntryPoint v0.6, `handleOps` `0x1fad948c`. Doppler launches whose integrator is Safe `0xae478d7652b1ca5da070aa8563fce1570b420db5` (identity unverified) |
| `0x8366a39cc670b4001a1121b8f6a443a643e40951` | 375 | PoolManager.initialize called directly, `0x6276cbbe`; 270 senders |
| `0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862` | 197 | Doppler Airlock `create` `0x882db707`, called directly |
| `0x3194e32622c5d860a0572c74edda99dcfd8fc827` | 180 | Unverified launcher, selector `0x2fcb9108`, hookless native-ETH pools with 1% to 3% fees, 177 distinct senders. Not in the KB |
| EIP-7702 delegated EOAs (`0xad303ab2...`, `0xeca9eb0e...`, `0x2a68080e...`, `0x958bf097...` and others) | about 300 | Doppler launches via selector `0xb0da329a` |
| `0x8212f89caff7cb72e74008327983b52c909494ff` | 59 | Unverified Doppler wrapper; integrator Safe `0xc229753359729aadcc3de696b75926f9f4091df6` |
| `0x0000ffffbe8efe702c8703ae3477ff5de3d319c0` | 47 | Pools.trade `LiquidityLauncher` |
| `0x815542e8b392389a1389e22e588e4b62a67ade72` | 41 | `LaunchFactory`, verified but not in the KB |
| `0x3c252a5f9c923c2fd4d6382a26be37e1312ca63e` | 28 | `CoinbarrelWorks` |
| `0x5c847be2fe1a245dcd4c4a2929f8efe0a9587b8e`, `0x61e50fce...`, `0x7ed598bc...` and others | 82 | Pons v2 graduations |
| `0xce9c48cfa068947f77738c81be406b53338e5b0d` | 24 | o1 Launchpad `RWAERC20LaunchpadFactory` |
| Clone-launcher family, selector `0x7fde822e` | 232 | See below; senders are the deployers themselves (0xb1e5 182, 0x864f904d 30, 0xc30f2f8f 12) |

**The clone-launcher family is noise.**
One deployer, `0xb1E5c89E0FebD0308c9Cc3Ae9d4411BcA3B6bA2A`, deployed launchers named `BankrPort`, `VirtualsPort`, `ClankerStation`, `HooditPad`, `HooditHub`, `VaroLaunch`, `CoinbarrelNova`, `OoneDeck` and others, borrowing real brand names.
Each makes about 20 hookless ETH pools a day, and every pool gets exactly one swap within 10 seconds and then nothing.

## 2. Uniswap v3 PoolCreated (factory 0x1f7d7550B1b028f7571E69A784071F0205FD2EfA)

Topic0 `0x783cca1c0412dd0d695e784568c96da2e9c22ff989357a2e8b1d9b2b4e6b7118`.
**404 new v3 pools in 24 h**, about 5% of the v4 count.
By quote: WETH 317, USDG 70, other 17.
By fee tier: 100 (221), 10000 (99), 500 (59), 3000 (25).

| tx.to | Pools | Identity |
| --- | ---: | --- |
| `0x73991a25c818bf1f1128deaab1492d45638de0d3` | 214 | v3 NonfungiblePositionManager, manual |
| `0x1fae6f162355cf77bf7f23cb919130962dad4ecb` | 38 | Unverified, selector `0x026f2bf0` |
| `0xfc5c184b9701bc6b425debdccb3a1edaaaf5b432` | 29 | Unverified, selector `0x4ae1e1f8` |
| `0x6ab00f885472c7f7688497a14fa1316d205d0de6` | 29 | `PairmonCards` |
| `0xf4fc0cd27fc8ecf17e55ee4c3f7201897df3eb75` | 15 | Pons v1 `PonsLaunchFactory` proxy, `launchToken` `0x686399cb` |
| about 10 unverified contracts sharing selector `0x77471ae1` | about 25 | One cloned factory family, unverified |

Noxa v2 (`0xdd84fdde...`) and hood.fun launched nothing on v3 in the window.
Pools.fun uses SushiSwap V3, not this factory.

## 3. Launchpads: model, events, buy path, activity in the window

Counts are logs of the named creation event over the full 24 h window, queried by topic across all addresses.

### Ranking by tokens created (24 h)

| # | Launchpad | Tokens created | Graduated | Trading in window |
| --- | --- | ---: | ---: | --- |
| 1 | **Pons v2** | **8,852** | 82 (0.93%) | **298,061 curve trades; 6,370 ETH of buy plus sell on ETH curves**, plus 4,967 ETH on the 48 graduated v4 pools in the cohort |
| 2 | Doppler family (Airlock `Create`) | 2,047 | 0 (by design) | see split |
| 2a | of which Long (integrator `0x92d435c9...`) | 1,364 | - | 25% of pools ever traded; 7.6 ETH-side volume (mostly stock and AI quotes) |
| 2b | of which Safe `0xae478d76...` via EntryPoint | 399 | - | 3.3% ever traded |
| 2c | of which Bankr (`0xf60633d0...`) | 178 | - | 39% traded; 51.5 ETH |
| 2d | of which Safe `0xc2297533...` | 59 | - | 31% traded |
| 3 | Flap (Portal `0x26605f32...`) | 1,950 | 0 | 2,140 `TokenBought` in total, about one buy per token |
| 4 | Pools.trade (`TokenLaunched`) | 110 | n/a | all traded; 45.9 ETH |
| 5 | Lunch (hook pools) | 66 | n/a | 25% traded |
| 6 | o1 Launchpad | 24 | n/a | 79% traded; 1.8 ETH |
| 7 | Pons v1 | 15 | n/a | v3 WETH |
| 8 | Virtuals (`PreLaunched` / `Launched`) | 15 / 15 | 0 | not measured |
| 9 | LetsCash / CashCat | 5 plus 5 VNext | n/a | tiny |
| 10 | Sentry | 5 | n/a | 1 swap |
| 11 | hood.fun | 0 on the known `TokenCreated` topic | 3 | 12 trades in total; the live launchpad is now `0x20d93c97ca645c6e81b7c35ca1e3c6b9049a40bf` (unverified, not in the KB) |
| 12 | Bags | 3 | 0 | 752 `TokensBought`, 733 of them on one curve |
| 13 | Pools.fun | 3 | n/a | SushiSwap V3; the factory is now `0x5f13c63a...` (`PartyFactory`, verified, not the KB address) |
| 14 | token.select | 1 | - | - |
| - | hood10, Mixpad, PAIR, Unihood, Noxa v2, StonkBrokers | 0 | - | inactive in the window |

Not attributable to a KB launchpad but material:

| Source | Count | Note |
| --- | --- | --- |
| Unverified launcher `0x3194e326...` | 180 v4 pools | 99% traded, median 82 swaps in the first hour |
| PoolManager.initialize direct | 375 | 95% traded |
| Contract-creation transactions that initialize a pool | 64 | Median 785 swaps in the first hour; 9 senders |
| Pons-topic forks | 24 | `0x798daaa0...` (14, unverified), `DegenLaunchFactory` `0xa8788400...` (7), `0xc2f62347...` (3), all emitting Pons' `TokenLaunched` topic |

**Pons v2 is where launches and flow are**, by an order of magnitude.
It has 7,051 distinct deployers.
Its quote assets are ETH 6,906, USDG 557, NVDA 511, `0xc0d6457c...` 297 and SPCX 122.
Only the top 20 curves carry 9% of trades, so flow is spread widely.

### Per launchpad: mechanism and hooks for a sniper

**Pons v2** has a bonding curve that graduates to Uniswap v4.
- Factory `0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e`.
- Launch: `launchToken(...)` `0xf35abbcf`, or `0xa72101af` with an exemption list. Launch fee 0.0005 ETH. There is also LaunchAndBuy `0xe33E9E47...`.
- Creation event: `TokenLaunched(address indexed token, address indexed curve, address indexed deployer, address pairToken, uint256 launchConfigId, uint256 graduationThreshold)`, topic0 `0x8d4aad4953d0ca700d468f3753aa14432d1b35b43ec6409f051fb6aa43a89607`.
- The curve is a separate contract per token, taken from topic2.
- Curve buy: `curve.buy(uint256 quoteIn, uint256 minTokensOut, address recipient)` `0x59a87bc1`. It is payable for ETH; an ERC-20 quote needs an approval on the curve.
- Curve sell is `0xd04c6983`.
- Trade events: `CurveBuy(address indexed buyer, address indexed recipient, uint256 quoteIn, uint256 tokensOut, uint256 fee, uint256 tax)` `0xec36bf571f136799e8dc0b0b8bea4b04d8bd3d43de838aab0d5fc21d4cbfc455`.
- `CurveSell` is `0x8113d738abdcb6b38357e9d53a54a7157861a09031b453651f0fe7fe151f59df`.
- Graduation happens at 4.2 ETH or the pair equivalent. The factory emits `PoolGraduated(address indexed token, uint256 positionId, uint256 tokenAmount, uint256 pairTokenAmount)` `0x0a44ef75df69c534f43cd6c1aa3ef8983065fe5fe79ef9e79f6494e6f258c259`, and the curve emits `CurveCompleted` `0xf8d37a90...`.
- After graduation: v4 pool, fee 0, tickSpacing 200, hook `0xe5e702641ea86f4ae6cc3cdaed2b886f976be044`. The hook takes 1% plus a creator tax of 0 to 10%, invisible in the LP fee. Buy through the Universal Router.
- Anti-snipe: 99% buy tax decaying to 0 over 3 s. The launcher and up to 32 creator-named wallets are exempt.
- Measured sniping (first external trade after launch, 6,445 curves): p10 at 2 blocks, median 20 blocks (2 s), 2,654 within 10 blocks, 87 in the launch block itself.
- Measured activity: 63% of curves (5,460 of 8,631) carry a dev buy in the launch tx. 58.8% of curves get at least one external buy within an hour; 1,589 of 8,631 get 10 or more and 303 get 100 or more.

**Doppler family (Long, Bankr, others)** is a permanent v4 multicurve from block one, with nothing to migrate.
- Airlock `0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862`.
- Creation event: `Create(address asset, address indexed numeraire, address initializer, address poolOrHook)` `0x68ff1cfcdcf76864161555fc0de1878d8f83ec6949bf351df74d8a4a1a2679ab`, with the asset in data word 0.
- Integrator: `Airlock.getAssetData(address)` `0x1652e7b7`; word 9 of the return is the integrator.
- Long also emits `LaunchCreated` `0xadc6f1f726f7c710f77ec06adc75f3bb964e5be19581b072c67f7b9b4039267b`, now from `LongLaunchFactory` `0x1eef016f...` (1,363 in the window).
- The graduation events `Graduate` `0xbd2bd570...` and `Migrate` `0x2a05bb71...` never fire here.
- Buy path: Universal Router V4 swap on hook `0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544`, fee `0x800000` (dynamic), tickSpacing 8. The numeraire is usually an ERC-20 (WETH 467, AI 211, `0xc0d6457c...` 153, SPCX 143, ETH 134, USDG 105), which needs Permit2.
- Hidden hook fee: Long standard launches show 0.1% LP plus a 1.12% Rehype fee, and the KB measured about 1.4% on a pool displaying 0.10%.
- Anti-snipe: the Long Rehype fee starts at 80% and decays linearly to 1.12% over 10 s.

**Flap** has a bonding curve that migrates to Uniswap V2 with the LP burned.
- Portal `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09`; the implementation is unverified.
- Creation event: `TokenCreated` `0x504e7f360b2e5fe33cbaaae4c593bc55305328341bf79009e43e0e3b7f699603`, with nothing indexed.
- Buy: `swapExactInput((address,address,uint256,uint256,bytes))` `0xef7ec2e7`, input token address(0) for ETH.
- Trade event: `TokenBought` `0xa800a2038683844fac66747f771bfdfae862eb28b16bcfa387afa9fbacce8ff7`.
- Graduation: `LaunchedToDEX` `0x6e4f4763...`, which never fired in the window.
- Tax tokens (addresses ending 7777) charge 0 to 10% on buys and sells.

**Pools.trade (Uniswap Labs)** uses Instant Launch: a hookless v4 native-ETH pool with LP fee 2500 and tickSpacing 25, and no curve.
- Launch: LiquidityLauncher `0x0000FffFBE8efE702c8703aE3477FF5dE3d319C0`.
- Creation event: `TokenLaunched` `0x3b3d2bafdcae274a232217e1f80ee4305d3af6aa25c8b14b1681bd68d18042a4`.
- It is emitted from `InstantLaunchStrategy` `0x23f8209572b4a1C2AD88A42749E830791Fb027f1` (87) and from `0x7c48dde3b447381f4d986334679b3afc7f2d35c2` (20, unverified, not in the KB).
- No anti-snipe. The UI says "No sniper protection".
- This is the cleanest target: an immutable, plain v4 pool.

**o1 Launchpad** seeds the pool directly.
- Factory `0xce9c48cfa068947f77738c81be406b53338e5b0d`.
- Creation event: `Launched` `0x207384e895174175cc774fe7f7457b37c382f27ebf53d37d5257b862f80eaf9c`.
- Anti-snipe: 99% fee decaying to 1% over 20 s.

**Sentry** seeds the pool directly: a 40% fee for 180 s, halving every 180 s down to a 1.7% floor. Only 5 launches in the window.

**Unihood** charges 15% under 5 s and 5% under 15 s, then 1%. It had 0 launches in the window.

**Virtuals** launches in two transactions: `PreLaunched` `0xb9ee8aa6...`, then `Launched` `0x6ed5dc54...`, which is the trigger to watch.
- The curve is priced in VIRTUAL. Buy with `buy(uint256,address,uint256,uint256)` `0x706910ff` on BondingV5 `0xd4cCBFA3...`.
- The buy tax starts at 99% and decays to 1% over 0 to 98 minutes.

**hood.fun and Bags** are near-dormant (under 5 launches a day).

### Universal Router path (all v4 and v3 venues after graduation)

- Use `0x8876789976dEcBfCbBbe364623C63652db8C0904`, which carries 99.7% of router traffic. `0x06AfBA43...` is a second genuine deployment.
- Call `execute(bytes,bytes[],uint256)` `0x3593564c` with command `0x10` (V4_SWAP) and actions `0x06 0x0c 0x0f`, which are SWAP_EXACT_IN_SINGLE, SETTLE_ALL and TAKE_ALL.
- `ExactInputSingleParams` in Universal Router 2.1.1 has six fields, including `minHopPriceX36`.
- **Trap: the old five-field struct silently succeeds with no per-hop price guard.**
- An ETH buy sends `msg.value` and settles `address(0)`. A sell goes through Permit2, with commands `0x0a10`.
- A hook revert arrives wrapped in `WrappedError(address,bytes4,bytes,bytes)` `0x90bfb865`.
- The V4 Quoter `0x8Dc178eFB8111BB0973Dd9d722ebeFF267c98F94` simulates the hook, so quote minus pool price gives the hidden fee. About 750k gas per quote.
- StateView is `0xF3334192D15450CdD385c8B70e03f9A6bD9E673b`.
- v3 SwapRouter02 is `0xCaf681a66D020601342297493863E78C959E5cb2`, with `exactInputSingle` `0x04e45aaf`.

## 4. Which launches get traded

Cohort: the 5,216 v4 pools initialized in the first 12 h of the window, so each has at least 12 h of history.
Swaps were matched by PoolId, from topic1 of v4 `Swap` `0x40e9cecb9f5f1f1c5b9c97dec2917b7ee92e57ba5563708daca94dd84ad7112f`.
Swaps inside the pool's own creation transaction (dev buys) are excluded.

| Group | Pools | Any swap in 1st hour | Ever swapped | 10+ swaps in 1st hour | Median swaps 1st hour | Swap within 1 s (10 blocks) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| **All new v4 pools** | 5,216 | 50.7% | **54.2%** | 23.9% | 1 | 33.7% |
| Hookless via PositionManager | 2,501 | 50.0% | 56.2% | 19.7% | 1 | 28.7% |
| Doppler hook | 1,384 | 22.3% | 23.0% | 14.1% | 0 | 8.0% |
| Pons v2 graduated | 48 | 100% | 100% | 100% | 1,588 | 100% |
| Unverified launcher `0x3194e326` | 106 | 99.1% | 99.1% | 97.2% | 82.5 | 98.1% |
| PoolManager.initialize direct | 154 | 94.8% | 94.8% | 70.8% | 77 | 90.3% |
| Pools.trade | 30 | 100% | 100% | 60% | 13 | 100% |
| Lunch pair hook | 52 | 25% | 25% | 7.7% | 0 | 11.5% |
| o1 Launchpad | 14 | 78.6% | 78.6% | 42.9% | 7 | 0% (20 s decay fee) |
| Clone-launcher family | 198 | 100% | 100% | 0% | 1 | 100%, and only that single swap |
| Fee-trap pools (LP fee at least 50%) | 1,561 | - | 40.2% | - | - | - |

By quote: ETH pools 68% ever traded, WETH 50%, USDG 48%, other quotes 30%.

Roughly **half of new v4 pools ever see a swap**.
Once the fee traps, the clone family and the dead Doppler Safe launches are removed, a real "meaningful trading" rate (10 or more swaps in the first hour) is about 24%.

For Pons curves (not v4 pools until graduation), 58.8% get an external buy within an hour and 18% get 10 or more.

ETH-side volume on the cohort's v4 pools, 42,007 ETH in total over their life in the window:
- other single-pool hooks: 21,682 ETH;
- hookless PositionManager pools: 12,292 ETH;
- Pons graduated: 4,967 ETH;
- everything attributable to other launchpads: under 1,000 ETH.

The top two pools (VMINT, PPRM) route 99% of their swaps through one sender `0xc955efd62944fcea581194ba722db08592865b8b`, which looks like wash volume (unverified).

## 5. Honeypot and rug mechanisms a safety checker must detect

From the KB, plus what the window showed.

1. **Extreme LP fee pools.** 2,434 of 8,345 new v4 pools (29%) had an LP fee of 80% to 99%. Reject any pool whose fee is above your ceiling, and remember the fee field can be `0x800000` (dynamic), so read the live fee from `StateView.getSlot0`.
2. **Hidden hook fees (`afterSwapReturnDelta` / `beforeSwapReturnDelta`).** The pool shows 0% or 0.1% while the hook takes 1% to 2% (Pons, Bags, Doppler/Rehype, hood10, CashCat, o1, Sentry, Unihood, Lunch). Always quote through the V4 Quoter and compare with the pool price. Decode hook permission flags from the low 14 bits of the hook address. 66% of registered hooks on this chain can replace the swap.
3. **Time-decaying opening taxes.** Pons is 99% over 3 s, Long 80% over 10 s, o1 99% over 20 s, Sentry 40% for 180 s then halving, Unihood 15% under 5 s, and Virtuals 99% over up to 98 min. A first-block snipe on these pays the tax. Model the schedule by `block.timestamp`, not by block count.
4. **Owner-settable hook taxes on upgradeable hooks.** Lunch `LunchTaxHookPair` / `LunchTaxHook` are ERC1967 proxies. The creator can change buy and sell tax up to 500 bps per side at any time with `setRates`, and the owner can upgrade. Its event is `TaxAccrued(bytes32 indexed poolId, bool isBuy, uint256 quoteAmount)`.
5. **Hooks that can refuse swaps.** Bitquery measured `beforeSwap` failing 1.174% of the time. DualPoolHook `0xd1BcbCCa...` can be paused per pool by its owner. Simulate the sell as well as the buy.
6. **Fake quote tickers.** 11 contracts in this window's new-pool tokens carry a USDG-like symbol, for example `0x4076bb6e...`, `0x650bf915...`, `0xa6a71fad...`, `0xb76fd9e3...` and `0xc2378f12...` ("USDG", 18 decimals; real USDG has 6), plus `USDG-L2/L3/L4`. 7 new v4 pools quote against them. There are also fake `USDT` and `ETH` tickers. Key on the address, never the symbol.
7. **Stock-ticker impersonation.** 63 new-pool tokens use a real Stock Token ticker (TSLA, AMD, SPY, SHOP, IBM and others) at an address not in the KB roster, across 99 new v4 pools. Match against `robinhood-chain/16-token-contracts.md`.
8. **Real stock tokens carry issuer powers.** There is a central blocklist checked on transfer, `adminBurn` from any holder including pool reserves, a global pause, and one upgrade beacon behind all 194 tokens (KB file 46). Pools quoting in a stock token inherit these.
9. **Upgradeable launch infrastructure.**
   - Bags: one EOA owns the beacons for every curve and fee share, and can pause curves, which freezes sells.
   - Flap: a 2-of-5 Safe can upgrade the Portal that holds every curve reserve, and FeeSafe can blocklist and `halt()`.
   - Virtuals: one EOA upgrades BondingV5; the token has a blocklist and `setProjectTaxRates` is uncapped.
   - PAIR and token.select: UUPS factories.
   - RaiseHood: `setLpLocker`, `forceOpenTrading` and `setPaused`, which make it honeypot-capable (unverified).
10. **Fee-on-transfer and tax tokens.** Flap tax tokens (addresses ending 7777) charge up to 10% per side. Virtuals tokens tax 1% on buys and 1% on sells after graduation. Test with a simulated buy then sell and compare balances. Uniswap's `FeeOnTransferDetector` is listed on other chains in `DEPLOYMENTS.md`, but its presence on 4663 is unverified.
11. **Transfer restrictions before graduation.** Flap reverts pool transfers before graduation and for 30 days after only the main pool works. hood.fun tokens can only move via the launchpad before graduation.
12. **LP removability.** Most KB launchpads lock or burn LP. A hookless PositionManager pool made by an EOA has fully removable liquidity, the classic rug. Check the LP position owner.
13. **Pool squatting.** 741 tokens got more than one new v4 pool in the window. Copycat pools on an already-launched token (for example FOOMS on hook `0x24eb4c8b...` next to its Pons pool) mean "first Initialize for this token" is not "the launch".

## 6. Public RPC capabilities (tested 2026-09-25)

Client `nitro/v3.12.0-rc.3+ebe9e83-20260916T211740Z`.

| Method | Result |
| --- | --- |
| `eth_call` with a state-override third param (`code`, `balance`, `state`, `stateDiff`) | **Supported**; all four override kinds worked |
| `eth_call` fourth param (block overrides) | Accepted |
| `eth_estimateGas` with a state override | Supported |
| `eth_simulateV1` | **Supported**, including `stateOverrides` and `traceTransfers` (native transfers show up as synthetic logs from `0xeeee...eeee`) |
| `debug_traceCall`, `debug_traceTransaction` | **Not available** (-32601) |
| `trace_call` | Not available |
| `eth_createAccessList` | Not available |
| `txpool_content` | Not available; there is no public mempool |
| `eth_subscribe` over HTTP | Not supported; no websocket RPC was tested |
| `eth_maxPriorityFeePerGas` | 0 |
| `eth_gasPrice` | 36,237,488 wei (0.036 gwei) |

**`eth_simulateV1` with `traceTransfers` is the honeypot-check tool**: simulate buy then sell under an overridden balance and read every transfer, with no trace API needed.
The KB also says Alchemy `robinhood-mainnet` does not serve `trace_block` at any tier, and free-tier `eth_getLogs` is capped at 10 blocks.
An `ALCHEMY_API_KEY` exists in nearby project `.env` files (for example `meme-factory/.env`), but it was not needed or used.

## 7. Block time, sequencer and ordering

- **Block time is 0.1008 s**, measured over the 24 h window.
- `block.number` in Solidity is the L1 estimate, about 120 L2 blocks per tick. Use `ArbSys(0x64).arbBlockNumber()` for the L2 height.
- **Ordering is first-come, first-served at the sequencer** (KB `ROBINHOOD-CHAIN.md`). Priority fees do not reorder; `eth_maxPriorityFeePerGas` is 0. There is no priority gas auction and no mempool.
- **Timeboost / express lane is not enabled.** `timeboost_sendExpressLaneTransaction` returns "method does not exist" on both the RPC and the sequencer endpoint.
- **Sequencer endpoint `https://sequencer.mainnet.chain.robinhood.com` accepts `eth_sendRawTransaction` directly.** It answered a junk tx with the "typed transaction too short" parse error, and does not serve reads. Submitting there skips one RPC hop; the latency gain is unmeasured.
- **The sequencer feed `wss://feed.mainnet.chain.robinhood.com` is public, with no auth.** Verified live: it streams sequenced messages with a sequence number and L2 message payload. The KB measured sealed blocks arriving about 107 ms before RPC serves them.
- **That lead is about one block.** It lets a bot see a launch transaction and react in the next block or two, which matches the measured Pons p10 first-external-trade lag of 2 blocks.
- **You cannot get in front of a transaction you see.** Being first depends on network latency to the sequencer, and anti-snipe decay schedules make block-0 entry expensive on most pads anyway.
- **The sequencer screens transactions** for sanctioned addresses, and Robinhood operates it (KB, Terms of Service as of 2026-09-02).
- **No L2 sequencer uptime feed exists** for this chain.
- **KB file 47:** backrunning shows up on about 0.41% of large trades, one block after the victim; sandwiching is unreachable.

## 8. What this means for the sniper design

- The main launch stream is **Pons v2 `TokenLaunched`** (about 370 an hour). Its curve buy is a direct `curve.buy` call, not a Uniswap swap, so a v4-Initialize-only listener misses almost all Pons launches.
- The second stream is **Doppler `Create`** (about 85 an hour, mostly Long). Few are traded, and they carry an 80% fee decaying over 10 s.
- Pools.trade, o1, the unverified `0x3194e326` launcher and direct `PoolManager.initialize` pools are small but reliably traded.
- Filter out LP fees of 50% or more, the clone-launcher family, fake-ticker quotes and hooks with unknown or upgradeable code before spending anything.
- Watch the sequencer feed for the launch transaction, and simulate with `eth_simulateV1` plus a state override. Send to the sequencer endpoint.

## 9. Unverified items and KB gaps found

These are unverified, or are new contracts not in the KB, and are candidates to write back to the KB after confirmation.
- `LongLaunchFactory` proxy `0x1eef016f22a943abc7dd11422edee9d235942104` is Long's current factory; the KB lists LongLauncher `0x22e99278...`.
- The hood.fun live launchpad appears to be `0x20d93c97ca645c6e81b7c35ca1e3c6b9049a40bf` (unverified), emitting the known `Trade` and `Graduated` topics plus an unknown creation topic `0x9ab9914b5e10152ca9ecfe43da4cd97e46e589ab220862e8e0f127097f28b4f9` (unverified).
- Pools.trade has a second strategy, `0x7c48dde3b447381f4d986334679b3afc7f2d35c2` (unverified), emitting `TokenLaunched`.
- Pools.fun's factory now emitting is `0x5f13c63a8060fd47f7b7278fbcb3a6f47fcb2dc6` (`PartyFactory`, verified); the KB lists `0x626C3d09...`.
- The Doppler integrators `0xae478d7652b1ca5da070aa8563fce1570b420db5` and `0xc229753359729aadcc3de696b75926f9f4091df6` are Safes from one deployer, `0x4e1DCf7A...`. Their identity is unverified; they may be Bankr's new setup.
- The Lunch launchpad (`LunchV4PairLauncher` `0x6fda94ac...`, hooks `0x4eb19769...` and `0xf7521cf0...`) has no KB archive.
- Pons-topic forks: `0x798daaa0...` (unverified), `DegenLaunchFactory` `0xa8788400...` and `0xc2f62347...`.
- The clone-launcher family is from deployer `0xb1E5c89E0FebD0308c9Cc3Ae9d4411BcA3B6bA2A`.
- Flap event signatures come from Flap's docs, not verified source, although the topics matched live logs.
- ETH volume figures count the ETH or WETH side only. Stock-token and USDG-quoted volume is excluded, so Doppler/Long volume is understated.
