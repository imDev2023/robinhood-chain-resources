# HOOD10 - X profile (@hood10xyz)

> Source: https://x.com/hood10xyz
> Retrieved: 2026-09-02 (Jina Reader and Bright Data unlocker; raw in `_raw/jina-x-hood10xyz.md` and `_raw/bdata-x-hood10xyz.md`)

---

## Profile

| field | value |
| --- | --- |
| Display name | HOOD10 Index |
| Handle | @hood10xyz |
| User id | 2088616374767689728 |
| Bio | Ten Tokens, One Ticker. The Index of @RobinhoodCrypto Chain. Launchpad: launch.hood10.xyz |
| Website | hood10.xyz |
| Joined | August 2026 |
| Following | 2 |
| Followers | 2,710 |
| Posts | 56 |
| Verified | false |

The account is the only official channel found for the project.
No Telegram group, Discord server, Medium, Mirror, Dune dashboard, GitHub organisation or RootData entry was discoverable from either site, from the docs, from the app bundles, or from a Bright Data search (`_raw/bdata-search-hood10.json`).
The launchpad's own create form asks a creator for a website, an X handle and a Telegram, so the absence is the project's choice rather than a capture failure.

## Verbatim timeline as rendered

The profile page renders the pinned post plus a login wall.
Both captures agree on this text.

> Pinned, Aug 29
>
> Introducing HOOD10 LAUNCHPAD. LIVE on launch.hood10.xyz
> Launch your own coin and pair it with anything. A meme. A stock. A stable. Or $HOOD10 itself.
> Free to launch. Liquidity locked forever. Every trade buys and burns $HOOD10.
> More details and builder incentives to come.

> Over $330,000 has been distributed to HOOD10 holders thus far.
> Most of the dividends would have grown substantially in value if you had held since Day 1.
> With the Index constantly evolving and new tokens entering the Top 10, HOOD10 keeps you exposed to wherever the action goes.

> The HOOD10 Launchpad has surpassed $5M in total trading volume in just two days.
> Check out some of the latest projects trending on the Launchpad: GOONER @gooneronhood, FLYWHEEL @flywheelhood10, WIRED @wiredfi.

Full text, timestamps and engagement for the five posts pulled through the Bright Data pipeline are in `02-x-hood10xyz-posts.md`.

## Handles named by the account

| handle | relationship |
| --- | --- |
| @RobinhoodCrypto | the chain, named in the bio |
| @gooneronhood | GOONER, a launchpad coin, and the first reflection launch (pool `0x5e5b5f...`) |
| @flywheelhood10 | FLYWHEEL, a launchpad coin, the sample `LaunchToken` in `contracts/` |
| @wiredfi | WIRED, a launchpad coin |
| @letscashfun | not named by @hood10xyz, but the venue the HOOD10 token itself launched on. See `03-x-letscashfun-and-cashcat.md` |

## Capture notes

`bdata pipelines x_posts` refuses a profile URL: it accepts only `https://x.com/<user>/status/<id>`.
The error is preserved in `_raw/bdata-x-hood10xyz.err`.
The X syndication endpoint `https://syndication.twitter.com/srv/timeline-profile/screen-name/hood10xyz` returns a page with no timeline payload for this account (2,221 bytes, `_raw/x/syndication-hood10xyz.html`), although it works for other handles on the same day, so it is not a general block.
