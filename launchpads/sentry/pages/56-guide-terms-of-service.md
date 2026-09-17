# Sentry - Guide, Terms of Service

> Source: https://www.sentry.trading/desktop/guide#tos
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Terms of Service[](https://www.sentry.trading/desktop/guide#tos "Copy link to this section")

Last updated · July 2026

## 1. Acceptance of these terms

By accessing or using Sentry (sentry.trading, the Sentry web app, the Sentry PWA, or any associated interface), you agree to be bound by these Terms of Service. If you do not agree, do not use the service.

## 2. What Sentry is

Sentry is non-custodial software that provides:

*   A swap interface that aggregates quotes across public on-chain DEX venues (Uniswap V3, Uniswap V2, Uniswap v4 Doppler pools, and PancakeSwap V3 on Robinhood Chain; Uniswap V3 on Ink) and executes on the best route.
*   A token-launch tool that deploys ERC-20 contracts and creates locked V3 liquidity positions on the user's behalf on either chain.
*   A token-locking interface to the Sentry Token Locker, a trustless timelock contract on Robinhood Chain.
*   A bridging interface that routes ETH between Ethereum mainnet, Ink, and Robinhood Chain via Relay Protocol.
*   A domain-registration interface for ZNS _.hood_ and _.ink_ domains, premier-name auctions, and display resolution for both TLDs.
*   Paid visibility products (token boosts and featured slots), paid username changes, push notifications, and a token watchlist.
*   Encrypted server-side custody of user-elected private keys, used solely to sign user-initiated transactions.

**Fees.** In-app and guest swaps carry a 1% platform fee taken from the swap input on both supported chains; quotes shown in the interface are net of this fee. Sentry additionally receives the treasury share of trading fees accrued by locked launch liquidity (30% on Robinhood Chain, 35% on Ink; the majority belongs to each token's creator), proceeds from boosts, featured slots, and premier domain auctions, and the $10 username-change fee. Sentry does not charge fees for bridging, sending, token locking, or key export beyond network gas. Boost, featured-slot, and username-change purchases are final and non-refundable.

Sentry is **not** a broker, dealer, exchange, custodian, money transmitter, or investment advisor. Sentry does not custody user funds in a fiduciary capacity, does not facilitate fiat on-ramps or off-ramps, and does not provide investment advice or portfolio management.

## 3. Eligibility

You may use Sentry only if you are at least 18 years old (or the age of majority in your jurisdiction, whichever is greater), legally permitted to use the service in your jurisdiction, and not located in or a national of any country subject to U.S. sanctions or embargoes. By using Sentry, you represent that you meet these requirements.

## 4. Your account and your keys

Sentry accounts are created with a username and password. The password is hashed with bcrypt server-side; the plaintext is never stored. You are solely responsible for safeguarding your password. Password recovery is available only for accounts with a verified email address (added voluntarily in Settings), after identity is proven against that email and any enabled two-factor method; accounts without a verified email cannot be recovered.

Generated and imported wallets are stored as AES-256-GCM-encrypted ciphertext. You may export the plaintext private key for any wallet at any time via the Settings hub. The exported key gives you full custody — Sentry retains no ability to override or recover keys you have exported.

## 5. User-deployed tokens

Tokens deployed through Sentry's Create flow are deployed by the user and owned by the public market the moment the deploy transaction confirms. The launch sequence (renouncement, LP lock, no pre-mine — see [Launch Mechanics](https://www.sentry.trading/desktop/guide#launch-mechanics)) is mechanical and identical for every token; Sentry does not select, vet, audit, or endorse any individual token.

The fact that a token appears in Sentry's trending list, search picker, or featured slots does not constitute endorsement, recommendation, or warranty. You are solely responsible for evaluating any token you trade or deploy.

## 6. No investment advice

Nothing in the Sentry app, the Guide, this Terms of Service, the Privacy Policy, or any official Sentry communication channel (X, Telegram, email) constitutes investment advice, financial advice, legal advice, or tax advice. All trades and deploys are user-initiated. Token prices are highly volatile and may go to zero. You are solely responsible for any tax consequences of activity conducted through Sentry in your jurisdiction.

## 7. Risk disclosure

Use of Sentry involves risks including but not limited to:

*   **Smart-contract risk.** Bugs in deployed contracts (Sentry's factories, the underlying DEX contracts, Relay, ZNS, or third-party token contracts) may result in partial or total loss of funds.
*   **Market risk.** Token prices are volatile and may fall to zero, and liquidity may disappear without warning.
*   **Counterparty risk.** Third-party tokens deployed through Sentry are user-deployed and unvetted. The launch mechanics do not guarantee project quality, team integrity, or future market behavior.
*   **Regulatory risk.** The legal and regulatory treatment of token trading, token issuance, and DeFi protocols is evolving and varies by jurisdiction.
*   **Operational risk.** Software bugs, RPC failures, indexer lag, or service interruptions may affect your ability to interact with the app.
*   **Self-custody risk.** Lost passwords, lost keys, mistaken transactions, and signed transactions to malicious contracts are not recoverable by Sentry.

## 8. Prohibited uses

You agree not to use Sentry for any unlawful purpose, including but not limited to: money laundering, sanctions evasion, terrorism financing, fraud, market manipulation, deploying tokens that infringe intellectual property, or activity that violates the laws of your jurisdiction.

## 9. Disclaimer of warranties

Sentry is provided “AS IS” and “AS AVAILABLE” without warranty of any kind, express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, non-infringement, or uninterrupted availability. Sentry does not warrant that the service will meet your requirements, that operation will be uninterrupted or error-free, or that any token or transaction will perform as expected.

## 10. Limitation of liability

To the maximum extent permitted by law, Sentry, its operators, and its contributors shall not be liable for any indirect, incidental, special, consequential, exemplary, or punitive damages — including but not limited to loss of profits, loss of data, loss of tokens, loss of access, or loss of cryptocurrency value — arising out of or in connection with your use of Sentry. Aggregate liability for any direct damages shall not exceed the greater of one hundred U.S. dollars ($100) or the total fees you paid Sentry directly in the twelve months preceding the claim.

## 11. Indemnification

You agree to indemnify and hold Sentry, its operators, and its contributors harmless from any claim, demand, loss, or damage arising from your use of the service, your breach of these terms, or your violation of any law or third-party right.

## 12. Modifications

Sentry may update these terms from time to time. Material changes will be announced on Sentry's X or Telegram channel and reflected in the “Last updated” date above. Continued use of the service after a change constitutes acceptance of the updated terms.

## 13. Termination

Sentry may suspend or terminate access to the service at its sole discretion, including for violation of these terms. Termination of access does not affect your on-chain assets — you can export private keys at any time prior to termination, and funds in any wallet you hold the keys for remain under your control regardless of your access to the Sentry interface.

## 14. Governing law

These terms are governed by the laws of the State of Texas, United States, without regard to conflict-of-law principles. Any dispute arising from these terms or your use of Sentry shall be resolved in the state or federal courts located in Travis County, Texas, and you consent to personal jurisdiction there.

## 15. Contact

Questions about these terms can be directed to [@sentrylauncher](https://x.com/sentrylauncher) on X or the [Sentry Telegram](https://t.me/sentrylauncher).
