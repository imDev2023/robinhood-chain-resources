# Bags - Initial Buy Math

> Source: https://docs.bags.fm/how-to-guides/initial-buy-math
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/how-to-guides/initial-buy-math.md)

---

# Initial Buy Math

> Calculate how many tokens you receive for your initial buy using the Meteora Dynamic Bonding Curve SDK

In this guide, you'll learn how to estimate the initial buy token amount you receive when buying with SOL. This is useful to understand what percentage of the supply you would get for a given SOL amount before executing a buy.

## Prerequisites

Before starting, make sure you have:

* Node.js (v18 or higher) and npm.
* A Solana RPC URL (e.g. from [Helius](https://helius.dev), or a public endpoint).
* Installed the required dependencies:
  ```bash theme={null}
  npm install @meteora-ag/dynamic-bonding-curve-sdk @solana/web3.js bn.js
  ```

## 1. Set Your RPC and Curve Parameters

Create a file (e.g. `estimate-allocation.ts`) and set your RPC URL.

## 2. Token Allocation Script

The following script uses the Meteora Dynamic Bonding Curve SDK to get a **swap quote** for a given SOL amount (in lamports). The function returns the **token amount** you would receive (in token units, 9 decimals). You can then compute the percentage of supply as `(tokenAmount / totalSupply) * 100` if you have the token's total supply.

```typescript theme={null}
import { DynamicBondingCurveClient } from '@meteora-ag/dynamic-bonding-curve-sdk';
import { BaseFeeMode, CollectFeeMode } from '@meteora-ag/dynamic-bonding-curve-sdk';
import { Connection } from '@solana/web3.js';
import BN from 'bn.js';

const RPC_URL = "";
const SOLANA_CONNECTION = new Connection(RPC_URL);
const BONDING_CURVE_CLIENT = new DynamicBondingCurveClient(SOLANA_CONNECTION, 'processed');

const SQRT_START_PRICE = new BN('3141367320245630');
const MIGRATION_QUOTE_THRESHOLD = new BN(85000000000);

const BASE_FEE_CLIFF_FEE_NUMERATOR = new BN('20000000');
const BASE_FEE_FIRST_FACTOR = 0;
const BASE_FEE_SECOND_FACTOR = new BN('0');
const BASE_FEE_THIRD_FACTOR = new BN('0');
const BASE_FEE_MODE = BaseFeeMode.FeeSchedulerLinear;

const COLLECT_FEE_MODE = CollectFeeMode.QuoteToken;

const CURVE = [
    {
        sqrtPrice: new BN('6401204812200420'),
        liquidity: new BN('3929368168768468756200000000000000'),
    },
    {
        sqrtPrice: new BN('13043817825332782'),
        liquidity: new BN('2425988008058820449100000000000000'),
    },
];

export const getOutputAmountOfInitialBuy = async (initialBuyIn: string): Promise<string | null> => {
    try {
        const quote = await BONDING_CURVE_CLIENT.pool.swapQuote({
            virtualPool: {
                quoteReserve: new BN(0),
                sqrtPrice: SQRT_START_PRICE,
                activationPoint: new BN(0),
                volatilityTracker: {
                    volatilityAccumulator: new BN(0),
                },
            } as any,
            config: {
                collectFeeMode: COLLECT_FEE_MODE,
                migrationQuoteThreshold: MIGRATION_QUOTE_THRESHOLD,
                poolFees: {
                    baseFee: {
                        cliffFeeNumerator: BASE_FEE_CLIFF_FEE_NUMERATOR,
                        firstFactor: BASE_FEE_FIRST_FACTOR,
                        secondFactor: BASE_FEE_SECOND_FACTOR,
                        thirdFactor: BASE_FEE_THIRD_FACTOR,
                        baseFeeMode: BASE_FEE_MODE,
                    },
                    dynamicFee: {
                        initilized: new BN(0),
                    },
                },
                curve: [
                    {
                        sqrtPrice: CURVE[0].sqrtPrice,
                        liquidity: CURVE[0].liquidity,
                    },
                    {
                        sqrtPrice: CURVE[1].sqrtPrice,
                        liquidity: CURVE[1].liquidity,
                    },
                ],
            } as any,
            swapBaseForQuote: false,
            amountIn: new BN(initialBuyIn),
            slippageBps: 0,
            hasReferral: false,
            currentPoint: new BN(0),
        });

        return quote.outputAmount.div(new BN(10 ** 9)).toString();
    } catch (err) {
        console.error(err);
        return null;
    }
};
```

## 3. Using the Function

* **Input**: `initialBuyIn` is the SOL amount in **lamports** (1 SOL = 1,000,000,000 lamports).
* **Output**: The function returns the token amount you receive (in token base units, 9 decimals), or `null` on error.

Example: to see how many tokens you get for 1 SOL:

```typescript theme={null}
const tokenAmount = await getOutputAmountOfInitialBuy((1e9).toString()); // 1 SOL in lamports
console.log("Tokens received:", tokenAmount);
// To get % of supply: (Number(tokenAmount) / totalSupply) * 100
```
