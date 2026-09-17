# Bags - Address Lookup Tables (LUTs)

> Source: https://docs.bags.fm/principles/lookup-tables
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/principles/lookup-tables.md)

---

# Address Lookup Tables (LUTs)

> Public LUTs maintained by Bags and how to use them

### Overview

Solana Address Lookup Tables (LUTs) let you reference many accounts in a transaction without having to include their full 32-byte public keys directly. This reduces transaction size and helps you fit more instructions per transaction.

Bags maintains a public LUT that contains the most commonly used accounts across our APIs and products. You can use it for all Bags-related transactions.

* Mainnet-beta LUT address: `Eq1EVs15EAWww1YtPTtWPzJRLPJoS6VYP9oW9SbNr3yp`

<Note>
  The LUT is updated over time as our products evolve. If you have suggestions for accounts or providers to include, reach out to us.
</Note>

### What's inside

* Core program IDs and frequently used accounts for Bags workflows
* Accounts related to token launches, fee sharing/claiming, and post-launch liquidity
* Well-known tipping provider recipient wallets (see below)

You can inspect the table contents via your RPC or CLI to confirm which accounts are currently included.

### Using the LUT in transactions

* Include the LUT address when compiling or building your transaction message so that account keys are resolved from the table at runtime.
* The transaction fee payer must have access to the LUT on mainnet-beta; no special permissions are required to read from a public LUT.
* LUT usage is optional for most transactions. Your transactions will still work without it, but may be larger.

### When LUTs are Required

For fee share configurations, LUTs are **required** when you have more than 15 fee claimers. The SDK provides a helper function `getConfigCreationLookupTableTransactions()` to create the necessary LUT transactions:

1. Create the LUT creation transaction
2. Execute the creation transaction
3. Wait for one slot to pass (required by Solana)
4. Execute all LUT extend transactions
5. Pass the LUT addresses to `createBagsFeeShareConfig` via `additionalLookupTables`

See the [Launch a Token](/how-to-guides/launch-token) guide for a complete example of LUT creation and usage.

### Recommended tip recipients (from the Bags LUT)

While you can tip any valid Solana address, we recommend using a provider wallet that is already present in our LUT for convenience and compact transactions. Current provider recipients included in the LUT:

* Jito:
  * `96gYZGLnJYVFmbjzopPSU6QiEV5fGqZNyN9nmNhvrZU5`
  * `HFqU5x63VTqvQss8hp11i4wVV8bD44PvwucfZ2bU7gRe`
  * `Cw8CFyM9FkoMi7K7Crf6HNQqf4uEMzpKw6QNghXLvLkY`
  * `ADaUMid9yfUytqMBgopwjb2DTLSokTSzL1zt6iGPaS49`
  * `DfXygSm4jCyNCybVYYK6DwvWqjKee8pbDmJGcLWNDXjh`
  * `ADuUkR4vqLUMWXxW9gh6D6L8pMSawimctcNZ5pGwDcEt`
  * `DttWaMuVvTiduZRnguLF7jNxTgiMBZ1hyAumKUiL2KRL`
  * `3AVi9Tg9Uo68tJfuvoKvqKNWKkC5wPdSSdeBnizKZ6jT`

* bloXroute:
  * `HWEoBxYs7ssKuudEjzjmpfJVX7Dvi7wescFsVx2L5yoY`
  * `95cfoy472fcQHaw4tPGBTKpn6ZQnfEPfBgDQx6gcRmRg`
  * `3UQUKjhMKaY2S6bjcQD6yHB7utcZt5bfarRCmctpRtUd`
  * `FogxVNs6Mm2w9rnGL1vkARSwJxvLE8mujTv3LK8RnUhF`

* Astral:
  * `astrazznxsGUhWShqgNtAdfrzP2G83DzcWVJDxwV9bF`
  * `astra4uejePWneqNaJKuFFA8oonqCE1sqF6b45kDMZm`
  * `astra9xWY93QyfG6yM8zwsKsRodscjQ2uU2HKNL5prk`
  * `astraRVUuTHjpwEVvNBeQEgwYx9w9CFyfxjYoobCZhL`
  * `astraEJ2fEj8Xmy6KLG7B3VfbKfsHXhHrNdCQx7iGJK`
  * `astraubkDw81n4LuutzSQ8uzHCv4BhPVhfvTcYv8SKC`
  * `astraZW5GLFefxNPAatceHhYjfA1ciq9gvfEg2S47xk`
  * `astrawVNP4xDBKT7rAdxrLYiTSTdqtUr63fSMduivXK`

<Tip>
  See the tipping guide for how to include a tip in Bags-generated transactions. Using a recipient already in the LUT keeps transactions as compact as possible.
</Tip>

### Propose additions

If you operate a relevant service or have account suggestions that should be in our LUT, please reach out. We're happy to review and expand coverage where it benefits developers.
