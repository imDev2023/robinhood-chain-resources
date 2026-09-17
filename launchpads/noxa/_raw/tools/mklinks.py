# Builds LINKS.md by extracting every link from every pages/ and socials/ file.
import os, re, glob, json, urllib.parse, collections
BASE = "/Volumes/Farhan/Work Folder/Dev/AI/long-launch/resources/launchpads/noxa"

cap = {}
for f in sorted(glob.glob(f"{BASE}/pages/*.md")) + sorted(glob.glob(f"{BASE}/socials/*.md")):
    head = open(f, encoding="utf8", errors="replace").read(600)
    m = re.search(r"^> Source: (\S+)", head, re.M)
    if m:
        cap.setdefault(m.group(1).rstrip('/'), os.path.relpath(f, BASE))

def classify(u):
    h = urllib.parse.urlparse(u).netloc.lower()
    if 'noxa' in h and h.startswith('docs.'): return 'docs'
    if h.endswith('noxa.fi') or h.endswith('noxa.io') or 'noxa.eth' in h or h.endswith('noxacto.xyz'): return 'internal'
    if 'x.com' in h or 'twitter.com' in h or 't.me' in h: return 'social'
    if 'blockscout' in h or 'rh-scan' in h or 'explorer' in h: return 'explorer'
    if 'dexscreener' in h or 'geckoterminal' in h or 'defillama' in h or 'coingecko' in h: return 'data'
    if 'github.com' in h: return 'repo'
    if any(k in h for k in ('ipfs', 'pinata', 'arweave', '4everland', 'dweb.link', 'nftstorage', 'flk-ipfs')): return 'asset'
    if 'robinhood.com' in h: return 'chain'
    if 'w3.org' in h or 'localhost' in h or not h: return 'ignore'
    return 'external'

rows, seen = [], set()
for f in sorted(glob.glob(f"{BASE}/pages/*.md")) + sorted(glob.glob(f"{BASE}/socials/*.md")):
    rel = os.path.relpath(f, BASE)
    txt = open(f, encoding="utf8", errors="replace").read()
    for m in re.finditer(r"\[([^\]\n]{0,120})\]\((https?://[^)\s]+)\)", txt):
        text, href = (m.group(1).strip() or "(no text)"), m.group(2).rstrip('.,')
        t = classify(href)
        if t == 'ignore' or (rel, href) in seen: continue
        seen.add((rel, href)); rows.append((rel, text, href, t, cap.get(href.rstrip('/'), 'not captured')))
    for m in re.finditer(r"(?<![\(\[\w])(https?://[a-zA-Z0-9./_?=&%:@#~+-]+)", txt):
        href = m.group(1).rstrip('.,)')
        t = classify(href)
        if t == 'ignore' or (rel, href) in seen: continue
        seen.add((rel, href)); rows.append((rel, "(bare url)", href, t, cap.get(href.rstrip('/'), 'not captured')))

order = {'internal': 0, 'docs': 1, 'social': 2, 'explorer': 3, 'data': 4, 'repo': 5, 'chain': 6, 'asset': 7, 'external': 8}
rows.sort(key=lambda r: (order[r[3]], r[2], r[0]))
cnt = collections.Counter(r[3] for r in rows)
capd = sum(1 for r in rows if r[4] != 'not captured')
L = ["# Noxa link inventory\n",
     "Every link found on any captured Noxa page or social capture, one row per (page, href) pair.",
     "Captured 2026-09-03.",
     f"{len(rows)} rows, {len(set(r[2] for r in rows))} distinct URLs, {capd} rows whose target has its own file in this archive.\n",
     "Type counts: " + ", ".join(f"{k} {v}" for k, v in sorted(cnt.items(), key=lambda kv: -kv[1])) + ".\n",
     "`internal` is any noxa.fi, noxa.io, noxa.eth or noxacto.xyz URL; `docs` is docs.noxa.fi; `asset` is an IPFS gateway URL for a token logo; `external` is everything else, most of it site chrome on the DefiLlama capture.\n",
     "| found on | link text | href | type | captured as |",
     "| --- | --- | --- | --- | --- |"]
esc = lambda s: s.replace('|', '\\|').replace('\n', ' ')[:120]
for r in rows:
    L.append(f"| `{r[0]}` | {esc(r[1])} | <{r[2]}> | {r[3]} | {r[4] if r[4] == 'not captured' else '`' + r[4] + '`'} |")
open(f"{BASE}/LINKS.md", "w").write("\n".join(L) + "\n")
print("wrote", len(rows), "rows")
