# Sentry - Quotrons, the machine-readable integration bundle

> Source: https://www.quotrons.cash/{llms.txt,quotrons-llm.md,integration.md,integration/*,migration/manifest.json}
> Retrieved: 2026-09-03 (curl)
> Raw capture: `_raw/quotrons/`

---

Captured because the Quotrons pages link these files and they are the sibling product's own contract documentation.
Sentry itself has no equivalent under sentry.trading beyond `sentry-guide.md`, which is `pages/58-guide-machine-readable-source.md`.

Quotrons publishes a machine-readable integration bundle that Sentry does not: an `llms.txt` index, a full reference, an integration guide, a network manifest and four ABIs.
They are captured verbatim under `_raw/quotrons/`.

## https://www.quotrons.cash/llms.txt

# QUOTRONS V2

> QUOTRONS is a 4,444-terminal ERC-404 collection on Robinhood Chain
> (chain id 4663). V2's supported market is one canonical QUOTRON/WETH
> Uniswap v4 pool. One whole liquid token materializes one dark terminal;
> burning its backing token hardwires that terminal into a permanent NFT.
> Hardwired terminals claim promotional rewards paid in one of ten
> tokenized stocks.

Status on 2026-08-13: V1 is permanently retired after a stale-approval
incident. The verified V2 contracts are deployed and the snapshot-based,
zero-action distribution is finalized. The canonical QUOTRON/WETH pool is
seeded, trading is live, metadata is frozen, and launch fees are permanently
finalized at 3%.

Final V1 historical record: $113,849.84 in tokenized-stock rewards
generated for hardwired holders. This frozen archival value uses the
final onchain fee pots, the exact 80/17 reward-to-burn ratio, and the V1
final-accounting stock marks; it is not a live balance or current-price
valuation.

V2 core: 0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F
V2 NFT mirror: 0x027ACa2794E44f24950D81227DcD516FfBB49d6e
V2 reflections: 0xe04fba61FD54Ba78Dd450A30d8Af40167aF5d3Ec
Canonical router: 0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18
Canonical hook: 0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc

Permanent base fee: 3%. Of volume at that rate, 2% funds stock rewards,
0.6375% compounds locked liquidity, 0.2125% buys and burns
STONKBROKERS, and 0.15% goes to the creator. The temporary launch-fee
phase has ended.

Ten reward stocks: NVDA AAPL TSLA GME SPCX SPY PLTR NFLX RDDT MSTR.
The Gold Indicator accrues all ten stocks directly; V2 has no fresh PAXG
conversion rail.

The Machine's Record shows a cumulative V2 reward total that does not reset
when an epoch opens. It adds all historical WETH reward-pot pulls to the live
queue, and separately reports WETH already converted and allocated to
hardwired terminals. Its USD estimate uses the current ETH/USD price.

Metadata is revealed and pinned. The onchain base URIs freeze as part of
the one-way launch transaction. Dark metadata:
ipfs://bafybeig447r5kqu34u2qm5aklrvgk5igor6qe6o7ng6wmuj2vet3idiwhe/
Hardwired metadata:
ipfs://bafybeigl2vkhz4pwib27k6l6g5nqsvp5i6zgnhogc27csap3cltlvvx5mi/

V2 discloses owner pause and venue-codehash controls, a blacklist
guardian, and a threshold recovery Safe that can forcibly move eligible
user balances or terminal NFTs. These are explicit trust assumptions.

Reflections and reward drops are promotional rewards, not dividends,
investment income, equity, or a share of profits. Nothing here is
financial advice. Read the complete reference at:
https://quotrons.cash/llms-full.txt

## https://www.quotrons.cash/quotrons-llm.md

# QUOTRONS V2 — LLM Reference

Last updated 2026-08-13.

QUOTRONS is a 4,444-terminal ERC-404 collection on Robinhood Chain
(chain id 4663). V1 is permanently retired after a stale-approval
incident. V2 is a separate, newly deployed collection and does not
replace or mutate V1.

The V2 snapshot distribution was zero-action and is finalized. Eligible
dark terminals, hardwired terminals, fractional balances, and approved
restitution allocations were delivered directly. The canonical
QUOTRON/WETH pool is seeded, trading and hardwiring are live, and the
permanent fee is 3%.

The revealed assets are pinned to IPFS. The one-way metadata freeze
executed as part of launch, so the base URIs are immutable.

Promotional rewards are not dividends, investment income, equity, or a
share of profits. Nothing here is financial, investment, legal, or tax
advice.

## Token and terminal mechanics

- V2 preserves exactly 4,444 economic units:
  liquid supply + hardwired count × 1e18 = 4,444e18.
- One whole liquid QUOTRON materializes one dark terminal.
- Selling below a whole unit dissolves a dark terminal.
- Hardwiring burns exactly one liquid QUOTRON backing a chosen dark
  terminal.
- Hardwiring is permanent and irreversible.
- A hardwired terminal is a permanent ERC-721 and can claim its assigned
  promotional stock rewards.
- Pending rewards stay attached to the hardwired terminal ID when its NFT
  transfers.

Standard tiers and weights:

- Quotron I Keypad: 1.0x.
- Quotron II Desk Unit: 1.5x.
- Quotron 800: 2.5x.
- NASDANK Terminal: 5.0x.

Holding a STONK BROKER NFT increases an ordinary hardwired terminal's
live reward weight to 1.25x. Anyone can call `poke(id)` after the owner's
Broker status changes.

## One market and ten reward stocks

V2 has one canonical QUOTRON/WETH Uniswap v4 market. It does not have ten
QUOTRON/stock pools.

The ten tokenized stocks are reward conversion tracks:

`NVDA AAPL TSLA GME SPCX SPY PLTR NFLX RDDT MSTR`

Fresh WETH reward fees are converted in bounded epochs and deposited as
those stocks into the V2 reflections contract.

The three basket relics (#4441–#4443) each receive one third of a 12.5%
carve from every track's converted stock. The Gold Indicator (#4444)
receives 5% of every track's converted stock. V2 has no fresh PAXG
conversion route; migrated legacy PAXG credit remains claimable.

## Fee policy

The permanent base fee is 3%. At that rate:

- 2.0000% of volume funds stock rewards;
- 0.6375% compounds locked QUOTRON liquidity;
- 0.2125% buys and burns STONKBROKERS; and
- 0.1500% goes to the creator.

During the historical launch phase, before irreversible finalization:

- the keeper, registry-eligible wallets, and STONK BROKER holders pay 3%;
- the public fee is 90%; and
- a recipient that actually pays the 90% buy fee is transfer-restricted
  for one hour.

There is no six-hour V2 timer and no 40% V2 tier. The manual, one-way
finalization has executed, so every wallet now uses the 3% base fee.

## Reward epochs

The destination-locked epoch converter:

- requires at least 0.1 WETH to open an epoch;
- caps an epoch at 100 WETH;
- enforces at least 60 seconds between epochs;
- splits WETH equally among the ten reward tracks;
- uses sealed WETH -> USDG -> stock routes; and
- sends stock only to the reflections contract.

The Machine's Record displays a cumulative V2 reward total that does not
reset when an epoch opens. It adds all historical reward-pot pulls to the
live queue, then separately reports WETH already converted and allocated,
WETH in an active conversion, and WETH awaiting the next epoch. USD is
marked at the current ETH/USD price.

Each track's stock inflow is divided 82.5% to ordinary hardwired
terminals by weight, 12.5% to the three basket relics, and 5% to #4444.

## Canonical routing

The only supported route is:

`user -> QuotronWethRouter -> registered QUOTRON/WETH v4 pool`

The hook rejects every noncanonical sender and pool. The token requires a
one-shot PoolManager settlement authorization issued by that hook. Known
non-v4 venue code hashes can be banned, while EOA hashes cannot.
This prevents alternate v4 settlement; ordinary ERC-20 transfers remain,
so arbitrary future custom contracts are not claimed to be impossible.

Router API:

```solidity
buyExactEth(uint256 minQuotronOut, address recipient, uint256 deadline)
    payable returns (uint256 quotronOut);

sellExactQuotronForEth(
    uint256 quotronIn,
    uint256 minEthOut,
    address recipient,
    uint256 deadline
) returns (uint256 ethOut);
```

Sells require an ERC-20 allowance to the canonical router. Approve only
the needed amount. Aggregators quote with `QuotronWethQuoter` via
`eth_call` using `(amount, payer)`, then apply an explicit slippage
minimum and submit through the canonical router.

There is no hosted quote API key. Public integration files:

- Guide: `https://quotrons.cash/integration.md`
- Manifest: `https://quotrons.cash/integration/manifest.json`
- Router ABI:
  `https://quotrons.cash/integration/QuotronWethRouter.abi.json`
- Token ABI:
  `https://quotrons.cash/integration/Quotron404V2.abi.json`
- Hook ABI:
  `https://quotrons.cash/integration/QuotronWethHook.abi.json`
- Quoter ABI:
  `https://quotrons.cash/integration/QuotronWethQuoter.abi.json`

## V1 migration

The V2 Merkle distribution preserved eligible exact IDs and hardwire
state, delivered reviewed fractional allocations and restitution, and
excluded post-cutoff purchases on every venue (OpenSea, unofficial
external pools, or direct transfers). Dark ownership and balances froze
at halt block 34984482; eligible hardwired ownership followed V1 NFTs
through block 35337540.

Finalization required both full distribution of the committed cap and a
zero migration-reserve balance. It permanently closed all remaining
claim, assignment, handoff, fractional, and restitution entrypoints.
The website's V1 Migration Record is now read-only, except for safe V1
operator revocation.

The zero-action distribution did not take V1 NFTs or move accrued V1
rewards. Those remain separate V1 entitlements; V2 terminals accrue new
V2 epoch rewards.

V1's final historical record is **$113,849.84** in tokenized-stock
rewards generated for hardwired holders (displayed as **$113,850**).
This frozen archive uses the final onchain V1 fee pots, the exact 80/17
reward-to-burn ratio, and the stock marks used for final V1 accounting.
It is not a live balance or a current-price valuation. Audit data:
`/migration/v1-historical-rewards.json`.

## Disclosed controls

- The owner can pause the core and hook, manage non-EOA venue codehash
  bans, and irreversibly finalize the base fee.
- The blacklist guardian can freeze addresses but cannot remove a freeze.
- The recovery administrator can add or remove freezes.
- A Safe with threshold at least two is the recovery administrator.
- The Safe can forcibly move V2 ERC-20 balances or terminal NFTs between
  eligible non-protocol accounts.
- Protected protocol accounts cannot be arbitrary recovery targets.
- Actions emit onchain events.

Guardian:
`0x7171E64E979265aeD6588577D1c6b60A701d7866`

Recovery Safe:
`0x15277aA1ecC13734d57C519a2DAA1cc4A748bA89`

These controls are explicit trust assumptions. Metadata base URIs and
the ERC721-C transfer validator become immutable at launch. The V2
mirror clears individual token approvals on base-driven ownership and
approval-domain transitions; wallet-wide operator approvals remain the
wallet owner's choice.

## NFT creator earnings

The V2 mirror uses ERC721-C transfer validation. The intended creator
earning is 5%: 4% to the keeper and 1% to the creator. Venue
compatibility depends on support for the transfer validator and payment
split. This is separate from the token-market creator carve.

## Production V2 addresses

- Core: `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F`
- Mirror: `0x027ACa2794E44f24950D81227DcD516FfBB49d6e`
- Reflections: `0xe04fba61FD54Ba78Dd450A30d8Af40167aF5d3Ec`
- Hook: `0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc`
- Router: `0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18`
- View quoter: `0xb8960fdC8A0Be155d196C2795b75747763562df2`
- Eligibility registry: `0x94CfC3798Ca6320Ac5e6af04484EFE90bD04aC81`
- Epoch converter: `0x24e62Dd5C7058CC41ad9c5375C137460ea1Da2FE`
- WETH burn vault: `0xd1258efafa9d1B1d09c86403139Db78465540760`
- Burn adapter: `0x59b09A326984dd3c1076B864aa27F0BDd9876f0a`
- Finalized migrator: `0x205E13e6Ec07baa4eD1c57d677DE9FeE1C88Cd6D`
- Empty migration reserve: `0xCF39cb2363f85d3adad4fF891bb357C1766ef292`
- Fractional sink: `0x077403e402B63Da54a594Cbd2CfC46DbC92927ad`
- Locked LP vault: `0x4b7A4F53D9b7E4B4941bc9CF74e852D55444cCBe`
- Liquidity seeder: `0xCc949C33860E0F695be3373628955D77Dd922Fee`
- Royalty splitter: `0xd8eb805e96B05cb412A1e48eb3a85B6267f901d7`

Pool id:
`0x0b142aaf734f1b063355bfe854e282a13b26dcac86e2e564e74540f9b218d069`

## Metadata

- Dark images:
  `ipfs://bafybeibxh5bcdw353ufuprmzyzmk4wwtptjkym7em6igmmwp4izzoxrjym/`
- Hardwired animations:
  `ipfs://bafybeicmrosixas4ry3mp6afuevniqbqzq72to2n65ys5umuqqzijzsmsm/`
- V2 dark metadata:
  `ipfs://bafybeig447r5kqu34u2qm5aklrvgk5igor6qe6o7ng6wmuj2vet3idiwhe/`
- V2 hardwired metadata:
  `ipfs://bafybeigl2vkhz4pwib27k6l6g5nqsvp5i6zgnhogc27csap3cltlvvx5mi/`

## Risks

- Smart contracts, wallets, marketplaces, RPCs, and the chain can fail.
- The canonical market can be volatile and illiquid.
- A 90% launch fee is intentionally punitive; verify the actual onchain
  payer fee before signing. A recipient that pays it is
  transfer-restricted for one hour.
- Hardwiring is irreversible.
- Reward volume may never materialize.
- Tokenized stocks are third-party upgradeable assets.
- The guardian and recovery Safe are trust assumptions.
- Canonical v4 settlement is enforced, but arbitrary future custom
  contracts cannot be claimed to be impossible.
- Unsupported marketplaces may reject ERC721-C transfers or listings.
- Stock-token access is restricted in some jurisdictions, including the
  United States region.
- Never risk more than you can afford to lose completely.

The longer canonical reference is served at `/llms-full.txt`.

## https://www.quotrons.cash/integration.md

# Integrate QUOTRON swaps

QUOTRON's production swap API is a verified smart contract. There is no API
key. Aggregators should `eth_call` the view quoter with `(amount, payer)`.
That returns output and the payer's hook fee without the payer holding ETH,
QUOTRON, or a router allowance. Execution still goes through the canonical
router; apply a user-approved slippage minimum before submitting.

## Live deployment

| Item | Value |
| --- | --- |
| Network | Robinhood Chain |
| Chain ID | `4663` |
| RPC | `https://rpc.mainnet.chain.robinhood.com` |
| QUOTRON | `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F` |
| Canonical router | `0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18` |
| Canonical hook | `0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc` |
| View quoter | `0xb8960fdC8A0Be155d196C2795b75747763562df2` |
| WETH | `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` |
| Pool ID | `0x0b142aaf734f1b063355bfe854e282a13b26dcac86e2e564e74540f9b218d069` |

ETH and QUOTRON use 18 decimals.

Machine-readable resources:

- [Integration manifest](/integration/manifest.json)
- [Router ABI](/integration/QuotronWethRouter.abi.json)
- [QUOTRON ABI](/integration/Quotron404V2.abi.json)
- [Hook ABI](/integration/QuotronWethHook.abi.json)
- [Quoter ABI](/integration/QuotronWethQuoter.abi.json)
- [Full project reference](/llms-full.txt)

## Why this route is canonical

The official QUOTRON/WETH v4 pool is intentionally bound to one router. The
router supplies payer and recipient context to the hook, and the token accepts
PoolManager settlement only when the hook authorizes that exact amount during
the same swap.

That path protects the WETH fee engine funding hardwired Terminal NFT rewards,
the STONK BROKERS burn, locked liquidity, and the creator carve. Integrators
call the router; they do not call PoolManager or construct hook data.

This guarantee is scoped to canonical v4 settlement. Ordinary ERC-20 transfers
remain possible, so it is not a claim that every future custom contract or
non-v4 venue is impossible.

## Router API

```solidity
function buyExactEth(
    uint256 minQuotronOut,
    address recipient,
    uint256 deadline
) external payable returns (uint256 quotronOut);

function buyExactQuotron(
    uint256 quotronOut,
    address recipient,
    uint256 deadline
) external payable returns (uint256 wethSpent);

function sellExactQuotronForEth(
    uint256 quotronIn,
    uint256 minEthOut,
    address recipient,
    uint256 deadline
) external returns (uint256 ethOut);
```

`deadline` is Unix time in seconds. `recipient` must be nonzero. Exact-output
buys revert if the payer's current fee is 50% or higher.

## View quoter

The sealed router cannot grow a `quote` function, and wrapping it would price
fees for the wrapper instead of `payer`. `QuotronWethQuoter` is a separate
read-only contract bound to the live router. It does not change the hook.

```solidity
function quoteBuyExactEth(uint256 ethIn, address payer)
    external view
    returns (uint256 quotronOut, uint256 feeBps, uint256 feeWeth, uint256 poolWethIn);

function quoteSellExactQuotron(uint256 quotronIn, address payer)
    external view
    returns (uint256 ethOut, uint256 feeBps, uint256 feeWeth, uint256 poolWethOut);

function quoteBuyExactQuotron(uint256 quotronOut, address payer)
    external view
    returns (uint256 ethIn, uint256 feeBps, uint256 feeWeth, uint256 poolWethIn);
```

`payer` is the wallet that will call the router. The quoter reads
`hook.currentFeeBps(payer)`, applies the same gross/net WETH carve the hook
uses, then runs Uniswap v4 swap math on the remaining pool amount with the
hook's 0 LP-fee override.

```ts
const QUOTER = "0xb8960fdC8A0Be155d196C2795b75747763562df2";
const quoterAbi = await fetch(
  "https://quotrons.cash/integration/QuotronWethQuoter.abi.json",
).then((response) => response.json());

const [quotronOut, feeBps, feeWeth] = await publicClient.readContract({
  address: QUOTER,
  abi: quoterAbi,
  functionName: "quoteBuyExactEth",
  args: [ethIn, account],
});
```

A sell quote does not need an approval. Still approve the router before
submitting `sellExactQuotronForEth`. Simulating the exact router call remains
a valid execution check when the payer is funded.

## Buy: quote, apply slippage, execute

The example uses viem and an injected wallet. Use `1n` only for simulation;
never submit a production swap with a placeholder minimum.

```ts
import {
  createPublicClient,
  createWalletClient,
  custom,
  http,
  parseEther,
} from "viem";

const chain = {
  id: 4663,
  name: "Robinhood Chain",
  nativeCurrency: { name: "Ether", symbol: "ETH", decimals: 18 },
  rpcUrls: {
    default: { http: ["https://rpc.mainnet.chain.robinhood.com"] },
  },
} as const;

const ROUTER = "0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18";
const routerAbi = await fetch(
  "https://quotrons.cash/integration/QuotronWethRouter.abi.json",
).then((response) => response.json());

const [account] = await window.ethereum.request({
  method: "eth_requestAccounts",
});
const publicClient = createPublicClient({ chain, transport: http() });
const walletClient = createWalletClient({
  account,
  chain,
  transport: custom(window.ethereum),
});

const ethIn = parseEther("0.1");
const deadline = BigInt(Math.floor(Date.now() / 1000) + 20 * 60);
const quote = await publicClient.simulateContract({
  account,
  address: ROUTER,
  abi: routerAbi,
  functionName: "buyExactEth",
  args: [1n, account, deadline],
  value: ethIn,
});

const slippageBps = 500n; // user-selected 5%
const minOut = (quote.result * (10000n - slippageBps)) / 10000n;
if (minOut === 0n) throw new Error("minimum output is zero");

const hash = await walletClient.writeContract({
  account,
  address: ROUTER,
  abi: routerAbi,
  functionName: "buyExactEth",
  args: [minOut, account, deadline],
  value: ethIn,
});
```

## Sell: approve, quote, execute

The canonical router pulls QUOTRON from its caller. Approve only the sale
amount and wait for the approval receipt before simulating the sell.

```ts
import { parseEther } from "viem";

const QUOTRON = "0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F";
const tokenAbi = await fetch(
  "https://quotrons.cash/integration/Quotron404V2.abi.json",
).then((response) => response.json());
const quotronIn = parseEther("1");

const approvalHash = await walletClient.writeContract({
  account,
  address: QUOTRON,
  abi: tokenAbi,
  functionName: "approve",
  args: [ROUTER, quotronIn],
});
await publicClient.waitForTransactionReceipt({ hash: approvalHash });

const sellDeadline = BigInt(Math.floor(Date.now() / 1000) + 20 * 60);
const quote = await publicClient.simulateContract({
  account,
  address: ROUTER,
  abi: routerAbi,
  functionName: "sellExactQuotronForEth",
  args: [quotronIn, 1n, account, sellDeadline],
});

const minEthOut = (quote.result * (10000n - slippageBps)) / 10000n;
if (minEthOut === 0n) throw new Error("minimum output is zero");

const sellHash = await walletClient.writeContract({
  account,
  address: ROUTER,
  abi: routerAbi,
  functionName: "sellExactQuotronForEth",
  args: [quotronIn, minEthOut, account, sellDeadline],
});
```

## Executor and aggregator contracts

The connected wallet should call the canonical router directly whenever
possible. If an executor contract calls it, that executor becomes the payer.

- On buys, the executor supplies ETH and can name the user as recipient, but
  the executor's onchain fee tier applies.
- On sells, the executor must hold QUOTRON and approve the router.
- Moving whole QUOTRON units through a non-exempt executor can materialize or
  dissolve ERC-404 Terminal NFTs.

Test the exact executor path on a fork before advertising support.

## Required preflight

1. Require chain ID `4663`.
2. Read `Quotron404V2.isLaunched()` and `paused()`.
3. Read `QuotronWethHook.paused()` and `currentFeeBps(payer)`.
4. Quote with `QuotronWethQuoter` using the actual payer address.
5. For sells, read `isTransferRestricted(payer)`, balance, and allowance.
6. Display input, quote, fee tier, slippage, and minimum output.
7. Estimate gas from the exact call. Whole-unit transitions may create or
   dissolve Terminal NFTs and increase gas use.
8. Submit only after explicit user approval.

If simulation reverts, do not send the transaction.

Support and verified addresses: [quotrons.cash/docs](https://quotrons.cash/docs)

## https://www.quotrons.cash/integration/manifest.json

```json
{
  "schemaVersion": 1,
  "updatedAt": "2026-08-14",
  "network": {
    "name": "Robinhood Chain",
    "chainId": 4663,
    "nativeCurrency": {
      "name": "Ether",
      "symbol": "ETH",
      "decimals": 18
    },
    "rpcUrl": "https://rpc.mainnet.chain.robinhood.com",
    "explorerUrl": "https://robinhoodchain.blockscout.com"
  },
  "contracts": {
    "quotron": "0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F",
    "router": "0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18",
    "hook": "0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc",
    "quoter": "0xb8960fdC8A0Be155d196C2795b75747763562df2",
    "weth": "0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73"
  },
  "canonicalPoolId": "0x0b142aaf734f1b063355bfe854e282a13b26dcac86e2e564e74540f9b218d069",
  "tradeApi": {
    "transport": "contract",
    "quoteMethod": "eth_call",
    "quoter": "quoteBuyExactEth(uint256,address)",
    "quoteSell": "quoteSellExactQuotron(uint256,address)",
    "quoteBuyExactOutput": "quoteBuyExactQuotron(uint256,address)",
    "buyExactInput": "buyExactEth(uint256,address,uint256)",
    "buyExactOutput": "buyExactQuotron(uint256,address,uint256)",
    "sellExactInput": "sellExactQuotronForEth(uint256,uint256,address,uint256)",
    "sellApprovalSpender": "0x42024fCFdB4F3089Dd619A0cEF0Cd24E7b841C18"
  },
  "abis": {
    "router": "https://quotrons.cash/integration/QuotronWethRouter.abi.json",
    "quotron": "https://quotrons.cash/integration/Quotron404V2.abi.json",
    "hook": "https://quotrons.cash/integration/QuotronWethHook.abi.json",
    "quoter": "https://quotrons.cash/integration/QuotronWethQuoter.abi.json"
  },
  "documentation": {
    "human": "https://quotrons.cash/docs",
    "integration": "https://quotrons.cash/integration.md",
    "machineReadable": "https://quotrons.cash/llms-full.txt"
  }
}
```

## https://www.quotrons.cash/migration/manifest.json

```json
{
  "meta": {
    "schema": "quotrons-v2-migration-v1",
    "generatedAt": "2026-08-13T11:58:01.114Z",
    "chainId": 4663,
    "deployBlock": "34546608",
    "snapshotBlock": "34984482",
    "snapshotBlockHash": "0xfbe4be5a06e1c2af4d3b64d2e16ca421dadf962a849dd8aca86fd1706fbb882d",
    "liquidEligibilityPolicy": "Liquid ERC-404 balances, dark ids, fractional balances, and restitution are frozen at block 34984482. Post-cutoff buys and transfers create no V2 entitlement.",
    "hardwiredOwnershipCutoffBlock": "35337540",
    "hardwiredOwnershipCutoffHash": "0x85a3668228eb45a92d4b41e042ba15058978924fe279808004ff891216250eb4",
    "hardwiredEligibilityPolicy": "Only ids already hardwired at block 34984482 receive lit copies; those ids follow V1 NFT ownership through block 35337540. Later hardwires remain dark allocations owned at block 34984482.",
    "legacy": {
      "legacy": "0x40686524e56AfF0F1446958725dCF6e6dA5381E6",
      "mirror": "0xbde7BEc47cbFc689e5E952B6cdD113A500abcd83",
      "reflections": "0x666A51Eb731a9CF79d97B4A9c64cD5a4806c877C",
      "hook": "0x5A7D914597476393794E100dDD8b70f8c3f570CC",
      "poolManager": "0x8366a39CC670B4001A1121B8F6A443A643e40951",
      "seeder": "0xe2EaE8F7eB81Bb4a5971BB65847632bc6Be6cf18",
      "owner": "0x7171E64E979265aeD6588577D1c6b60A701d7866",
      "attacker": "0xB53CcF301CF2E2283265810372a0915Defb7e53d",
      "operator": "0x2001a402E8803c1C92317c080326f1c80aA74532",
      "poisonSeed": "0x122778523DF4ddf5189218B2bAbffCb3bc351bbC"
    },
    "assignmentHash": "0xd385f0257ffb1ca15f9fb7bafba1896d1c0af0cc413d552e46145f1b36200fd0",
    "leafDomain": "0x010665319fa9e2b81786b6f4f5b644477d67ccb2402ceb0a9a6806c7c9e610e0",
    "merkleRoot": "0x1c28b8292e4784ff5cd5209dae8e8667d0648c7748c85ce09b9449af0a1a0cde",
    "leafEncoding": "keccak256(bytes.concat(keccak256(abi.encode(domain,chainId,legacy,snapshotBlock,kind,account,v1Id,v2Id,amount))))",
    "kinds": {
      "DARK": 1,
      "HARDWIRED": 2,
      "FRACTIONAL": 3,
      "RESTITUTION_DARK": 4
    },
    "leafCount": 4307,
    "accountCount": 734,
    "migrationReserveWei": "3925448872639031210668",
    "migrationReserveUnits": 3925.4488726390314,
    "conflictPolicy": "Every verified attacker receive gets one allocation. Pause-block terminal claims keep exact ids; the first non-conflicting incident event may recover the original id; repeated or colliding events receive a same-floor/same-tier replacement when capacity permits, otherwise a tier-preserving cross-floor replacement."
  },
  "accountPath": "/migration/accounts/{lowercase-address}.json"
}
```

## ABIs

- `Quotron404V2`: `name`, `symbol`, `decimals`, `UNIT`, `totalSupply`, `balanceOf`, `allowance`, `approve`, `transfer`, `isLaunched`, `paused`, `blacklisted`, `erc721TransferExempt`, `canonicalRouter`, `floorHook`
- `QuotronWethHook`: `currentFeeBps`, `markedTimeRemaining`, `isTransferRestricted`, `paused`, `launchFeesFinalized`, `canonicalRouter`, `registeredPool`, `poolRegistered`, `reflectionPot`, `burnPot`, `lpPot`
- `QuotronWethQuoter`: `quoteBuyExactEth`, `quoteSellExactQuotron`, `quoteBuyExactQuotron`, `currentFeeBps`, `router`, `hook`, `quotron`, `weth`, `poolId`
- `QuotronWethRouter`: `buyExactEth`, `buyExactQuotron`, `sellExactQuotronForEth`, `poolManager`, `quotron`, `weth`, `hook`, `wethIsCurrency0`

Full JSON for each is at `_raw/quotrons/`.
