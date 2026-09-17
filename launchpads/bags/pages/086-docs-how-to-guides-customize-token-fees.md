# Bags - Customize Token Fees

> Source: https://docs.bags.fm/how-to-guides/customize-token-fees
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/how-to-guides/customize-token-fees.md)

---

# Customize Token Fees

> Learn how to configure different fee structures for your token launch using Bags config types

When launching a token via the Bags API, you can customize the fee structure by passing the optional `bagsConfigType` parameter to the [Create Fee Share Config](/api-reference/create-fee-share-configuration) endpoint. This controls how much in trading fees the token takes at different stages of its lifecycle.

## Fee Distribution

All trading fees are split between the **protocol** and the **creator**. The split depends on whether fee compounding is enabled:

| Setup           | Protocol     | Creator      | Compounding |
| --------------- | ------------ | ------------ | ----------- |
| No compounding  | 50% of fee   | 50% of fee   | —           |
| 25% compounding | 37.5% of fee | 37.5% of fee | 25% of fee  |
| 50% compounding | 25% of fee   | 25% of fee   | 50% of fee  |

For example, a 2% fee without compounding gives 1% to the protocol and 1% to the creator. A 2% fee with 25% compounding gives 0.5% to compounding, 0.75% to the protocol, and 0.75% to the creator. A 1% fee with 50% compounding gives 0.5% to compounding, 0.25% to the protocol, and 0.25% to the creator.

## Fee Modes

There are seven available fee modes. If you don't specify a `bagsConfigType`, the **Default** mode is used.

### Default

**Config ID:** `fa29606e-5e48-4c37-827f-4b03d58ee23d`

| Stage          | Total Fee | Protocol | Creator | Compounding |
| -------------- | --------- | -------- | ------- | ----------- |
| Pre-migration  | 2%        | 1%       | 1%      | —           |
| Post-migration | 2%        | 0.75%    | 0.75%   | 0.5%        |

The standard fee structure. A flat 2% fee on all trades. Pre-migration, the fee is split equally between protocol and creator. Post-migration, 25% of fees are compounded back into the pool's liquidity, with the remainder split equally between protocol and creator. This is the simplest option and works well for most token launches.

### Low Pre / High Post with Compounding

**Config ID:** `d16d3585-6488-4a6c-9a6f-e6c39ca0fda3`

| Stage          | Total Fee | Protocol | Creator | Compounding |
| -------------- | --------- | -------- | ------- | ----------- |
| Pre-migration  | 0.25%     | 0.125%   | 0.125%  | —           |
| Post-migration | 1%        | 0.25%    | 0.25%   | 0.5%        |

Lower fees during the bonding curve phase to encourage early trading volume, then a higher fee rate once the token graduates to the DAMM V2 pool. Post-migration, 50% of fees are compounded back into the pool's liquidity, deepening the order book over time.

### High Pre / Low Post with Compounding

**Config ID:** `a7c8e1f2-3d4b-5a6c-9e0f-1b2c3d4e5f6a`

| Stage          | Total Fee | Protocol | Creator | Compounding |
| -------------- | --------- | -------- | ------- | ----------- |
| Pre-migration  | 1%        | 0.5%     | 0.5%    | —           |
| Post-migration | 0.25%     | 0.0625%  | 0.0625% | 0.125%      |

Higher fees during the bonding curve phase to maximize early fee revenue, then reduced fees post-migration to encourage continued trading. Post-migration, 50% of fees are compounded back into the pool's liquidity.

### High Flat with Compounding

**Config ID:** `48e26d2f-0a9d-4625-a3cc-c3987d874b9e`

| Stage          | Total Fee | Protocol | Creator | Compounding |
| -------------- | --------- | -------- | ------- | ----------- |
| Pre-migration  | 10%       | 5%       | 5%      | —           |
| Post-migration | 10%       | 2.5%     | 2.5%    | 5%          |

A high flat 10% fee on all trades. Post-migration, 50% of fees are compounded back into the pool's liquidity, rapidly deepening the order book. Best suited for tokens that want to maximize fee revenue and liquidity growth simultaneously.

### 2% Flat with 85% Supply Locked

**Config ID:** `810faadb-030b-47de-a68b-7211c1cbbee3`

| Stage          | Total Fee | Protocol | Creator | Compounding |
| -------------- | --------- | -------- | ------- | ----------- |
| Pre-migration  | 2%        | 1%       | 1%      | —           |
| Post-migration | 2%        | 0.75%    | 0.75%   | 0.5%        |

Identical fee economics to the **Default** mode (a flat 2% fee, with 25% of post-migration fees compounded back into the pool's liquidity), but **85% of the token supply is locked**. Use this when you want the standard 2% fee structure while keeping the large majority of supply locked. This mode graduates at **\~100 SOL** rather than the usual 85 SOL.

### Default with 1K Supply

**Config ID:** `e2963a6c-441a-4862-9d80-b94e3a481cd7`

| Stage          | Total Fee | Protocol | Creator | Compounding |
| -------------- | --------- | -------- | ------- | ----------- |
| Pre-migration  | 2%        | 1%       | 1%      | —           |
| Post-migration | 2%        | 0.75%    | 0.75%   | 0.5%        |

Identical to the **Default** mode in every way (a flat 2% fee with 25% post-migration compounding), except the token launches with a **1,000 token supply**. Use this when you specifically need a 1K total supply.

### 2% Base with 96% Supply Locked

**Config ID:** `ba28db46-ea6f-4452-8218-5587f6aca0a1`

| Stage          | Total Fee                           | Protocol     | Creator      | Compounding |
| -------------- | ----------------------------------- | ------------ | ------------ | ----------- |
| Pre-migration  | 2%                                  | 1%           | 1%           | —           |
| Post-migration | 2% → 0.5% by market cap (see below) | 37.5% of fee | 37.5% of fee | 25% of fee  |

Like the **Default** mode, 25% of post-migration fees are compounded back into the pool's liquidity and the remainder is split equally between protocol and creator. This mode adds two things on top: **96% of the token supply is locked**, and a **market-cap-based fee post-migration** (starting at 2% and decaying to a 0.5% floor).

**Post-migration market-cap fee:** the 2% base fee only holds during the bonding-curve phase. Once the token graduates (raises 55 SOL and migrates to the real DAMM v2 pool), the trading fee no longer stays flat — it starts at 2% and shrinks as the token's market cap grows, down to a **0.5% floor**. The bigger and more successful the token gets, the cheaper it is to trade. The decay is exponential (it drops faster early, then eases toward the floor) and bottoms out once the market cap is roughly **25x** its value at graduation:

```text theme={null}
   1x MC (just graduated): 2.00%
  ~2x                    : ~1.45%
  ~5x                    : ~1.00%
  ~9x                    : ~0.80%
 ~15x                    : ~0.63%
 ~25x and beyond         : 0.50%   <- floor, stays here
```

In absolute terms for this mode (graduation ≈ 4,978 SOL FDV): \~2% at the start of the DAMM v2 pool, \~1% around \~25k SOL FDV, and the 0.5% floor around \~125k SOL FDV. As with the Default mode, 25% of each post-migration fee is compounded back into the pool's liquidity and the remaining 75% is split equally between protocol and creator.

## `enableFirstSwapWithMinFee`

When creating a fee share config, you can pass an optional boolean `enableFirstSwapWithMinFee` (default `true`) to the [Create Fee Share Config](/api-reference/create-fee-share-configuration) endpoint. When `true`, the **first** swap on the new pool pays the minimum (ending) base fee instead of the starting cliff fee.

This only matters for config types that use a **base-fee scheduler** (one whose base fee changes over time). **No current config type uses a base-fee scheduler, so this field has no effect right now** — you can safely omit it. It is retained for forward compatibility in case scheduler-based config types are introduced later.

## Choosing the Right Mode

| Goal                                                         | Recommended Mode                           |
| ------------------------------------------------------------ | ------------------------------------------ |
| Simple, consistent fees                                      | **Default** (2% / 2%)                      |
| Encourage early trading, earn more post-graduation           | **Low Pre / High Post** (0.25% / 1%)       |
| Maximize early fee revenue, encourage post-graduation volume | **High Pre / Low Post** (1% / 0.25%)       |
| Maximize fee revenue and liquidity growth                    | **High Flat with Compounding** (10% / 10%) |
| Standard 2% fees with most supply locked                     | **2% Flat with 85% Supply Locked**         |
| Default fees, but a 1,000 token supply                       | **Default with 1K Supply**                 |
| Lock nearly all supply; fees that fall as the token grows    | **2% Base with 96% Supply Locked**         |

<Note>
  The `bagsConfigType` is set once when creating the fee share config and cannot be changed after the token is launched. Choose your fee structure carefully before launching.
</Note>

## Graduation Thresholds

Every token launches on a bonding curve and **graduates** (migrates to a DAMM V2 pool) once it raises a set amount of SOL. Most modes graduate at **85 SOL**; the supply-locked modes differ.

| Mode                                 | SOL to graduate |
| ------------------------------------ | --------------- |
| Default                              | 85 SOL          |
| Low Pre / High Post with Compounding | 85 SOL          |
| High Pre / Low Post with Compounding | 85 SOL          |
| High Flat with Compounding           | 85 SOL          |
| 2% Flat with 85% Supply Locked       | \~100 SOL       |
| Default with 1K Supply               | 85 SOL          |
| 2% Base with 96% Supply Locked       | 55 SOL          |

## Alternative: Using the Bags CLI

<Note>
  This section requires the Bags CLI. See [Install and Set Up the Bags CLI](/cli/install-and-setup) to get started.
</Note>

You can create and manage fee share configurations directly from the terminal:

**Create a fee share config:**

```bash theme={null}
bags config create \
  --mint TOKEN_MINT \
  --fee-claimers '[{"user":"WALLET_A","userBps":5000},{"user":"WALLET_B","userBps":5000}]'
```

**Update an existing config (requires admin authority):**

```bash theme={null}
bags config update \
  --mint TOKEN_MINT \
  --fee-claimers '[{"user":"WALLET_A","userBps":7000},{"user":"WALLET_B","userBps":3000}]'
```

**Transfer admin authority to another wallet:**

```bash theme={null}
bags config transfer-admin --mint TOKEN_MINT --new-admin NEW_ADMIN_PUBKEY
```

**List all tokens where you are admin:**

```bash theme={null}
bags config admin-list
```

Add `--skip-confirm` to any command to bypass the confirmation prompt.

## What is Fee Compounding?

All seven fee modes enable **fee compounding** after migration. This means that a portion of the trading fees collected post-migration are automatically reinvested into the DAMM V2 pool's liquidity rather than being distributed. This deepens the pool over time, leading to tighter spreads and better trading conditions for the token.

The **Default** mode and the three supply-locked/supply variants (**2% Flat with 85% Supply Locked**, **Default with 1K Supply**, and **2% Base with 96% Supply Locked**) compound **25%** of post-migration fees, while the other three modes (**Low Pre / High Post**, **High Pre / Low Post**, and **High Flat with Compounding**) compound **50%**. The remaining fees are split equally between the protocol and the creator.
