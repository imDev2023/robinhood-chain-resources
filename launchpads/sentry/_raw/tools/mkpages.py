# Builds resources/launchpads/sentry/pages/ from the raw captures on disk.
# Re-runnable: it clears pages/ first and regenerates everything.
import os, re, glob, json

BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/sentry"
R, P = BASE + "/_raw", BASE + "/pages"
os.makedirs(P, exist_ok=True)
for f in glob.glob(P + "/*.md"):
    os.remove(f)

manifest = []
n = 0


def jina(path):
    s = open(path, encoding="utf-8", errors="replace").read()
    i = s.find("Markdown Content:")
    body = s[i + len("Markdown Content:"):].strip() if i >= 0 else s.strip()
    warn = [l for l in s[:i].splitlines() if l.startswith("Warning:")] if i >= 0 else []
    return body, warn


def write(slug, title, url, method, body, note="", warnings=None, raw=None, shots=None):
    global n
    n += 1
    fn = "%02d-%s.md" % (n, slug)
    L = ["# Sentry - %s" % title, "", "> Source: %s" % url,
         "> Retrieved: 2026-09-02 (%s)" % method]
    if raw:
        L.append("> Raw capture: `%s`" % raw)
    L += ["", "---", ""]
    if note:
        L += [note, ""]
    if shots:
        L += ["Screenshots: " + ", ".join("`screenshots/%s`" % s for s in shots) + ".", ""]
    if warnings:
        L += ["Capture warnings from the tool: " + "; ".join(w.replace("Warning: ", "") for w in warnings), ""]
    L.append(body)
    open(P + "/" + fn, "w").write("\n".join(L).rstrip() + "\n")
    manifest.append((fn, title, url))
    return fn


def ab(name):
    return open("%s/ab/%s" % (R, name), encoding="utf-8", errors="replace").read().strip()


# ---------------------------------------------------------------- app views
b, w = jina(R + "/jina/sentry-root.md")
write("app-discover-tokens", "Discover, the token list at sentry.trading",
      "https://www.sentry.trading/", "Jina Reader",
      b, note=("The app is a single-page React app. `/` and `/desktop/tokens` render the same Discover list.\n"
               "The list header reads `183 Sentry markets` on Robinhood Chain on the capture date; the Sentry subgraph counted 185 launches at block 52844801 (`_raw/api/goldsky-sentry-robinhood-protocol.json`), the difference being two tokens the app's own database does not list.\n"
               "Every row links to the Blockscout address page, the project website, X and Telegram where the creator supplied them."),
      warnings=w, raw="_raw/jina/sentry-root.md", shots=["01-sentry-root-tokens.png"])

b, w = jina(R + "/jina/sentry-root-ref-cruelhand.md")
write("app-referral-landing", "Referral landing, /?ref=CRUELHAND",
      "https://www.sentry.trading/?ref=CRUELHAND", "Jina Reader",
      b, note=("A `?ref=<code>` query parameter turns the landing screen into the sign-up screen with the referrer pre-attached.\n"
               "Per the guide's referral section, a referred account's 1% swap fee is paid to the referrer instead of Sentry, and the referred user's cost does not change.\n"
               "This capture also shows the sign-up form: username, password of at least 8 characters, and a `Create a new Sentry Account` checkbox."),
      warnings=w, raw="_raw/jina/sentry-root-ref-cruelhand.md")

write("app-token-detail-views", "Token detail pages, sixteen captured views",
      "https://www.sentry.trading/desktop/tokens (token rows)", "agent-browser screenshots",
      "\n".join([
          "A token page shows the pair, the creator handle, 5m / 1h / 6h / 24h change, a TradingView chart with social markers, 24h buy and sell pressure, price, FDV, 24h volume, liquidity, pool TVL and total supply, plus Share, comment, watchlist, boost, vote and Swap actions.",
          "",
          "| screenshot | token | pair | note |",
          "| --- | --- | --- | --- |",
          "| `screenshots/02-sentry-token-quotron.png` | QUOTRON, Quotrons | WETH | by @cruelhand, $12.93M FDV, 837 txns in 24h, the largest market on the list |",
          "| `screenshots/17-token-01-.png` | HOME, Hood Of Meme | WETH | by @cruelhandeth, no market data yet, the launch decoded in `_raw/blockscout/tx-0xee98627a...json` |",
          "| `screenshots/18-token-02-.png` | CHILL, Netflix and Chill | NFLX stock pair | by @cruelhand, $62.3K FDV, the highest-volume Sentry launch at 10,697 WETH |",
          "| `screenshots/19-token-03-.png` | SENTRY | WETH | by @sentrydev, $4.08M FDV |",
          "| `screenshots/20-token-04-.png` | ROBIN, Robin | WETH | by @sentrydev, verified badge |",
          "| `screenshots/21-token-05-.png` | WIF, RobinWifHat | WETH | by @cruelhand, $3.39M FDV |",
          "| `screenshots/22-token-06-.png` | BSENTRY, Baby Sentry | WETH with reflections | by @poipojopo, the launch decoded in `_raw/blockscout/tx-0x95d32514...json` |",
          "| `screenshots/23-token-07-.png` | BIGCHUNG, Big Chungus | WETH | by @nobody |",
          "| `screenshots/24-token-08-.png` | SARD, Sardines | WETH | by @sardines |",
          "| `screenshots/25-token-09-.png` | BOINK | WETH | by @boink, verified badge |",
          "| `screenshots/26-token-10-.png` | 6900, RHC6900 | WETH | by @lyon |",
          "| `screenshots/27-token-11-.png` | MIRA | WETH | by @nobody |",
          "| `screenshots/28-token-12-.png` | STEST, Sentry Test | WETH | by @sentrydev, one lifetime txn |",
          "| `screenshots/29-token-13-.png` | HOME, Hood Of Meme | WETH | second capture of the same page |",
          "| `screenshots/30-token-14-.png` | SILVER INU | SLV stock pair | by @ryoshiresearch, the launch decoded in `_raw/blockscout/tx-0x561a23fa...json` |",
          "| `screenshots/31-token-15-.png` | SILVER INU | SLV stock pair | a second Silver Inu deployment, `0x54a39956A2eA5669049Af0fa54eB6C1ffEB4845a` |",
          "",
          "The full 183-row token database behind these pages is captured verbatim in `_raw/api/supabase-sentry_tokens_robinhood.json`, and the Ink equivalent in `_raw/api/supabase-sentry_tokens_ink.json`.",
      ]))

b, w = jina(R + "/jina/sentry-desktop-social.md")
write("app-social-feed", "Social, the in-app feed",
      "https://www.sentry.trading/desktop/social", "Jina Reader, plus agent-browser after a wallet login",
      b + "\n\n## The same view after signing in with a wallet\n\n```text\n" + ab("read-authed-social.txt") + "\n```",
      note=("Logged out, the feed renders but posting, liking and messaging are gated behind `Sign in`.\n"
            "Signed in, the header carries the account handle derived from the wallet address, follower and post counts, an `Edit profile` action, and an encrypted 24-hour direct-message pane."),
      warnings=w, raw="_raw/jina/sentry-desktop-social.md, _raw/ab/read-authed-social.txt",
      shots=["03-social.png"])

write("app-profile-portfolio", "Profile and portfolio, signed in",
      "https://www.sentry.trading/desktop/portfolio", "agent-browser after a wallet login",
      "```text\n" + ab("read-authed-portfolio.txt") + "\n```",
      note=("Captured while signed in with the project's shared test wallet `0xTEST_WALLET_ADDRESS_REDACTED`.\n"
            "The page shows net worth, native ETH balance, token value, estimated PnL, a portfolio value chart, an allocation breakdown, holdings, and a GitHub-style activity heatmap of on-chain actions.\n"
            "Logged out, the same route renders the shell with `Loading...` placeholders (`_raw/jina/sentry-desktop-portfolio.md`)."),
      raw="_raw/ab/read-authed-portfolio.txt, _raw/jina/sentry-desktop-portfolio.md",
      shots=["04-portfolio.png", "43-profile-authed.png"])

write("app-creator-tools", "Tools, the creator tools page",
      "https://www.sentry.trading/desktop/tools", "agent-browser after a wallet login",
      "```text\n" + ab("read-authed-tools.txt") + "\n```\n\n## Logged out, through Jina\n\n" + jina(R + "/jina/sentry-desktop-tools.md")[0],
      note=("The only tool shipped so far is `Robinhood bundle wallets`, and it is allowlisted per account: a fresh account is told `Creator tools are not available for this account.`\n"
            "The guide's launch section says bundle-buy accounts may whitelist up to 50 wallets at launch, which is what this tool feeds."),
      raw="_raw/ab/read-authed-tools.txt, _raw/jina/sentry-desktop-tools.md",
      shots=["05-tools.png", "44-tools-authed.png"])

write("app-create-form", "Create a new coin, the launch form behind the login gate",
      "https://www.sentry.trading/desktop/create", "agent-browser with a headless EIP-6963 wallet, signed in",
      "\n".join([
          "```text",
          ab("read-create-authed.txt"),
          "```",
          "",
          "## With Launch Type set to Stock Base Pair",
          "",
          "```text",
          ab("read-create-stock.txt"),
          "```",
          "",
          "## Fields, in the order the form presents them",
          "",
          "| field | required | notes |",
          "| --- | --- | --- |",
          "| Coin Name | yes | placeholder `My Token`; the guide caps it at 32 characters |",
          "| Coin Symbol | yes | placeholder `TKN`; the guide caps it at 10 characters |",
          "| Coin Logo | yes | `Tap to upload logo`; submitting without one returns the client-side error `Token logo is required.` |",
          "| Launch Type | yes | `STANDARD` or `STOCK BASE PAIR`, a two-button toggle, Standard preselected |",
          "| Base Stock Pair | only for a stock launch | `Select a tokenized stock...`, with the copy `Your token launches paired with this stock. Holders earn the stock reflections on every trade.` |",
          "| Telegram Coin Emoji | no | `Create custom TG coin emoji - $20` |",
          "| Dev Buy (USD) | no | with a `Switch to ETH` toggle |",
          "| Social links | no | website, X and Telegram |",
          "| Creator fee recipient | no | `Optional - defaults to your wallet` |",
          "",
          "The submit button reads `DEPLOY ON ROBINHOOD` and a second, disabled control names the deploying wallet.",
          "",
          "## The tokenized stocks the form offers",
          "",
          "Nineteen stocks and ETFs are selectable in the picker (`screenshots/41-create-stock-selector.png`):",
          "",
          "Apple AAPL `0xaF3D...93f9`, AMD `0x8692...3fdC`, Amazon AMZN `0x12f1...bF54`, Alphabet Class A GOOGL `0x2e08...4FE3`, Intel INTC `0xc72b...9681`, Meta Platforms META `0xc0D6...2f35`, Microsoft MSFT `0xe932...2e74`, Micron MU `0xfF08...4afD`, Netflix NFLX `0xE044...91E8`, NVIDIA NVDA `0xd060...9EEC`, Oracle ORCL `0xb099...EE03`, Palantir PLTR `0x894E...4F2A`, Invesco QQQ `0xD5f3...de68`, iShares Silver Trust SLV `0x411e...D89f`, SNDK `0xB90A...6400`, SpaceX Class A SPCX `0x4a0E...5eEa`, SPDR S&P 500 SPY `0x117c...4C0C`, Tesla TSLA `0x322F...3b2d`, United States Oil Fund USO `0xa30F...D344`.",
          "",
          "The stock factory itself accepts far more: `getSupportedBaseTokens()` returned 88 addresses on 2026-09-02 (`_raw/rpc/derived-state-2026-09-02.txt`). The form is a curated subset of what the contract will take.",
          "",
          "## A defect worth recording",
          "",
          "With the network selector on Robinhood, the form's own header badge reads `INK` and the subtitle reads `Deploy your coin on Ink chain`, while the submit button correctly reads `Deploy on Robinhood` and the launch would go to the Robinhood factory.",
          "The chain label in the Create card does not follow the network selector.",
      ]),
      note=("This is the wallet-gated view. It was reached with the tier 0 headless EIP-6963 provider from the `headless-wallet` skill, which announces a wallet, forwards reads to the chain, parks the SIWE challenge for an out-of-page signer, and records and rejects any `eth_sendTransaction`.\n"
            "The SIWE challenge Sentry issues is bound to `Chain ID: 4663`, carries a single-use nonce and expires five minutes after issue.\n"
            "No transaction was ever broadcast, and the deploy attempt captured here stopped at the client-side logo validation."),
      raw="_raw/ab/read-create-authed.txt, _raw/ab/read-create-stock.txt, _raw/tools/hw-observer.js",
      shots=["10-create.png", "38-create-form.png", "39-create-form-stock-pair.png",
             "40-create-form-lower.png", "41-create-stock-selector.png", "42-create-deploy-attempt.png"])

write("app-login-gate", "The login gate: account, X, or wallet",
      "https://www.sentry.trading/desktop/tokens (Login)", "agent-browser",
      "\n".join([
          "Logged out, every authenticated route (`/desktop/create`, `/desktop/portfolio`, `/desktop/tools`, `/desktop/leaderboard`, `/desktop/referrals`, `/desktop/settings`, and the `/mobile/*` equivalents) client-side redirects to `/desktop/tokens`.",
          "",
          "Pressing `Login` opens a full-screen landing panel (`screenshots/34-login-modal.png`) reading `Find Trade Launch the next $DOGE $SHIB $PEPE $BONK $SPX $WIF $FARTCOIN $FLOKI $MOG $POPCAT`, with `LOGIN`, `Explore`, and links to Terms and Privacy.",
          "",
          "`LOGIN` opens the picker (`screenshots/35-login-picker.png`) with exactly three routes in:",
          "",
          "- **Sentry Account** - username plus password. The form (`screenshots/36-login-account-form.png`) is Username, Password, a `Create a new Sentry Account` checkbox and a `LOGIN` button. The guide says usernames are 3 to 32 characters of letters, numbers and underscores, passwords at least 8 characters, hashed with bcrypt cost 10, and sessions last 24 hours.",
          "- **Continue with X** - OAuth. X-created accounts start with no password.",
          "- **Connect wallet** - `MetaMask, Rabby, Phantom, WalletConnect`. Choosing it enumerates injected wallets over EIP-6963 and shows a `WalletConnect` entry alongside them.",
          "",
          "## What the wallet route actually asks for",
          "",
          "The wallet route issues a SIWE `personal_sign` challenge. Decoded from the parked request:",
          "",
          "```text",
          "www.sentry.trading wants you to sign in with your Ethereum account:",
          "0xTEST_WALLET_ADDRESS_REDACTED",
          "",
          "Sign in to Sentry. This does not cost gas and does not give Sentry permission to move your funds.",
          "",
          "URI: https://www.sentry.trading",
          "Version: 1",
          "Chain ID: 4663",
          "Nonce: 6a70db81ff1f603686655a39d4ab0fc9",
          "Issued At: 2026-09-02T20:21:15.529Z",
          "Expiration Time: 2026-09-02T20:26:15.529Z",
          "```",
          "",
          "The nonce is server-issued and single-use and the window is five minutes, so a captured signature cannot be replayed.",
          "There is no balance precheck on the login path: the shared test wallet, holding 0.001 ETH on chain 4663, signed in and reached the Create form without any funding prompt.",
          "",
          "Once signed in, the top nav gains `Create`, `Profile`, `Tools`, a trade-history clock, a screenshot camera and a Settings gear.",
      ]),
      note="Captured with the tier 0 observer provider described in `pages/07-app-create-form.md`. The private key never entered the page: the challenge was parked on `window.__HW.pending`, signed by `_raw/tools/sign-siwe.py` in a separate process, and only the signature was handed back.",
      shots=["13-login-modal.png", "34-login-modal.png", "35-login-picker.png", "36-login-account-form.png", "37-login-modal.png"])

write("app-settings", "Settings and the referral program",
      "https://www.sentry.trading/desktop/tokens (Settings gear)", "agent-browser after a wallet login",
      "\n".join([
          "Settings is a modal, not a route: `/desktop/settings` redirects to Discover in both the logged-out and logged-in states.",
          "",
          "```text",
          ab("read-authed-settings.txt"),
          "```",
          "",
          "## Referral Program panel, verbatim",
          "",
          "> Generate your referral code and invite friends. Anyone who signs up with your code - or trades through your buy links - earns you 1% of every trade they make, paid in ETH to your Sentry wallet on every swap. One code per account, yours forever.",
          "",
          "> Leave blank for a random code.",
          "",
          "> Have a referral code? Enter it once and that referrer earns a share of the platform fee on your swaps. Your own swap costs never change.",
          "",
          "The subgraph's `routerStats_collection` shows how small this is in practice: 0.00213 WETH of referral payments against 2.98 WETH of router fees, all time (`_raw/api/goldsky-sentry-robinhood-protocol.json`).",
      ]),
      raw="_raw/ab/read-authed-settings.txt",
      shots=["45-settings-authed.png", "46-settings-referrals.png"])

write("app-network-switcher", "The chain selector",
      "https://www.sentry.trading/desktop/tokens (Network button)", "agent-browser",
      "\n".join([
          "The header carries a `Network: Robinhood. Change network` button that opens a two-entry modal:",
          "",
          "| entry | chain id |",
          "| --- | --- |",
          "| Ink | 57073 |",
          "| Robinhood (selected) | 4663 |",
          "",
          "The selector switches the entire app, including the token list, the create form's target factory and the swap venue set.",
          "The same EVM address is used on both chains.",
          "",
          "`screenshots/16-network-switcher.png` from the earlier session is mislabelled: it holds a second copy of the Filters modal, not the network switcher. `screenshots/33-network-switcher.png` is the real one.",
      ]),
      shots=["16-network-switcher.png", "33-network-switcher.png"])

write("app-domains-and-filters", "The Domains tab and the Filters modal",
      "https://www.sentry.trading/desktop/tokens (Domains, Filters)", "agent-browser",
      "\n".join([
          "## Domains",
          "",
          "The Discover header has three tabs: `TOKENS`, `DOMAINS`, `FILTERS`.",
          "",
          "The Domains tab reads:",
          "",
          "> REGISTER A .HOOD DOMAIN. Your onchain name on Robinhood - resolves everywhere in the app, sets your identity on the portfolio page.",
          "",
          "> DOMAIN MARKETPLACE. Premier .hood names up for auction. First bid starts a 7-day clock; raises beat the leader by 5%+, and late bids extend the deadline. Bids are escrowed and refunded automatically when outbid.",
          "",
          "The auction table columns are DOMAIN, STATUS, BID, BIDS, ENDS, with `000.hood` listed `OPEN FOR BIDS` at 0.2500 ETH, 0 bids, `Awaiting first bid`.",
          "The registry the modal writes to is ZNS Connect, `0x8f95ed212F37cDc19f5C0716c24966D9019939Ee` on Robinhood Chain.",
          "",
          "## Filters",
          "",
          "The Filters modal offers `PAIRS: WETH | STOCKS` and `SORT BY: VOLUME | MARKET CAP | 24H % | NEWEST`.",
          "The WETH and STOCKS split is the same split as the two live launch factories.",
      ]),
      shots=["14-domains-tab.png", "15-filters.png"])

b, w = jina(R + "/jina/sentry-swap.md")
write("app-swap-public", "The public swap page, no account needed",
      "https://www.sentry.trading/swap", "Jina Reader and agent-browser",
      b, note=("`/swap` is the guest surface: a featured token strip, a Swap and Lock tab pair, a You Pay and You Receive form defaulting to ETH, and a `CONNECT WALLET` button.\n"
               "The guide puts the same 1% input fee on guest swaps as on in-app swaps, and says a `?ref=` code redirects that 1% to the referrer."),
      warnings=w, raw="_raw/jina/sentry-swap.md", shots=["08-swap.png"])

b, w = jina(R + "/jina/sentry-lock.md")
write("app-lock-public", "The public token locker page",
      "https://www.sentry.trading/lock", "Jina Reader and agent-browser",
      b, note=("`/lock` is the second tab of the guest surface. The form is You Lock, a token selector, an `Until` date with `1w / 1m / 3m / 6m / 1y / Custom` presets, and `CONNECT WALLET`.\n"
               "The page names its own contract in the footer: `SentryTokenLocker 0xbd0E7a24...5ea81D - verified on Blockscout - no owner, no fees, no backdoor`.\n"
               "`lockCount()` on that contract returned 509 on 2026-09-02 (`_raw/rpc/derived-sentry-token-2026-09-02.txt`)."),
      warnings=w, raw="_raw/jina/sentry-lock.md", shots=["09-lock.png"])

parts = []
for label, f in [("/mobile/tokens", "sentry-mobile-tokens.md"), ("/mobile/social", "sentry-mobile-social.md"),
                 ("/mobile/portfolio", "sentry-mobile-portfolio.md"), ("/mobile/tools", "sentry-mobile-tools.md"),
                 ("/mobile/create", "sentry-mobile-create.md"), ("/mobile/guide", "sentry-mobile-guide.md")]:
    bb, ww = jina(R + "/jina/" + f)
    parts.append("## %s\n\n%s" % (label, bb))
write("app-mobile-routes", "The /mobile route family",
      "https://www.sentry.trading/mobile/{tokens,social,portfolio,tools,create,guide}", "Jina Reader",
      "\n\n".join(parts),
      note=("Sentry ships two layouts behind the same app: `/desktop/*` with a fixed top nav and a right-side wallet rail, and `/mobile/*` with a bottom tab bar and a single column.\n"
            "Every `/mobile` route served the same Discover payload to a headless fetch, because the layout is chosen client-side from the viewport and the routes are otherwise identical.\n"
            "The mobile screenshots below were taken with a phone-sized viewport and do show the real mobile chrome."),
      raw="_raw/jina/sentry-mobile-*.md", shots=["11-mobile-tokens.png", "12-mobile-guide.png"])

routes = []
for label, f in [("/desktop/tokens", "sentry-desktop-tokens.md"), ("/desktop/create", "sentry-desktop-create.md"),
                 ("/desktop/launch", "sentry-desktop-launch.md"), ("/desktop/leaderboard", "sentry-desktop-leaderboard.md"),
                 ("/desktop/referrals", "sentry-desktop-referrals.md"), ("/desktop/settings", "sentry-desktop-settings.md")]:
    bb, ww = jina(R + "/jina/" + f)
    routes.append("## %s\n\nCapture size %d bytes.\n\n%s" % (label, os.path.getsize(R + "/jina/" + f), bb if bb else "_Empty. The route returned the app shell with no rendered content._"))
write("app-route-map", "Route map: what each path actually serves",
      "https://www.sentry.trading/desktop/*", "Jina Reader and agent-browser",
      "\n\n".join(routes),
      note=("\n".join([
          "The app has fewer real routes than its paths suggest. Confirmed on 2026-09-02, logged out and then logged in:",
          "",
          "| path | logged out | logged in |",
          "| --- | --- | --- |",
          "| `/` and `/desktop/tokens` | Discover list | Discover list |",
          "| `/desktop/social` | feed, posting gated | feed with the account header |",
          "| `/desktop/create` | redirects to `/desktop/tokens` | the launch form |",
          "| `/desktop/portfolio` | shell with placeholders | full portfolio |",
          "| `/desktop/tools` | shell | creator tools, allowlisted per account |",
          "| `/desktop/guide` | full guide | full guide |",
          "| `/desktop/leaderboard` | redirects to `/desktop/tokens` | redirects to `/desktop/tokens` |",
          "| `/desktop/referrals` | redirects to `/desktop/tokens` | redirects to `/desktop/tokens`; the panel lives inside the Settings modal |",
          "| `/desktop/settings` | redirects to `/desktop/tokens` | redirects to `/desktop/tokens`; Settings is the header gear, a modal |",
          "| `/desktop/launch` | redirects to `/desktop/tokens` | not a route |",
          "| `/swap`, `/lock` | standalone guest surfaces | same |",
          "",
          "A headless fetch of a redirecting route returns whatever Discover had rendered by the time the reader gave up, which is why several of the captures below are copies of the token list rather than the page their URL names.",
      ])),
      raw="_raw/jina/sentry-desktop-*.md, _raw/ab/read-desktop-*.txt")

# ---------------------------------------------------------- the guide, split
src = open(R + "/jina/sentry-desktop-guide.md", encoding="utf-8", errors="replace").read()
i = src.find("Markdown Content:")
gbody = src[i + len("Markdown Content:"):]
heads = [(m.start(), m.group(1).strip(), m.group(2))
         for m in re.finditer(r"^## (.+?)\[\]\((https://www\.sentry\.trading/desktop/guide#[a-z0-9-]+) \"Copy link to this section\"\)\s*$",
                              gbody, re.M)]
shot_for = {"#telegram-bots": ["07-guide-telegram-bots.png"], "#welcome": ["06-guide.png"]}
for idx, (pos, title, anchor) in enumerate(heads):
    end = heads[idx + 1][0] if idx + 1 < len(heads) else len(gbody)
    body = gbody[pos:end].strip()
    slug = "guide-" + re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:44]
    frag = "#" + anchor.split("#")[1]
    write(slug, "Guide, %s" % title, anchor, "Jina Reader", body,
          raw="_raw/jina/sentry-desktop-guide.md",
          shots=shot_for.get(frag))

write("guide-machine-readable-source", "sentry-guide.md, the machine-readable guide",
      "https://www.sentry.trading/sentry-guide.md", "curl",
      open(R + "/sentry-guide.md", encoding="utf-8", errors="replace").read().strip(),
      note=("Sentry publishes its whole guide as one markdown file, dated `Last updated: August 27, 2026`, explicitly written to be handed to an AI assistant.\n"
            "It is the same material as the rendered guide pages above, minus the Ecosystem Stats, Brand Kit, Team, V2 Roadmap and Troubleshooting sections, and plus a fuller Ink xStocks integrator reference.\n"
            "Every economic number in this archive's README was checked against the chain rather than taken from this file; where the two disagree the README says so."),
      raw="_raw/sentry-guide.md")

# ------------------------------------------------------------------ quotrons
qpages = [("quotrons-root", "Quotrons, the terminal exchange", "https://www.quotrons.cash/", "quotrons-root.md"),
          ("quotrons-about", "Quotrons, About and Legal", "https://www.quotrons.cash/about", "quotrons-about.md"),
          ("quotrons-docs", "Quotrons, Docs", "https://www.quotrons.cash/docs", "quotrons-docs.md"),
          ("quotrons-desk", "Quotrons, My Desk", "https://www.quotrons.cash/desk", "quotrons-desk.md"),
          ("quotrons-exchange", "Quotrons, Exchange", "https://www.quotrons.cash/exchange", "quotrons-exchange.md"),
          ("quotrons-xstocks", "Quotrons, xStocks Pools", "https://www.quotrons.cash/xstocks", "quotrons-xstocks.md"),
          ("quotrons-market", "Quotrons, Social Market", "https://www.quotrons.cash/market", "quotrons-market.md"),
          ("quotrons-rewards", "Quotrons, Reward Stocks", "https://www.quotrons.cash/rewards", "quotrons-rewards.md"),
          ("quotrons-otc", "Quotrons, OTC Desk", "https://www.quotrons.cash/otc", "quotrons-otc.md"),
          ("quotrons-relics", "Quotrons, Relics", "https://www.quotrons.cash/relics", "quotrons-relics.md"),
          ("quotrons-v1", "Quotrons, V1 Migration Record", "https://www.quotrons.cash/v1", "quotrons-v1.md")]
for slug, title, url, f in qpages:
    bb, ww = jina(R + "/jina/" + f)
    note = ""
    if slug == "quotrons-root":
        note = ("Quotrons is the sibling product to Sentry: both are `a product of Mavrk, Inc.`, and the EOA that deployed every Quotron contract, `0x7171E64E979265aeD6588577D1c6b60A701d7866`, is the address SENTRY's own token contract returns from `founder()`.\n"
                "QUOTRON is also the largest market on Sentry's Discover list.\n"
                "It is not a launchpad and does not launch other people's tokens, so it is captured here as context, not as a launch route.")
    write(slug, title, url, "Jina Reader", bb, note=note, warnings=ww, raw="_raw/jina/" + f)

# ------------------------------------------------- linktree and external refs
ext = [("linktree-cruelhand", "linktr.ee/cruelhand, the founder's link hub", "https://linktr.ee/cruelhand", "linktree-cruelhand.md",
        "The eight links the page itself carries, before Linktree's own discovery feed, are: Sentry sign-up with the CRUELHAND referral code, X @cruelhandeth, Telegram @deployerone, the `Sergio's Field Notes` Telegram channel, LinkedIn, Ink Foundation, gm.ink, sentry.trading, and mavrk.markets.\nEvery one of those targets is captured as its own page or social file below."),
       ("mavrk-markets", "Mavrk, the company behind Sentry and Quotrons", "https://mavrk.markets/", "mavrk-markets.md",
        "Mavrk, Inc. is named in the footer of both sentry.trading and quotrons.cash, and Quotrons' About page records it as a Delaware corporation incorporated 2026-06-12, contact info@quotrons.cash."),
       ("linkedin-sergio-luna", "LinkedIn, Sergio Alessandro Luna", "https://www.linkedin.com/in/sergioalessandroluna/", "linkedin-sergio.md",
        "The guide's Team section names Sergio Luna as Founder and CEO of Sentry and of Mavrk, Inc., reachable at team@sentry.trading."),
       ("robinhood-chain-docs", "Robinhood Chain documentation", "https://docs.robinhood.com/chain/", "robinhood-chain-docs.md", ""),
       ("zns-connect", "ZNS Connect, the .ink and .hood name registry", "https://zns.bio/", "zns-bio.md",
        "The `.hood` registry contract on Robinhood Chain is `0x8f95ed212F37cDc19f5C0716c24966D9019939Ee`, which Blockscout reports as a contract but unverified."),
       ("relay-link", "Relay, the bridge behind Sentry's Bridge tile", "https://relay.link/", "relay-link.md", ""),
       ("ink-foundation", "Ink Foundation", "http://inkfnd.com/", "inkfnd.md", ""),
       ("gm-ink", "gm.ink", "https://gm.ink/", "gm-ink.md", ""),
       ("github-mavrkofficial", "GitHub, mavrkofficial", "https://github.com/mavrkofficial", "github-mavrkofficial.md",
        "Mavrk publishes no contract source on GitHub. The only public repository is the Quotrons brand kit; Sentry's contracts are read from Blockscout's verified sources instead, which are complete."),
       ("github-quotrons-brand-kit", "GitHub, mavrkofficial/quotrons-brand-kit", "https://github.com/mavrkofficial/quotrons-brand-kit", "github-quotrons-brand-kit.md", ""),
       ("opensea-quotrons404", "OpenSea, the Quotrons404 collection", "https://opensea.io/collection/Quotrons404", "opensea-quotrons404.md", "")]
for slug, title, url, f, note in ext:
    bb, ww = jina(R + "/jina/" + f)
    write(slug, title, url, "Jina Reader", bb, note=note, warnings=ww, raw="_raw/jina/" + f)

json.dump(manifest, open(R + "/pages-manifest.json", "w"), indent=1)
print(len(manifest), "pages written")
