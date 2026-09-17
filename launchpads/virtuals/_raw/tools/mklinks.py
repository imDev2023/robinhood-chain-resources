"""Build LINKS.md: one row per link discovered on any captured Virtuals page.

Sources: whitepaper markdown links, Jina "Links/Buttons" lists (www, ext pages),
agent-browser snapshots of app views, Tavily maps, and the launchpad-research.md seed URLs.
"captured as" resolves to the pages/ file whose Source URL matches, else to a raw file, else "not captured".
"""
import os, re, json, glob
from urllib.parse import urlparse, urljoin

BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/virtuals"
RAW = f"{BASE}/_raw"
idx = json.load(open(f"{RAW}/tools/pages-index.json"))


def norm(u):
    u = u.strip().split("#")[0]
    if u.endswith(".md"):
        u = u[:-3]
    u = re.sub(r"\?s=20$", "", u)
    if u.startswith("http") and u.rstrip("/") and u.count("/") == 2:
        u = u.rstrip("/") + "/"
    return u


by_url = {}
for p in idx:
    by_url.setdefault(norm(p["url"]), p["file"])
    by_url.setdefault(norm(p["url"]).rstrip("/"), p["file"])

# raw-only captures (things with a raw file but no page)
raw_only = {
    "https://x.com/virtuals_io/status/2072660137794564521": "socials/02-x-posts-robinhood.md",
    "https://x.com/virtuals_io": "socials/01-x-virtuals-io-profile.md",
    "https://twitter.com/virtuals_io": "socials/01-x-virtuals-io-profile.md",
    "https://discord.com/invite/virtualsio": "socials/03-discord-invite.md",
    "https://discord.gg/virtualsio": "socials/03-discord-invite.md",
    "https://t.me/virtuals": "socials/04-telegram.md",
    "https://virtuals.substack.com/": "socials/05-substack.md",
    "https://dune.com/virtuals_protocol": "socials/06-dune-dashboards.md",
    "https://dune.com/virtual_protocol/virtual-protocol-on-base": "socials/06-dune-dashboards.md",
    "https://github.com/Virtual-Protocol": "socials/07-github-org.md",
    "https://github.com/orgs/Virtual-Protocol": "socials/07-github-org.md",
    "https://github.com/orgs/Virtual-Protocol/repositories": "socials/07-github-org.md",
    "https://code4rena.com/reports/2025-04-virtuals-protocol": "not captured (external audit report page, listed in pages/ security audits page)",
    "https://dexscreener.com/robinhood/0x9cc8c4f6118419a27f113723f1dea646685be55f": "_raw/dexscreener/pair-virtual-weth.json",
}
for r in ["protocol-contracts", "agent-commerce-protocol", "acp-node-v2", "acp-python", "acp-cli", "vp-trade-sdk", "bondv5-trader", "genesis-claim-proof", "cumulative-merkle-distributor", "virtualToken", "vpsol-virtuals-curve"]:
    raw_only[f"https://github.com/Virtual-Protocol/{r}"] = f"_raw/github/{r}/ (clone, commit in _raw/github/COMMITS.txt)"


def captured(href):
    n = norm(href)
    for k in (n, n.rstrip("/"), n + "/"):
        if k in by_url:
            return "pages/" + by_url[k]
        if k in raw_only:
            return raw_only[k]
    h = urlparse(n).netloc
    if h.endswith("blockscout.com") or h in ("robinscan.io", "basescan.org", "etherscan.io", "solscan.io"):
        return "explorer link, addresses covered in contracts/ADDRESSES.md" if "robinhood" in n or h == "robinscan.io" else "not captured (other-chain explorer)"
    if h == "dexscreener.com":
        return "not captured (Dexscreener page; API captures in _raw/dexscreener/)"
    return "not captured"


def ltype(href, found_on):
    h = urlparse(href).netloc.lower()
    if href.startswith("mailto:"):
        return "mailto"
    if h.endswith("whitepaper.virtuals.io"):
        return "docs"
    if h.endswith("app.virtuals.io"):
        return "app"
    if h.endswith("virtuals.io"):
        return "internal"
    if h in ("x.com", "twitter.com", "t.me", "discord.com", "discord.gg", "warpcast.com", "youtube.com", "www.youtube.com", "medium.com", "mirror.xyz") or h.endswith("substack.com"):
        return "social"
    if h in ("github.com",):
        return "repo"
    if h.endswith("blockscout.com") or h in ("robinscan.io", "basescan.org", "etherscan.io", "solscan.io"):
        return "explorer"
    if h in ("dexscreener.com", "dextools.io", "www.dextools.io"):
        return "dex"
    if h in ("dune.com", "defillama.com", "www.coingecko.com", "coingecko.com"):
        return "data"
    if href.lower().endswith(".pdf"):
        return "pdf"
    if h.endswith("code4rena.com") or "audit" in href.lower():
        return "audit"
    return "external"


rows = []
seen = set()


def add(found_on, text, href):
    href = href.strip()
    if not href or href.startswith(("javascript:", "#", "data:")):
        return
    if href.startswith("/"):
        base = found_on if found_on.startswith("http") else "https://whitepaper.virtuals.io/"
        href = urljoin(base, href)
    if not href.startswith(("http", "mailto:")):
        return
    key = (found_on, norm(href))
    if key in seen:
        return
    seen.add(key)
    text = re.sub(r"\s+", " ", text).strip().replace("|", "/").replace("\u2014", "-").replace("\u2013", "-")[:80]
    href = href.replace("\u2014", "-").replace("\u2013", "-")
    rows.append((found_on, text or "(image or icon)", href, ltype(href, found_on), captured(href)))


# 1. whitepaper pages
for p in idx:
    if not p["raw"].startswith("_raw/jina/whitepaper/"):
        continue
    text = open(f"{BASE}/{p['raw']}").read()
    text = re.split(r"\n---\n# Agent Instructions\n", text)[0]
    for m in re.finditer(r"\[([^\]]*)\]\((https?://[^)\s]+|/[^)\s]+)\)", text):
        if "llms.txt" in m.group(2) and m.start() < 400:
            continue
        add(p["url"], m.group(1), m.group(2))
    for m in re.finditer(r'href="(https?://[^"]+)"', text):
        add(p["url"], "(html link)", m.group(1))

# 2. Jina pages (www, ext, pdf)
for p in idx:
    if p["raw"].startswith("_raw/jina/whitepaper/") or not (p["raw"].startswith("_raw/jina/") or p["raw"].startswith("_raw/pdf/")):
        continue
    text = open(f"{BASE}/{p['raw']}").read()
    part = text.split("Links/Buttons:", 1)
    if len(part) == 2:
        for m in re.finditer(r"^- \[([^\]]*)\]\((.*?)\)\s*$", part[1], re.M):
            add(p["url"], m.group(1), m.group(2))
    for m in re.finditer(r"\[([^\]]*)\]\((https?://[^)\s]+)\)", part[0]):
        add(p["url"], m.group(1), m.group(2))

# 3. app snapshots
for p in idx:
    if not p["raw"].startswith("_raw/network/read-"):
        continue
    key = p["raw"][len("_raw/network/read-"):-4]
    snap = f"{RAW}/network/snapshot-{key}.txt"
    if not os.path.exists(snap):
        continue
    for m in re.finditer(r'link "([^"]*)" \[ref=e\d+, url=([^\]\s]+)\]', open(snap).read()):
        add(p["url"], m.group(1), m.group(2))

# 4. Tavily maps and seed list
for mf, base in [("map-www.json", "https://www.virtuals.io/"), ("map-whitepaper.json", "https://whitepaper.virtuals.io/")]:
    for u in json.load(open(f"{RAW}/tavily/{mf}"))["results"]:
        add(f"tvly map {base}", "(tavily map result)", u)
for u in ["https://www.virtuals.io/", "https://whitepaper.virtuals.io/", "https://app.virtuals.io/", "https://dexscreener.com/robinhood/0x9cc8c4f6118419a27f113723f1dea646685be55f"]:
    add("launchpad-research.md section 9", "(seed URL)", u)

rows.sort(key=lambda r: (r[0], r[2]))
out = ["# Virtuals Protocol - link inventory", "", f"Generated 2026-09-02 by `_raw/tools/mklinks.py` from every captured page, snapshot and map; {len(rows)} rows.", "", "| found on | link text | href | type | captured as |", "| --- | --- | --- | --- | --- |"]
for r in rows:
    out.append("| " + " | ".join(r) + " |")
open(f"{BASE}/LINKS.md", "w").write("\n".join(out) + "\n")
from collections import Counter
print("rows", len(rows), Counter(r[3] for r in rows))
print("not captured internal:", sorted(set(r[2] for r in rows if r[3] in ("docs", "app", "internal") and r[4].startswith("not captured")))[:80])
