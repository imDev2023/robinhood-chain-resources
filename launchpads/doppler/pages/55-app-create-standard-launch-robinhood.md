# Doppler - create token, Standard launch wizard on Robinhood

> Source: https://app.doppler.lol/ (Create token -> Robinhood -> Multicurve -> Standard launch)
> Retrieved: 2026-09-02 (agent-browser walk-through, session lp-doppler)

---

The Standard launch radio turns the single form into a five-step wizard.
The step rail reads: 1 Basics, 2 Details, 3 Pricing, 4 Economics, 5 Review.
Steps unlock in order; each later step is disabled until the current one validates.

The whole wizard was walked with no wallet connected, using the placeholder token `Archive Probe` / `$PROBE` and a 64x64 solid-colour PNG.
No transaction was signed.
The last screen's submit control reads `Connect wallet`.

## Step 1, Basics

Screenshot: `screenshots/08-app-create-standard-step1.png`.
Same fields as Quick launch: token image (required), token name, token symbol, Network, Numeraire, Social links (optional).
Continue stays disabled until an image is uploaded.

## Step 2, Details

Screenshot: `screenshots/09-app-create-standard-2-details.png`.
Heading `Project details`.
All optional:

- A free-text box, placeholder `Tell people about your project, why you're raising, etc.`
- `+ Add team member`
- `+ Add fundraising round`
- `+ Add milestone`
- A `Documents` switch, default off

None of this is on-chain; it is launch-page metadata.

## Step 3, Pricing

Screenshots: `screenshots/10-app-create-standard-3-pricing.png` (Visual), `screenshots/11-app-create-standard-3-pricing-table.png` (Table).
Heading `Supply curves`, subtitle `Define the bonding curves that will determine your token's price trajectory.`
A Visual / Table toggle, a `+ Add Curve` button, and a `Cumulative` switch sit above the chart.
The chart plots Supply against Market Cap on a log axis from $1K to $1.0B.

The default three curves shipped by the app, plus a fourth read-only tail curve:

| curve | start market cap | end market cap | share of supply |
| --- | --- | --- | --- |
| Curve 1 | $5,000 | $10,000,000 | 75% |
| Curve 2 | $100,000 | $40,000,000 | 12.5% |
| Curve 3 | $1,000,000 | $1,000,000,000 | 11.5% |
| tail (disabled) | $1,000,000,000 | infinity | 1% |

The three editable curves total 99%; the locked tail curve carries the last 1%, so the four sum to 100%.
The placeholder text in the empty Table inputs is `250,000` for start market cap, `3,000,000` for end market cap and `25` for share, which is what a hand-added curve defaults to.

## Step 4, Economics

Screenshot: `screenshots/12-app-create-standard-4-economics.png`.
Heading `Economics`, subtitle `Configure pricing, supply, fees, and distribution.`
An `Allocation Preview` donut on the right reads TOTAL 100%, SALE 100%.

Supply and allocation:

- Total supply, default `1,000,000,000`
- Tokens to sell, default `100` percent
- Vesting duration, default `365` days
- `Recipients (0)` with a `+ Add` button.
  Helper text: `Maximum total grant percentage: 0%` and `Any unallocated tokens will be burned.` The grant ceiling is zero because Tokens to sell is 100%.
- Each recipient row is Alias, Recipient Address, Percentage.

Fee tiers, described as `Earnings from providing liquidity. Choose based on your risk and strategy.`

- Preset buttons `1%`, `2%`, `3%`
- A `Custom fee tier` box, validated as `Custom fee must be between 0% and 10%.`
- A `Default` / `Buy & Burn` pair for what happens with earned fees
- A currency button reading `ETH`, with the note `Fees will be earned in both this token and ETH and distributed to your fee beneficiaries.`

Fee beneficiaries:

- `Fee Beneficiaries (0)` with `+ Add`, rows of Address and Fee %
- Helper text, verbatim: `Addresses that will receive fees from the liquidity pool. 5% is reserved for Doppler Protocol. The remaining 95% can be distributed among fee beneficiaries.`
- One disabled row is always rendered under the empty list, labelled `Doppler Protocol` with a greyed `5` in the Fee % box.
  It is a placeholder showing the reserved share, not an editable entry.
  The Recipients list renders the same kind of disabled placeholder row, labelled `Doppler Protocol` at `100`

The 5% floor is enforced on-chain, not just in the UI: `MIN_PROTOCOL_OWNER_SHARES = WAD / 20` in `contracts/DopplerHookMigrator-0x7bf319d8e969f7596b1bc171da9ce322f67ae0c4/sources/src/types/BeneficiaryData.sol`.
The 10% UI ceiling on the fee tier is stricter than the contract, which allows `MAX_LP_FEE = 150_000`, that is 15%.

## Step 5, Review

Screenshots: `screenshots/13-app-create-standard-5-review.png`, `screenshots/14-app-create-standard-5-governance.png`.
Heading `Review & confirm`, subtitle `Please review all details before creating your token.`

Summary rendered for the placeholder launch:

| field | value |
| --- | --- |
| Token | Archive Probe ($PROBE) |
| Mode | Multicurve |
| Total supply | 1.0B |
| For sale | 100% |
| Curves | 3 |
| Fee tier | 1% |
| Fee earnings | Default |
| Token allocation #1 | Doppler Market, 100.00% |

Below the allocation chart is an `Add governance` switch, default off.
Toggling it on changed no other visible field.

Warning text, verbatim: `This action launches a new token on Robinhood and cannot be undone. Please verify all details are correct.`
The submit control is `Connect wallet`.

## Raw step-3 accessibility snapshot

```text
- heading "Supply curves" [level=2, ref=e13]
- button "Visual" [ref=e21]
- button "Table" [ref=e22]
- button "+ Add Curve" [ref=e23]
- switch [checked=false, ref=e24]
- SvgRoot "12.5%$100K$40M11.5%$1.0M$1.0B75%$5K$10M0%20%40%60%80%100%$1K$10K$100K$1.0M$10M$100M$1.0BMarket CapSu" [ref=e25] clickable [onclick]
  - graphics-symbol [ref=e37] clickable [cursor:pointer, onclick]
  - graphics-symbol [ref=e38] clickable [cursor:pointer, onclick]
  - graphics-symbol [ref=e39] clickable [cursor:pointer, onclick]
  - graphics-symbol [ref=e40] clickable [cursor:pointer, onclick]
  - graphics-symbol [ref=e41] clickable [cursor:pointer, onclick]
  - graphics-symbol [ref=e42] clickable [cursor:pointer, onclick]
- generic "Curve 1Start Market Cap$End Market Cap$Share %%" [ref=e26] clickable [cursor:pointer]
  - button "Select Curve 1" [ref=e43]
  - button "Delete curve" [ref=e52]
  - textbox [ref=e53]: 5K
  - textbox [ref=e54]: 10.00M
  - textbox [ref=e55]: 75
- generic "Curve 2Start Market Cap$End Market Cap$Share %%" [ref=e27] clickable [cursor:pointer]
  - button "Select Curve 2" [ref=e44]
  - button "Delete curve" [ref=e56]
  - textbox [ref=e57]: 100K
  - textbox [ref=e58]: 40.00M
  - textbox [ref=e59]: 12.5
- generic "Curve 3Start Market Cap$End Market Cap$Share %%" [ref=e28] clickable [cursor:pointer]
  - button "Select Curve 3" [ref=e45]
  - button "Delete curve" [ref=e60]
  - textbox [ref=e61]: 1.00M
  - textbox [ref=e62]: 1.00B
  - textbox [ref=e63]: 11.5
- button "Back" [ref=e14]
- button "Continue" [ref=e15]
- button "Close" [ref=e29]
- generic ".group:hover {\n                --charging-filter: drop-shadow(0 0 15px rgba(51, 137, 230, 0.4)) drop" [ref=e100] clickable [cursor:pointer]
- button "Buy" [ref=e101]
```
