> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/prebond-tax.md).

# PreBond Tax

Flap supports Tax tokens. Since V5.4.0 (on BNB Chain & XLayer) , tax is not only applied to migrated tax tokens but also the ones that are still on the bonding curve.

When a tax token has already migrated DEX, it will charges a tax on every trade through the main pool and accumulate the tax in the token first. Once the accumulated token amount reaches a specific liquidation threshold, an automatic liquidation happens to sell the token for quote and sent the the beneficiary through the Tax Splitter. (Check below to learn more detaills)

When a tax token is still on the bonding curve, we don’t implement it as a “real tax” like a migrated one. To make it simple and easy to do an off-chain quote, we implement it as an `extra fee` added upon the current bonding curve fee.

For example:

* For a non-tax token, the current bonding curve fee on BNB chain is 1%.
* For a token with a tax of 3%, the effective trading fee becomes: 1% + 3% = 4%
* For a token with a tax of 1%, the effective trading fee is 2%
