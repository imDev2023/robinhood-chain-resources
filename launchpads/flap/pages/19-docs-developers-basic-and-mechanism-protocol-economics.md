# Flap - protocol-economics

> Source: https://docs.flap.sh/flap/developers/basic-and-mechanism/protocol-economics
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/basic-and-mechanism/protocol-economics.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/basic-and-mechanism/protocol-economics.md).

# protocol-economics

Flap charges protocol-level rates to sustain the on-chain infrastructure that powers token launches, tax settlement, and automation across all supported chains. All rates are enforced at the protocol

***

#### Bonding Curve Rate <a href="#bonding-curve-rate" id="bonding-curve-rate"></a>

A rate applied to every buy and sell against the bonding curve, taken as a percentage of the trade amount. This rate applies only during the bonding curve phase - once a token graduates to DEX, it no longer applies.

1% on BNB Chain, Robinhood, X Layer, and Monad. 2.5% on Morph.

***

#### Tax Token Protocol Rate <a href="#tax-token-protocol-rate" id="tax-token-protocol-rate"></a>

Tax tokens are subject to an additional protocol rate to support automated tax collection, settlement, and payout infrastructure.

Up to 0.3% of trade volume, regardless of the token's tax rate.

Exact rate is publicly verifiable in the protocol contract.
