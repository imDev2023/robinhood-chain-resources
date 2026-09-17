# Pools.trade - robots.txt and web app manifest

> Source: https://pools.trade/robots.txt and https://pools.trade/manifest.webmanifest
> Retrieved: 2026-09-02 (curl; files are `_raw/site/robots.txt` and `_raw/site/manifest.webmanifest`)

---

Both files are short and both say something about the operator, so they are recorded verbatim.

## robots.txt

```text
# Not for public search yet.
#
# Indexing is blocked by `<meta name="robots" content="noindex, nofollow">`
# (see app/root.tsx), NOT by a Disallow rule here. That is deliberate:
#
#   - A crawler must be able to fetch the page to see the noindex. `Disallow: /`
#     would hide the noindex, and Google can still list a disallowed URL it
#     found via an inbound link - so it is both weaker and less predictable.
#   - Twitterbot, Slackbot-LinkExpanding and facebookexternalhit honour
#     robots.txt. `Disallow: /` would stop them fetching the page and every
#     link unfurl would fall back to a bare URL.
#
# So: crawling is allowed, indexing is not.
User-agent: *
Allow: /
```

The em dash in the original has been replaced with a hyphen to satisfy this archive's writing rules; the file itself is unchanged on disk at `_raw/site/robots.txt`.

The live pages still carry `<meta name="robots" content="noindex, nofollow">`, so the whole site is deliberately excluded from search while it is in beta.

## manifest.webmanifest

```json
{
  "id": "/",
  "name": "Pools",
  "short_name": "Pools",
  "description": "Robinhood Chain launchpad built by Uniswap Labs. Launch a token, discover new ones, and trade them end to end.",
  "start_url": "/",
  "scope": "/",
  "display": "browser",
  "background_color": "#131313",
  "theme_color": "#131313",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png", "purpose": "any" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" },
    { "src": "/icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ]
}
```

`"Robinhood Chain launchpad built by Uniswap Labs"` is the site's own claim of ownership.
It is corroborated rather than trusted; see `README.md` section 2.

## Page head

The rendered home document (`_raw/site/home.html`) carries:

```text
<title>Pools - create a token on Robinhood Chain</title>
<meta name="twitter:site" content="@TradePools">
<meta property="og:url" content="https://pools.trade">
<link rel="canonical" href="https://pools.trade">
```

and preloads `Basel-Grotesk-Book` and `Basel-Grotesk-Medium`, the Uniswap brand typeface.
