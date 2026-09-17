import os, re, json, glob
BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/sentry"
R, S = BASE + "/_raw", BASE + "/socials"
os.makedirs(S, exist_ok=True)
for f in glob.glob(S + "/*.md"):
    os.remove(f)
n = 0


def jina(path):
    s = open(path, encoding="utf-8", errors="replace").read()
    i = s.find("Markdown Content:")
    return (s[i + len("Markdown Content:"):].strip() if i >= 0 else s.strip())


def write(slug, title, url, method, body, note="", raw=None):
    global n
    n += 1
    L = ["# Sentry - %s" % title, "", "> Source: %s" % url, "> Retrieved: 2026-09-02 (%s)" % method]
    if raw:
        L.append("> Raw capture: `%s`" % raw)
    L += ["", "---", ""]
    if note:
        L += [note, ""]
    L.append(body)
    open("%s/%02d-%s.md" % (S, n, slug), "w").write("\n".join(L).rstrip() + "\n")
    print("%02d-%s.md" % (n, slug))


write("x-sentrylauncher", "X, @sentrylauncher, the official product account",
      "https://x.com/sentrylauncher", "Jina Reader, plus a Bright Data render",
      jina(R + "/jina/x-sentrylauncher.md")
      + "\n\n## Bright Data render of the same profile\n\n```text\n"
      + open(R + "/bdata/x-profile-sentrylauncher.md", encoding="utf-8", errors="replace").read().strip()[:6000]
      + "\n```",
      note=("193 posts, 2,804 followers, 40 following, joined January 2026, bio `Token launch and trading product. Official account for sentry.trading`.\n"
            "The pinned and top posts state the product's core claims in the team's own words: no bonding curve, live on Uniswap the moment Deploy is pressed, LP permanently locked in the factory, and trading across several Robinhood Chain DEX venues including PancakeSwap V3.\n"
            "The X syndication timeline endpoint returns `entries: []` for this handle, so no machine-readable post feed was obtainable; `bdata pipelines x_posts` rejects profile URLs and accepts only individual status URLs."),
      raw="_raw/jina/x-sentrylauncher.md, _raw/bdata/x-profile-sentrylauncher.md, _raw/x/syndication-sentrylauncher.html")

write("x-cruelhandeth", "X, @cruelhandeth, Sergio Luna, founder",
      "https://x.com/cruelhandeth", "Jina Reader, Bright Data render, and one post through the x_posts pipeline",
      jina(R + "/jina/x-cruelhandeth.md")
      + "\n\n## One post pulled through the Bright Data x_posts pipeline\n\n```json\n"
      + open(R + "/bdata/x_posts-cruelhandeth-status-2094906164282528080.json", encoding="utf-8", errors="replace").read().strip()
      + "\n```",
      note=("The founder's personal account. The guide's Team section names Sergio Luna as Founder and CEO of Sentry and of Mavrk, Inc.\n"
            "This handle appears as the creator of several of the largest Sentry launches, including QUOTRON, CHILL and WIF, under the display names `@cruelhand` and `@cruelhandeth` inside the app."),
      raw="_raw/jina/x-cruelhandeth.md, _raw/bdata/x-profile-cruelhandeth.md, _raw/bdata/x_posts-cruelhandeth-status-2094906164282528080.json")

# quotrons syndication timeline
tl = []
try:
    s = open(R + "/x/syndication-quotrons404.html", encoding="utf-8", errors="replace").read()
    m = re.search(r'<script id="__NEXT_DATA__" type="application/json">(.*?)</script>', s, re.S)
    d = json.loads(m.group(1))
    for e in d["props"]["pageProps"]["timeline"]["entries"]:
        c = e.get("content", {}).get("tweet", {})
        if not c:
            continue
        tl.append("| %s | %s |" % (c.get("created_at", ""), (c.get("full_text") or "").replace("\n", " ").replace("|", "/").strip()))
except Exception as ex:
    tl = ["| | capture failed: %s |" % ex]

write("x-quotrons404", "X, @quotrons404, the sibling product account",
      "https://x.com/quotrons404", "Jina Reader plus the X syndication timeline endpoint",
      jina(R + "/jina/x-quotrons404.md")
      + "\n\n## Latest timeline page, from the syndication endpoint\n\n"
      + "| posted | text |\n| --- | --- |\n" + "\n".join(tl),
      note=("`https://syndication.twitter.com/srv/timeline-profile/screen-name/quotrons404` returned a full 20-post timeline inside `__NEXT_DATA__` with no key, where the same endpoint returned nothing for @sentrylauncher and @cruelhandeth.\n"
            "The feed is an automated bot posting Quotron terminal sales, hardwiring events and tokenized-stock reward claims, which is the clearest available picture of Quotrons' live activity."),
      raw="_raw/jina/x-quotrons404.md, _raw/bdata/x-profile-quotrons404.md, _raw/x/syndication-quotrons404.html")

write("x-inkfndhq", "X, @inkfndhq, the Ink Foundation",
      "https://x.com/inkfndhq", "Jina Reader", jina(R + "/jina/x-inkfndhq.md"),
      note="Ink is Sentry's second chain (chain id 57073) and is linked from the founder's linktree. Captured for context on the non-Robinhood half of the product.",
      raw="_raw/jina/x-inkfndhq.md")

tg = [("telegram-sentrylauncher", "Telegram, @sentrylauncher, the community channel", "https://t.me/sentrylauncher", "tg-sentrylauncher.md",
       "Linked from every Sentry token row and from the app footer as `Join Sentry on Telegram`."),
      ("telegram-sentrybuybot", "Telegram, @SentryBuyBot, buy alerts", "https://t.me/SentryBuyBot", "tg-sentrybuybot.md",
       "One of the two official bots. Added to a project's group, it posts an alert on every buy with amount, price, market cap, buyer and one-tap chart and Buy links, and it sells paid featured slots. It runs with Telegram group privacy enabled, so it sees only commands, replies and mentions."),
      ("telegram-sentrytgbot", "Telegram, @SentryTG_Bot, the trading bot", "https://t.me/SentryTG_Bot", "tg-sentrytgbot.md",
       "The second official bot: trade, launch and broadcast from a chat, in private chats only, on the same engine, routes and fees as the app. It also sells the $20 animated Coin Emoji."),
      ("telegram-cruelhand", "Telegram, Sergio's Field Notes", "https://t.me/cruelhand", "tg-cruelhand.md",
       "The founder's own channel, linked from linktr.ee/cruelhand."),
      ("telegram-deployerone", "Telegram, @deployerone, the founder's contact", "https://t.me/deployerone", "tg-deployerone.md",
       "Listed on the linktree as `Contact me on Telegram`. The Solana deployment feed at `_raw/api/web-token-deployments.json`, served by the same backend as the Sentry site, records tokens deployed from Telegram chats through a deployer bot, which is where this handle's name comes from.")]
for slug, title, url, f, note in tg:
    write(slug, title, url, "Jina Reader", jina(R + "/jina/" + f), note=note, raw="_raw/jina/" + f)

dl = json.load(open(R + "/api/defillama-protocol-sentry.json"))
write("defillama-sentry", "DefiLlama protocol record, slug `sentry`",
      "https://api.llama.fi/protocol/sentry", "curl",
      "\n".join([
          "| field | value |",
          "| --- | --- |",
          "| id | %s |" % dl.get("id"),
          "| name | %s |" % dl.get("name"),
          "| category | %s |" % dl.get("category"),
          "| chains | %s |" % ", ".join(dl.get("chains") or []),
          "| twitter | %s |" % dl.get("twitter"),
          "| audits | %s |" % dl.get("audits"),
          "| github | %s |" % dl.get("github"),
          "| listed at | %s (unix) |" % dl.get("listedAt"),
          "| current TVL, Robinhood Chain | $%s |" % round((dl.get("currentChainTvls") or {}).get("Robinhood Chain", 0), 2),
          "| current TVL, Ink | $%s |" % round((dl.get("currentChainTvls") or {}).get("Ink", 0), 2),
          "",
          "## Description, verbatim",
          "",
          "> " + (dl.get("description") or "").strip(),
          "",
          "## Methodology, verbatim",
          "",
          "> " + (dl.get("methodology") or "").strip(),
      ]),
      note=("DefiLlama's description is out of date in two ways that matter: it describes only the Uniswap V3 generation, and it quotes the creator split as 65/35.\n"
            "On chain on 2026-09-02 the Robinhood split is 70/30 (`creatorFeeBps() = 7000` on both live factories, on the legacy factory and on the LP vault), and the live generation is Uniswap v4 with per-swap settlement rather than V3 fee accrual.\n"
            "DefiLlama also records zero audits and no public GitHub, which matches what could be found independently."),
      raw="_raw/api/defillama-protocol-sentry.json")
