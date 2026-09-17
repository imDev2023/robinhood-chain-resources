# Doppler - app filters panel

> Source: https://app.doppler.lol/ (Filters panel)
> Retrieved: 2026-09-02 (agent-browser snapshot, session lp-doppler)

---

The Filters panel is where the chain and the launching application are chosen.
Screenshot: `screenshots/02-app-filters.png`.

Chains offered: All chains, Base, Robinhood, Monad, Unichain, Ink, Solana.

Applications offered: All applications, Doppler, Ohara, Frame, Duels, Coop Records, Paragraph, fxhash, Noice, Bonk, Zora, Bankr, Long, Feel.

Other controls: a `Verified by Doppler` switch (default off), and an Advanced section with three range pickers.
Range buckets seen, in panel order:

- Any, Under $10K, $10K-$50K, $50K-$500K, $500K+
- Any, Under $1K, $1K-$10K, $10K-$100K, $100K+
- Any, Under $5K, $5K-$50K, $50K-$500K, $500K+

Selecting a chain does not change the URL; the filter is client state only.

```text
- link "Doppler" [ref=e11, url=https://app.doppler.lol/]
- button "Home" [ref=e12]
- button [ref=e15]
- button "Create token" [ref=e13]
- button "Portfolio" [ref=e14]
- button "Menu" [ref=e16]
- button "All" [ref=e2]
- button "Upcoming" [ref=e9]
- button "Filters" [ref=e10]
- button "All chains" [ref=e17]
- button "Base" [ref=e18]
- button "Robinhood" [ref=e19]
- button "Monad" [ref=e20]
- button "Unichain" [ref=e21]
- button "Ink" [ref=e22]
- button "Solana" [ref=e23]
- button "All applications All applications" [ref=e24]
- button "Doppler Doppler" [ref=e25]
- button "Ohara" [ref=e26]
- button "Frame" [ref=e27]
- button "Duels" [ref=e28]
- button "Coop Records" [ref=e29]
- button "Paragraph" [ref=e30]
- button "fxhash" [ref=e31]
- button "Noice" [ref=e32]
- button "Bonk" [ref=e33]
- button "Zora Zora" [ref=e34]
- button "Bankr Bankr" [ref=e35]
- button "Long" [ref=e36]
- button "Feel Feel" [ref=e37]
- LabelText "Verified by Doppler" [ref=e38] clickable [cursor:pointer]
  - switch "Verified by Doppler" [checked=false, ref=e56]
- button "Advanced" [ref=e39]
- button "Any" [ref=e40]
- button "Under $10K" [ref=e41]
- button "$10K-$50K" [ref=e42]
- button "$50K-$500K" [ref=e43]
- button "$500K+" [ref=e44]
- button "Any" [ref=e45]
- button "Under $1K" [ref=e46]
- button "$1K-$10K" [ref=e47]
- button "$10K-$100K" [ref=e48]
- button "$100K+" [ref=e49]
- button "Any" [ref=e50]
- button "Under $5K" [ref=e51]
- button "$5K-$50K" [ref=e52]
- button "$50K-$500K" [ref=e53]
- button "$500K+" [ref=e54]
- button "Apply" [disabled, ref=e55]
- button "Pulse view" [ref=e57]
- button "Grid view" [ref=e58]
- button "List view" [ref=e59]
- button "Connect" [ref=e3]
```
