# Doppler - create token, launch mode chooser

> Source: https://app.doppler.lol/ (Create token)
> Retrieved: 2026-09-02 (agent-browser read and snapshot, session lp-doppler)

---

Create token opens a slide-over titled `Choose your launch mode`.
Screenshots: `screenshots/04-app-create-launch-mode.png` (all chains), `screenshots/05-app-create-mode-robinhood.png` (Robinhood selected).

Chains offered here: Base, Robinhood, Monad, Solana.
Note that this list is shorter than the Filters list: Unichain and Ink can be browsed but not launched on from this UI.

Launch modes offered with Base selected:

- Dynamic, `Dynamic pricing`, `Tokens are placed automatically on supply curves that adjust to demand.`
- Multicurve, `Multiple curve pricing`, `Launch with multiple pricing curves and distribution settings.`

**With Robinhood selected the Dynamic card disappears and Multicurve is the only mode offered.**
That matches the indexer, where 108,698 of 109,159 Doppler assets on chain 4663 were created through DopplerHookInitializer (multicurve) and only 4 through UniswapV4Initializer (dynamic).

```text
Select how you want to price and distribute your token

BaseRobinhoodMonadSolana

### Dynamic

Dynamic pricing

Tokens are placed automatically on supply curves that adjust to demand.

### Multicurve

Multiple curve pricing

Launch with multiple pricing curves and distribution settings.
```
