import os, re, json, glob
BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/sentry"
R = BASE + "/_raw"

# url -> capture path, from the generated pages and socials
cap = {}
for fn, title, url in json.load(open(R + "/pages-manifest.json")):
    for u in url.split(", "):
        cap[u.rstrip("/")] = "pages/" + fn
for f in sorted(glob.glob(BASE + "/socials/*.md")):
    for line in open(f):
        if line.startswith("> Source: "):
            cap[line[len("> Source: "):].strip().rstrip("/")] = "socials/" + os.path.basename(f)
            break

raw_map = {
    "https://robinhoodchain.blockscout.com": "_raw/blockscout/",
    "https://api.dexscreener.com": "_raw/dexscreener/",
    "https://esjrycmiokijtxnbfyox.supabase.co": "_raw/api/supabase-*.json",
    "https://sentry-pwa-backend-production.up.railway.app": "_raw/api/pwa-*.json",
    "https://web-production-7d3e.up.railway.app": "_raw/api/web-*.json",
    "https://api.goldsky.com": "_raw/api/goldsky-*.json",
    "https://api.llama.fi": "_raw/api/defillama-protocol-sentry.json",
    "https://www.dextools.io": "not captured, DEXTools blocks headless fetches",
    "https://www.sentry.trading/sentry-guide.md": "_raw/sentry-guide.md",
}

src_url = {}
for f in sorted(glob.glob(R + "/jina/*.md")):
    s = open(f, encoding="utf-8", errors="replace").read(600)
    m = re.search(r"^URL Source: (\S+)", s, re.M)
    if m:
        src_url[f] = m.group(1)


CHROME = re.compile(r"""
    ^https?://(pbs|abs|ton)\.twimg\.com
  | ^https?://avatars\.githubusercontent\.com
  | ^https?://[a-z0-9.-]*githubassets?\.com
  | ^https?://(help|support|business|about|developer|blog|docs)\.x\.com
  | ^https?://x\.com/(tos|privacy|i/jf/|settings|explore|home|login|signup|i/flow)
  | ^https?://(www\.)?linkedin\.com/(legal|help|company/linkedin|signup|uas|checkpoint|feed|jobs|learning|pulse|posts|in/[a-z0-9-]+\?)
  | ^https?://(www\.)?linktr\.ee/(?!cruelhand)
  | ^https?://github\.com/(features|pricing|about|security|login|signup|site|contact|customer-stories|enterprise|solutions|resources|sponsors|git-guides|collections|topics|trending|explore|marketplace|apps|orgs/community|github|readme|logos|premium-support|copilot|team|events|newsroom|blog|codespaces|issues|pulls|notifications|settings|search|join|orgs)
  | ^https?://(docs|opensource|resources|skills|education|partner|services|www)\.github\.com
  | ^https?://(opensea\.io/(rankings|stats|learn|blog|about|careers|privacy|terms|assets/[a-z]|collection/(?!Quotrons404))|support\.opensea\.io)
  | \.(png|jpg|jpeg|gif|svg|webp|ico|woff2?|mp4|css|js)(\?|$)
""", re.I | re.X)


def skip(href, found):
    return bool(CHROME.search(href))


def classify(href):
    h = href.lower()
    if h.startswith("mailto:"):
        return "email"
    if "sentry.trading" in h:
        return "guide anchor" if "/guide#" in h else "sentry app"
    if "quotrons.cash" in h:
        return "quotrons app"
    if "blockscout.com" in h or "explorer.inkonchain.com" in h:
        return "explorer"
    if "x.com" in h or "twitter.com" in h:
        return "social, X"
    if "t.me" in h:
        return "social, Telegram"
    if "linktr.ee" in h:
        return "link hub"
    if "github.com" in h:
        return "repo"
    if "api." in h or "goldsky" in h or "supabase" in h or "railway.app" in h:
        return "api"
    if "opensea.io" in h:
        return "nft market"
    if "dexscreener" in h or "dextools" in h:
        return "chart"
    if "linkedin.com" in h:
        return "social, LinkedIn"
    return "external"


ALIAS = {
    "https://sentry.trading": "https://www.sentry.trading",
    "http://sentry.trading": "https://www.sentry.trading",
    "https://quotrons.cash": "https://www.quotrons.cash",
    "http://quotrons.cash": "https://www.quotrons.cash",
    "https://www.sentry.trading/desktop/tokens": "https://www.sentry.trading",
    "https://www.sentry.trading/desktop/guide": "https://www.sentry.trading/desktop/guide#welcome",
}


def captured_as(href):
    k = href.rstrip("/")
    k = k.split("#tokens-list")[0].rstrip("/")
    for a, b in ALIAS.items():
        if k == a:
            k = b
            break
        if k.startswith(a + "/"):
            k = b + k[len(a):]
            break
    if k in cap:
        return "`%s`" % cap[k]
    if "#" in k and k.split("#")[0].rstrip("/") in cap:
        return "`%s`" % cap[k.split("#")[0].rstrip("/")]
    if k.startswith("https://www.sentry.trading/desktop/guide#"):
        frag = k.split("#")[1]
        for u, p in cap.items():
            if u.endswith("#" + frag):
                return "`%s`" % p
    for pre, path in raw_map.items():
        if k.startswith(pre):
            return "`%s`" % path if path.startswith("_raw") else path
    if k.startswith("mailto:"):
        return "n/a"
    return "recorded only"


rows = {}
for f, url in src_url.items():
    found = os.path.basename(f)
    s = open(f, encoding="utf-8", errors="replace").read()
    i = s.find("\nLinks/Buttons:")
    seen = set()
    for m in re.finditer(r"\[([^\]]*)\]\((https?://[^)\s]+|mailto:[^)\s]+)\)", s):
        text, href = m.group(1), m.group(2)
        text = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", text).strip()
        text = re.sub(r"\s+", " ", text).replace("\u2014", "-").replace("\u2013", "-")[:70] or "(icon or image link)"
        href = href.rstrip('"').strip()
        if skip(href, found):
            continue
        key = (found, href)
        if key in seen:
            continue
        seen.add(key)
        rows.setdefault(key, (found, text, href))

extra = [
    ("session, live reads", "Robinhood Chain JSON-RPC (Alchemy archive)", "https://rpc.mainnet.chain.robinhood.com/", "rpc", "`_raw/rpc/derived-*.txt`"),
    ("session, live reads", "Sentry Robinhood subgraph", "https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-robinhood/1.2.0/gn", "api", "`_raw/api/goldsky-sentry-robinhood-*.json`"),
    ("session, live reads", "Sentry Ink subgraph", "https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-ink/1.5.0/gn", "api", "recorded only, Ink is out of scope"),
    ("SCRAPING-PLAN 5.6", "Dexscreener pool the plan names", "https://dexscreener.com/robinhood/0x0b142aaf734f1b063355bfe854e282a13b26dcac86e2e564e74540f9b218d069", "chart", "`_raw/dexscreener/pair-0x0b142aaf.json`"),
    ("SCRAPING-PLAN 5.6", "Sentry guide, all anchors", "https://www.sentry.trading/desktop/guide", "sentry app", "`pages/16-guide-welcome.md` through `pages/57-guide-privacy-policy.md`"),
    ("SCRAPING-PLAN 5.6", "Sentry tokens list", "https://www.sentry.trading/desktop/tokens", "sentry app", "`pages/01-app-discover-tokens.md`"),
    ("SCRAPING-PLAN 5.6", "Quotrons", "https://www.quotrons.cash/", "quotrons app", "`pages/59-quotrons-root.md`"),
    ("SCRAPING-PLAN 5.6", "linktr.ee/cruelhand", "https://linktr.ee/cruelhand", "link hub", "`pages/70-linktree-cruelhand.md`"),
    ("SCRAPING-PLAN 5.6", "X, @cruelhandeth", "https://x.com/cruelhandeth", "social, X", "`socials/02-x-cruelhandeth.md`"),
    ("network capture", "X syndication timeline endpoint", "https://syndication.twitter.com/srv/timeline-profile/screen-name/quotrons404", "api", "`_raw/x/syndication-quotrons404.html`"),
    ("guide brand kit", "Sentry brand kit ZIP", "https://www.sentry.trading/brand/sentry-brand-kit.zip", "asset", "recorded only, a 9 MB binary"),
]

L = ["# Sentry link inventory", "",
     "Every link found on any captured Sentry, Quotrons or linked page, plus the endpoints this session called directly.",
     "`found on` names the raw capture the link was read from. `captured as` names the archive file that holds the target, or says why it was only recorded.",
     "Rows are sorted by source file then by URL.", "",
     "| found on | link text | href | type | captured as |",
     "| --- | --- | --- | --- | --- |"]
n = 0
for (found, href), (f2, text, h2) in sorted(rows.items()):
    L.append("| `%s` | %s | %s | %s | %s |" % (found, text.replace("|", "/"), href, classify(href), captured_as(href)))
    n += 1
for found, text, href, typ, capd in extra:
    L.append("| %s | %s | %s | %s | %s |" % (found, text, href, typ, capd))
    n += 1
L += ["", "Total rows: %d." % n]
open(BASE + "/LINKS.md", "w").write("\n".join(L) + "\n")
print(n, "rows")
