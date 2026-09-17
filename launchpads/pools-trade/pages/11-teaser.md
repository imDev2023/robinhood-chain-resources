# Pools.trade - Teaser route

> Source: https://pools.trade/teaser
> Retrieved: 2026-09-03 (agent-browser read, plus the route bundle `_raw/js/teaser-DxMrRqxW.js`)

---

Screenshot: `screenshots/22-teaser.png`.

`/teaser` is a real route in the React Router manifest and still resolves, but `agent-browser read` returns an empty document.
It is the pre-launch splash that ran before 2026-08-05, and its countdown has expired, so it renders nothing.

The strings are still in the shipped bundle and are worth recording because they are the site's own description of itself before launch:

```js
f = {
  tabTitle: `Something new`,
  ogTitle: `Pools`,
  ogDescription: `Coming soon from Uniswap`,
  comingSoon: `Coming soon`,
  deploying: `DEPLOYING`,
  untilLaunch: `until launch`,
  ogImageAlt: `The Pools droplet mark and wordmark on a dark green background.`
}
```

The route also preloads `/fonts/terminal-grotesque.woff2`, a different face from the Basel Grotesk used by the live app.
