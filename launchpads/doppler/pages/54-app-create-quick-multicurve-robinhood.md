# Doppler - create token, Quick multicurve on Robinhood

> Source: https://app.doppler.lol/ (Create token -> Robinhood -> Multicurve)
> Retrieved: 2026-09-02 (agent-browser read and eval, session lp-doppler)

---

Screenshots: `screenshots/06-app-create-quick-multicurve-robinhood.png`, and the open numeraire dropdown at `screenshots/07-app-create-numeraire-list.png`.

The form opens on the `Quick launch` radio, described as `Use the default pricing, supply, fees, and distribution settings.`
The alternative is `Standard launch`, `Customize details, pricing curves, economics, and launch settings.` (captured in `pages/55-app-create-standard-launch-robinhood.md`).

Quick launch fields, in form order:

1. Token image.
   Drag and drop or Upload image.
   Required: the Continue button stays disabled until an image is attached.
2. Token name.
   Free text.
3. Token symbol.
   Free text, prefixed `$` in the UI.
4. Network.
   A dropdown, pre-set to the chain chosen on the previous screen (Robinhood).
5. Numeraire.
   A dropdown, default ETH.
6. Social links (optional).
   A collapsed section.

The live preview card on the right shows `MC $5,000`, the starting market cap of the default first curve.
The submit control reads `Connect wallet`; nothing can be signed without one.

## Numeraire options (98 total)

Raw capture: `_raw/network/app-create-numeraire-options.json`.

ETH and USDG first, then tokenized Robinhood stock tokens in alphabetical order:

```text
ETH, USDG, AAOI, AAPL, AMAT, AMD, AMZN, APLD, ASML, ASTS, AVGO, BA, BABA, BE, CBRS, CCL, CELH, CLSK, COIN, COST, CRCL, CRWD, CRWV, DDOG, DELL, ELF, EWY, F, FLNC, FUTU, GLW, GME, GOOGL, INOD, INTC, INTU, IONQ, IREN, LITE, LLY, LULU, LUNR, MDB, META, MRVL, MSFT, MSTR, MU, MXL, NBIS, NFLX, NNE, NOW, NU, NVDA, NVTS, ORCL, P, PENG, PLTR, POET, PR, QBTS, QCOM, QQQ, QUBT, RBLX, RDDT, RDW, RGTI, RIVN, RKLB, SATS, SGOV, SHOP, SKHY, SLV, SMCI, SNDK, SOFI, SOXX, SPCX, SPMO, SPY, TSEM, TSLA, TSM, TTWO, UMC, UPS, USAR, USO, WDAY, XLK, XNDU, XOM, ZM, ZS
```

## Rendered form text

```text
## Token details

Set up your token's identity and social presence.

Quick launchUse the default pricing, supply, fees, and distribution settings.Standard launchCustomize details, pricing curves, economics, and launch settings.

Token image

Drag and drop orUpload image

Token name

Token symbol

$

Network

Robinhood

Numeraire

ETH

Social links (optional)

Connect wallet

TOKE

Robinhood

$TOKEN·TOKEN

MC$5,0000%

Buy
```
