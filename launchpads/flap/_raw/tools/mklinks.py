#!/usr/bin/env python3
"""Build LINKS.md for the Flap archive.

Sources:
  _raw/docs/*.md          every markdown link on every captured docs page
  _raw/ab/*.txt           agent-browser reads of the app
  _raw/socials/*.md       Jina and Bright Data social captures
  _raw/js/*.js            hosts referenced by the app bundle
Plus a hand-authored block for app routes visited with agent-browser.
"""
import re, os, glob, json, urllib.parse

BASE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
os.chdir(BASE)

# docs page url -> pages/NN file
page_of = {}
for line in open("_raw/docs/pages-index.tsv"):
    f, url = line.split("\t")[:2]
    page_of[url.rstrip("/")] = "pages/" + f
    page_of[url.rstrip("/") + ".md"] = "pages/" + f

# docs raw file -> its page and its own url
raw_of = {}
for line in open("_raw/docs/pages-index.tsv"):
    f, url, title = line.split("\t")[:3]
    slug = url.replace("https://docs.flap.sh/flap", "").strip("/")
    raw = "_raw/docs/" + (slug.replace("/", "__") if slug else "readme") + ".md"
    raw_of[raw] = (url, "pages/" + f, title)


EXTRA = {
 "https://docs.flap.sh/flap/llms.txt": "_raw/docs.flap.sh_llms.txt",
 "https://docs.flap.sh/flap/llms-full.txt": "_raw/docs.flap.sh_llms-full.txt",
 "https://flap.sh": "pages/01-board-robinhood.md",
 "https://flap.sh/": "pages/01-board-robinhood.md",
 "https://twitter.com/flapdotsh": "socials/01-x-flapdotsh-profile.md",
 "https://x.com/flapdotsh": "socials/01-x-flapdotsh-profile.md",
 "https://t.me/FlapOfficial": "socials/03-telegram-flapofficial.md",
 "https://discord.gg/flapdotsh": "socials/04-discord-and-farcaster.md",
 "https://warpcast.com/flap": "socials/04-discord-and-farcaster.md",
 "https://skynet.certik.com/projects/flap": "socials/05-certik-skynet.md",
}

def classify(href):
    h = href.lower()
    if h.startswith("/flap") or "docs.flap.sh" in h:
        return "docs page"
    if "github.com" in h:
        return "repo"
    if h.endswith(".pdf") or "/files/" in h:
        return "file"
    if any(s in h for s in ("x.com", "twitter.com", "t.me", "discord", "warpcast", "linkedin", "coingecko")):
        return "social"
    if "skynet.certik.com" in h:
        return "audit"
    if "scan.com" in h or "blockscout" in h or "dexscreener" in h or "defined.fi" in h:
        return "explorer"
    if "flap.sh" in h:
        return "app"
    return "external"

def captured_as(href, typ):
    if href.rstrip("/") in EXTRA:
        return EXTRA[href.rstrip("/")]
    if href in EXTRA:
        return EXTRA[href]
    u = href
    if u.startswith("/flap"):
        u = "https://docs.flap.sh" + u
    u = u.rstrip("/")
    if u.endswith(".md"):
        u = u[:-3]
    if u in page_of:
        return page_of[u]
    if typ == "repo":
        name = u.rstrip("/").split("/")[-1]
        for d in ("flap-skills", "flap-vault-component-template", "FlapVaultExample"):
            if d.lower() in u.lower():
                return f"_raw/github/{d}/"
        return "not captured, link recorded only"
    if "/files/" in u:
        return "_raw/docs/files/"
    return "not captured, link recorded only"

rows = []
seen = set()
pat = re.compile(r"\[([^\]]*)\]\(([^)\s]+)\)|<(https?://[^>\s]+)>")
for raw in sorted(raw_of):
    if not os.path.exists(raw):
        continue
    src_url, src_page, title = raw_of[raw]
    text = open(raw, encoding="utf8", errors="replace").read()
    for m in pat.finditer(text):
        label = (m.group(1) or "").strip() or "(bare url)"
        href = (m.group(2) or m.group(3) or "").strip()
        if not href or href.startswith("#"):
            continue
        typ = classify(href)
        key = (src_page, href)
        if key in seen:
            continue
        seen.add(key)
        label = label.replace("|", "\\|")[:80]
        rows.append((src_page, label, href, typ, captured_as(href, typ)))

APP = [
 ("pages/01-board-robinhood.md", "Flap home / board", "https://flap.sh/robinhood/board", "app", "pages/01-board-robinhood.md"),
 ("pages/01-board-robinhood.md", "STORE", "https://flap.sh/robinhood/CAstore", "app", "pages/72-ca-store-vault-store.md"),
 ("pages/01-board-robinhood.md", "DOCS", "https://docs.flap.sh/flap", "docs page", "pages/11-docs-readme.md"),
 ("pages/01-board-robinhood.md", "Create Token, non-tax", "https://flap.sh/create?lang=en", "app", "pages/09-create-non-tax-token.md"),
 ("pages/01-board-robinhood.md", "Create Token, tax", "https://flap.sh/launch?chain=robinhood&lang=en", "app", "pages/10-create-tax-token.md"),
 ("pages/01-board-robinhood.md", "STOCKS tab", "https://flap.sh/robinhood/board (STOCKS)", "app", "pages/02-board-robinhood-stocks.md"),
 ("pages/01-board-robinhood.md", "BONDING tab", "https://flap.sh/robinhood/board (BONDING)", "app", "pages/03-board-robinhood-bonding.md"),
 ("pages/01-board-robinhood.md", "CAT tab", "https://flap.sh/robinhood/board (CAT)", "app", "pages/04-board-robinhood-cat.md"),
 ("pages/01-board-robinhood.md", "LOW RISK tab", "https://flap.sh/robinhood/board (LOW RISK)", "app", "pages/05-board-robinhood-low-risk.md"),
 ("pages/01-board-robinhood.md", "TRENDING tab", "https://flap.sh/robinhood/board (TRENDING)", "app", "pages/06-board-robinhood-trending.md"),
 ("pages/01-board-robinhood.md", "token detail, $moon", "https://flap.sh/robinhood/0x862cdccb67c8a22fdb247d09a08b1dad09447777", "app", "pages/07-token-moon.md"),
 ("pages/03-board-robinhood-bonding.md", "token detail, $UBER on the curve", "https://flap.sh/robinhood/0x9413c960e0da92b7343086392b4c852019e57777?lang=en", "app", "pages/73-token-uber-bonding-curve.md"),
 ("pages/73-token-uber-bonding-curve.md", "TAX INFO", "https://flap.sh/robinhood/0x9413c960e0da92b7343086392b4c852019e57777/taxinfo?lang=en", "app", "pages/74-token-uber-tax-info.md"),
 ("pages/09-create-non-tax-token.md", "Reserve Your Token CA", "https://flap.sh/prelaunch", "app", "pages/71-prelaunch-reserve-ca.md"),
 ("pages/10-create-tax-token.md", "Enable Vault, Browse, IndexVault", "https://flap.sh/launch?chain=robinhood&lang=en (vault picker)", "app", "pages/70-create-tax-token-indexvault.md"),
 ("pages/01-board-robinhood.md", "Community, X", "https://x.com/flapdotsh", "social", "socials/01-x-flapdotsh-profile.md"),
 ("pages/01-board-robinhood.md", "Community, Telegram", "https://t.me/FlapOfficial", "social", "socials/03-telegram-flapofficial.md"),
 ("pages/01-board-robinhood.md", "More, AI Oracle", "https://docs.flap.sh/flap/developers/preview/flap-ai-oracle", "docs page", "pages/58-docs-developers-preview-flap-ai-oracle.md"),
 ("pages/01-board-robinhood.md", "More, Terms and Conditions", "https://flap.sh/terms", "app", "not captured, link recorded only"),
 ("pages/01-board-robinhood.md", "More, Contact Us", "https://flap.sh/contact", "app", "not captured, link recorded only"),
 ("pages/01-board-robinhood.md", "chart embed", "https://www.defined.fi/robinhood/<pair>/embed", "explorer", "_raw/network-token-moon.json"),
 ("pages/01-board-robinhood.md", "backend API", "https://batman.taxed.fun/v3/board", "external", "_raw/api/api-v3_board_*.json"),
 ("pages/07-token-moon.md", "backend API, one coin", "https://batman.taxed.fun/v3/coin/<address>", "external", "_raw/api/api-v3_coin_moon.json"),
 ("pages/01-board-robinhood.md", "backend API, banners", "https://batman.taxed.fun/v3/banners", "external", "_raw/api/api-v3_banners.json"),
 ("pages/01-board-robinhood.md", "live price websocket", "wss://flap.rcto.fun/latest", "external", "not captured, link recorded only"),
 ("pages/01-board-robinhood.md", "dividend backend", "https://batman-dividend.taxed.fun", "external", "not captured, link recorded only"),
 ("pages/01-board-robinhood.md", "chain RPC used by the app", "https://rpc.mainnet.chain.robinhood.com/", "external", "_raw/network-token-moon.json"),
 ("pages/01-board-robinhood.md", "explorer used by the app", "https://robinhoodchain.blockscout.com", "explorer", "_raw/blockscout/"),
 ("socials/01-x-flapdotsh-profile.md", "backer", "https://x.com/yzilabs", "social", "not captured, link recorded only"),
 ("socials/05-certik-skynet.md", "CertiK Skynet", "https://skynet.certik.com/projects/flap", "audit", "socials/05-certik-skynet.md"),
 ("socials/05-certik-skynet.md", "RootData", "https://www.rootdata.com/projects/detail/Flap?k=MTMxOTg=", "external", "not captured, link recorded only"),
 ("socials/05-certik-skynet.md", "CoinGecko", "https://www.coingecko.com/en/coins/flap", "external", "not captured, link recorded only"),
 ("socials/05-certik-skynet.md", "LinkedIn", "https://www.linkedin.com/company/flap-sh/", "social", "not captured, link recorded only"),
 ("pages/66-docs-audit-reports.md", "BlockSec, Flap Protocol V5", "https://docs.flap.sh/files/CWIFdhUbnZ19pU4znsUe", "file", "_raw/docs/files/blocksec_flap_protocol_v5_v1.0-signed.pdf"),
 ("pages/66-docs-audit-reports.md", "BlockSec, Flap Tax Token", "https://docs.flap.sh/files/P8NIjZbfzFTXxOTvSgGo", "file", "_raw/docs/files/blocksec_flap_tax_token_v1.0-signed.pdf"),
 ("pages/67-docs-media-kit.md", "Media Kit", "https://docs.flap.sh/files/media-kit", "file", "_raw/docs/files/Media Kit.zip"),
]
for r in APP:
    if (r[0], r[2]) in seen:
        continue
    seen.add((r[0], r[2]))
    rows.append(r)

rows.sort(key=lambda r: (r[0], r[3], r[2]))
out = ["# Flap link inventory\n",
 "Every link discovered on any captured Flap page, plus the app routes and backend endpoints the archive visited.",
 "Captured 2026-09-02 and 2026-09-03.\n",
 f"{len(rows)} rows.\n",
 "`captured as` points at the file in this directory that holds the target, or says the link was recorded without being fetched.",
 "Docs links appear once per source page, so the same target can appear on several rows.\n",
 "| found on | link text | href | type | captured as |",
 "| --- | --- | --- | --- | --- |"]
for src, label, href, typ, cap in rows:
    out.append(f"| `{src}` | {label} | `{href}` | {typ} | `{cap}` |")
open("LINKS.md", "w").write("\n".join(out) + "\n")
print("rows", len(rows))
